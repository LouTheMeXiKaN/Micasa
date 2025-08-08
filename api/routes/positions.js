const express = require('express');
const router = express.Router();
const prisma = require('../lib/prisma');
const { authenticateToken } = require('../middleware/auth');
const { body, param, validationResult } = require('express-validator');

// POST /positions/:positionId/applications - Apply to an open position
router.post('/:positionId/applications', authenticateToken, [
  param('positionId').isUUID().withMessage('Invalid position ID format'),
  body('message')
    .notEmpty().withMessage('Application message is required')
    .isLength({ min: 50, max: 1000 }).withMessage('Message must be between 50 and 1000 characters')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { positionId } = req.params;
  const { message } = req.body;
  const userId = req.user.id;

  try {
    // First, check if the position exists and is open
    const position = await prisma.openPosition.findUnique({
      where: { id: positionId },
      include: {
        event: {
          select: {
            id: true,
            title: true,
            host_id: true
          }
        }
      }
    });

    if (!position) {
      return res.status(404).json({
        error_code: 'POSITION_NOT_FOUND',
        message: 'Position not found'
      });
    }

    if (position.status !== 'open') {
      return res.status(400).json({
        error_code: 'POSITION_CLOSED',
        message: 'This position is no longer accepting applications'
      });
    }

    // Check if user has already applied
    const existingApplication = await prisma.application.findFirst({
      where: {
        position_id: positionId,
        applicant_id: userId
      }
    });

    if (existingApplication) {
      return res.status(409).json({
        error_code: 'DUPLICATE_APPLICATION',
        message: 'You have already applied for this position'
      });
    }

    // Create the application
    const application = await prisma.application.create({
      data: {
        position_id: positionId,
        applicant_id: userId,
        message: message,
        status: 'pending'
      },
      include: {
        applicant: {
          select: {
            id: true,
            username: true,
            email: true,
            profile_picture_url: true
          }
        },
        position: {
          select: {
            role_title: true,
            event: {
              select: {
                title: true
              }
            }
          }
        }
      }
    });

    // Create notification for the host
    await prisma.notification.create({
      data: {
        user_id: position.event.host_id,
        type: 'new_application',
        title: 'New Application',
        message: `${application.applicant.username} applied for ${position.role_title}`,
        data: {
          application_id: application.id,
          event_id: position.event.id,
          position_id: position.id
        }
      }
    });

    res.status(201).json({
      success: true,
      application: {
        id: application.id,
        position_id: application.position_id,
        status: application.status,
        message: application.message,
        created_at: application.created_at,
        position: {
          role_title: application.position.role_title,
          event_title: application.position.event.title
        }
      }
    });

  } catch (error) {
    console.error('Error creating application:', error);
    res.status(500).json({
      error_code: 'SERVER_ERROR',
      message: 'Failed to submit application'
    });
  }
});

// GET /positions/:positionId/applications - Get applications for a position (host only)
router.get('/:positionId/applications', authenticateToken, [
  param('positionId').isUUID().withMessage('Invalid position ID format')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { positionId } = req.params;
  const userId = req.user.id;

  try {
    // Check if the user is the host of the event
    const position = await prisma.openPosition.findUnique({
      where: { id: positionId },
      include: {
        event: {
          select: {
            host_id: true
          }
        }
      }
    });

    if (!position) {
      return res.status(404).json({
        error_code: 'POSITION_NOT_FOUND',
        message: 'Position not found'
      });
    }

    // Check if user is the host or a co-host
    const isHost = position.event.host_id === userId;
    const isCohost = await prisma.collaboration.findFirst({
      where: {
        event_id: position.event_id,
        collaborator_id: userId,
        is_cohost: true,
        status: 'accepted'
      }
    });

    if (!isHost && !isCohost) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only hosts and co-hosts can view applications'
      });
    }

    // Get all applications for this position
    const applications = await prisma.application.findMany({
      where: {
        position_id: positionId
      },
      include: {
        applicant: {
          select: {
            id: true,
            username: true,
            email: true,
            profile_picture_url: true,
            bio: true,
            instagram_handle: true,
            personal_website_url: true
          }
        }
      },
      orderBy: {
        created_at: 'desc'
      }
    });

    res.json({
      applications: applications.map(app => ({
        id: app.id,
        applicant: app.applicant,
        message: app.message,
        status: app.status,
        created_at: app.created_at
      }))
    });

  } catch (error) {
    console.error('Error fetching applications:', error);
    res.status(500).json({
      error_code: 'SERVER_ERROR',
      message: 'Failed to fetch applications'
    });
  }
});

module.exports = router;