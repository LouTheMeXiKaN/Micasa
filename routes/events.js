const express = require('express');
const { body, validationResult, param } = require('express-validator');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Validation rules for event creation
const createEventValidation = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Event title is required')
    .isLength({ max: 255 })
    .withMessage('Event title cannot exceed 255 characters'),
  
  body('description')
    .optional()
    .trim()
    .isLength({ max: 2000 })
    .withMessage('Event description cannot exceed 2000 characters'),
  
  body('start_time')
    .notEmpty()
    .withMessage('Start time is required')
    .isISO8601()
    .withMessage('Start time must be a valid ISO 8601 date'),
  
  body('end_time')
    .notEmpty()
    .withMessage('End time is required')
    .isISO8601()
    .withMessage('End time must be a valid ISO 8601 date')
    .custom((endTime, { req }) => {
      if (new Date(endTime) <= new Date(req.body.start_time)) {
        throw new Error('End time must be after start time');
      }
      return true;
    }),
  
  body('location_address')
    .trim()
    .notEmpty()
    .withMessage('Location address is required')
    .isLength({ max: 500 })
    .withMessage('Location address cannot exceed 500 characters'),
  
  body('location_visibility')
    .isIn(['immediate', 'confirmed_guests', '24_hours_before'])
    .withMessage('Location visibility must be one of: immediate, confirmed_guests, 24_hours_before'),
  
  body('pricing_model')
    .isIn(['fixed_price', 'choose_your_price', 'donation_based', 'free_rsvp'])
    .withMessage('Pricing model must be one of: fixed_price, choose_your_price, donation_based, free_rsvp')
    .custom((pricingModel) => {
      // Stage 1 constraint: only free_rsvp allowed
      if (pricingModel !== 'free_rsvp') {
        throw new Error('Only free_rsvp pricing model is supported in Stage 1');
      }
      return true;
    }),
  
  body('guest_list_visibility')
    .isIn(['public', 'attendees_live', 'private'])
    .withMessage('Guest list visibility must be one of: public, attendees_live, private'),
  
  body('is_invite_only')
    .isBoolean()
    .withMessage('is_invite_only must be boolean'),
  
  body('max_capacity')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Max capacity must be a positive integer'),
];

// Validation rules for event updates
const updateEventValidation = [
  body('title')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Event title cannot be empty')
    .isLength({ max: 255 })
    .withMessage('Event title cannot exceed 255 characters'),
  
  body('description')
    .optional()
    .trim()
    .isLength({ max: 2000 })
    .withMessage('Event description cannot exceed 2000 characters'),
  
  body('start_time')
    .optional()
    .isISO8601()
    .withMessage('Start time must be a valid ISO 8601 date'),
  
  body('end_time')
    .optional()
    .isISO8601()
    .withMessage('End time must be a valid ISO 8601 date'),
  
  body('location_address')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Location address cannot be empty')
    .isLength({ max: 500 })
    .withMessage('Location address cannot exceed 500 characters'),
  
  body('location_visibility')
    .optional()
    .isIn(['immediate', 'confirmed_guests', '24_hours_before'])
    .withMessage('Location visibility must be one of: immediate, confirmed_guests, 24_hours_before'),
  
  body('pricing_model')
    .optional()
    .isIn(['fixed_price', 'choose_your_price', 'donation_based', 'free_rsvp'])
    .withMessage('Pricing model must be one of: fixed_price, choose_your_price, donation_based, free_rsvp')
    .custom((pricingModel) => {
      // Stage 1 constraint: only free_rsvp allowed
      if (pricingModel && pricingModel !== 'free_rsvp') {
        throw new Error('Only free_rsvp pricing model is supported in Stage 1');
      }
      return true;
    }),
  
  body('guest_list_visibility')
    .optional()
    .isIn(['public', 'attendees_live', 'private'])
    .withMessage('Guest list visibility must be one of: public, attendees_live, private'),
  
  body('is_invite_only')
    .optional()
    .isBoolean()
    .withMessage('is_invite_only must be boolean'),
  
  body('max_capacity')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Max capacity must be a positive integer'),
];

// Helper function to calculate user's role in an event
async function calculateUserRole(eventId, userId) {
  // Check if user is the host
  const event = await prisma.event.findUnique({
    where: { id: eventId },
    select: { hostUserId: true }
  });

  if (event?.hostUserId === userId) {
    return 'host';
  }

  // TODO: Check collaboration and ticket tables when implemented
  // For now, non-hosts have 'none' role
  return 'none';
}

// Helper function to calculate event statistics
async function calculateEventStats(eventId) {
  // For Stage 1, we'll return basic stats since ticket and collaboration models aren't implemented yet
  // TODO: Update when ticket and collaboration models are added
  
  const registeredCount = 0; // Will be implemented when ticket model is added
  const maybeCount = 0; // Will be implemented when ticket model is added
  const teamSize = 1; // Currently just the host, will be updated when collaboration model is added
  const grossRevenue = 0.0; // Stage 1: only free events

  return {
    registered_count: registeredCount,
    maybe_count: maybeCount,
    team_size: teamSize,
    gross_revenue: grossRevenue
  };
}

// Helper function to format event response
function formatEventResponse(event, stats, currentUserRole) {
  // Build team array starting with the host
  const team = [];
  
  // Add host as the first team member
  if (event.host) {
    team.push({
      collaboration_id: `host-${event.id}`,  // Special ID for host
      user: {
        user_id: event.host.id,
        username: event.host.username,
        profile_picture_url: event.host.profilePictureUrl,
        bio: event.host.bio
      },
      role_title: 'Host',
      is_cohost: false,
      profit_share_percentage: 100  // Host gets 100% by default unless split with collaborators
    });
  }
  
  // Add collaborators to the team
  if (event.collaborations) {
    event.collaborations.forEach(collab => {
      if (collab.user) {  // Only add if user exists (might be null for phone-only invites)
        team.push({
          collaboration_id: collab.id,
          user: {
            user_id: collab.user.id,
            username: collab.user.username,
            profile_picture_url: collab.user.profilePictureUrl,
            bio: collab.user.bio
          },
          role_title: collab.roleTitle,
          is_cohost: collab.isCohost,
          profit_share_percentage: parseFloat(collab.profitSharePercentage.toString())
        });
      }
    });
  }

  return {
    event_id: event.id,
    host_user_id: event.hostUserId,
    title: event.title,
    description: event.description,
    cover_image_url: event.coverImageUrl,
    start_time: event.startTime.toISOString(),
    end_time: event.endTime.toISOString(),
    location_address: event.locationAddress,
    location_visibility: event.locationVisibility,
    pricing_model: event.pricingModel,
    price_fixed: event.priceFixed,
    guest_list_visibility: event.guestListVisibility,
    is_invite_only: event.isInviteOnly,
    max_capacity: event.maxCapacity,
    status: event.status,
    stats: stats,
    current_user_role: currentUserRole,
    team: team,  // Add team array
    open_positions: [],  // TODO: fetch open positions
    attendees: [],  // TODO: fetch attendees based on visibility rules
    attendee_count: stats.registered_count || 0
  };
}

// POST /events - Create a new event
router.post('/', authenticateToken, createEventValidation, async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid input data',
        details: errors.array()
      });
    }

    const {
      title,
      description,
      start_time,
      end_time,
      location_address,
      location_visibility,
      pricing_model,
      guest_list_visibility,
      is_invite_only,
      max_capacity
    } = req.body;

    // Create the event
    const event = await prisma.event.create({
      data: {
        hostUserId: req.userId,
        title,
        description,
        startTime: new Date(start_time),
        endTime: new Date(end_time),
        locationAddress: location_address,
        locationVisibility: location_visibility,
        pricingModel: pricing_model,
        guestListVisibility: guest_list_visibility,
        isInviteOnly: is_invite_only,
        maxCapacity: max_capacity,
        status: 'published',
        currency: 'USD'
      },
      include: {
        host: true,
        collaborations: {
          where: { status: 'accepted' },
          include: { user: true }
        }
      }
    });

    // Calculate initial stats and user role
    const stats = await calculateEventStats(event.id);
    const currentUserRole = 'host'; // Creator is always the host

    const response = formatEventResponse(event, stats, currentUserRole);

    res.status(201).json(response);
  } catch (error) {
    console.error('Error creating event:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to create event'
    });
  }
});

// GET /events/:eventId - Get event details
router.get('/:eventId', [
  param('eventId').isUUID().withMessage('Invalid event ID format')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid event ID format',
        details: errors.array()
      });
    }

    const eventId = req.params.eventId;

    // Find the event with team data
    const event = await prisma.event.findUnique({
      where: { id: eventId },
      include: {
        host: true,  // Include host user data
        collaborations: {
          where: {
            status: 'accepted'  // Only show accepted collaborators
          },
          include: {
            user: true  // Include user details for each collaborator
          }
        }
      }
    });

    if (!event) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested event could not be found'
      });
    }

    // Calculate stats
    const stats = await calculateEventStats(eventId);

    // Calculate current user role (if authenticated)
    let currentUserRole = 'none';
    if (req.headers.authorization) {
      try {
        // Try to authenticate, but don't fail if token is invalid
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.split(' ')[1];
        if (token) {
          const { verifyToken } = require('../utils/jwt');
          const decoded = verifyToken(token);
          currentUserRole = await calculateUserRole(eventId, decoded.userId);
        }
      } catch (error) {
        // Continue with 'none' role if authentication fails
        currentUserRole = 'none';
      }
    }

    const response = formatEventResponse(event, stats, currentUserRole);
    res.json(response);
  } catch (error) {
    console.error('Error fetching event:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to retrieve event details'
    });
  }
});

// PUT /events/:eventId - Update event details (Host only)
router.put('/:eventId', authenticateToken, [
  param('eventId').isUUID().withMessage('Invalid event ID format'),
  ...updateEventValidation
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid input data',
        details: errors.array()
      });
    }

    const eventId = req.params.eventId;

    // Find the event and verify host permission
    const event = await prisma.event.findUnique({
      where: { id: eventId }
    });

    if (!event) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested event could not be found'
      });
    }

    // Check if user is the host
    if (event.hostUserId !== req.userId) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only the event host can update event details'
      });
    }

    // Prepare update data
    const updateData = {};
    const allowedFields = {
      title: 'title',
      description: 'description',
      start_time: 'startTime',
      end_time: 'endTime',
      location_address: 'locationAddress',
      location_visibility: 'locationVisibility',
      pricing_model: 'pricingModel',
      guest_list_visibility: 'guestListVisibility',
      is_invite_only: 'isInviteOnly',
      max_capacity: 'maxCapacity'
    };

    // Map request fields to Prisma field names
    for (const [reqField, prismaField] of Object.entries(allowedFields)) {
      if (req.body[reqField] !== undefined) {
        if (reqField === 'start_time' || reqField === 'end_time') {
          updateData[prismaField] = new Date(req.body[reqField]);
        } else {
          updateData[prismaField] = req.body[reqField];
        }
      }
    }

    // Validate that end_time is after start_time if both are being updated
    if (updateData.startTime || updateData.endTime) {
      const startTime = updateData.startTime || event.startTime;
      const endTime = updateData.endTime || event.endTime;
      
      if (endTime <= startTime) {
        return res.status(400).json({
          error_code: 'VALIDATION_FAILED',
          message: 'End time must be after start time'
        });
      }
    }

    // Update the event
    const updatedEvent = await prisma.event.update({
      where: { id: eventId },
      data: updateData,
      include: {
        host: true,
        collaborations: {
          where: { status: 'accepted' },
          include: { user: true }
        }
      }
    });

    // Calculate updated stats and user role
    const stats = await calculateEventStats(eventId);
    const currentUserRole = 'host'; // User is verified as host above

    const response = formatEventResponse(updatedEvent, stats, currentUserRole);
    res.json(response);
  } catch (error) {
    console.error('Error updating event:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to update event'
    });
  }
});

// =============================================
// EVENT COLLABORATION HUB ENDPOINT
// =============================================

// GET /events/:eventId/team - Get collaboration hub data
router.get('/:eventId/team', authenticateToken, [
  param('eventId').isUUID().withMessage('Invalid event ID format')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid event ID format',
        details: errors.array()
      });
    }

    const eventId = req.params.eventId;

    // Check if event exists and user has permission
    const event = await prisma.event.findUnique({
      where: { id: eventId }
    });

    if (!event) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested event could not be found'
      });
    }

    // Check if user has permission to view collaboration data
    const { hasPermission } = await checkEventPermission(eventId, req.userId);
    
    if (!hasPermission) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only event hosts and co-hosts can view collaboration data'
      });
    }

    // Get open positions with application counts
    const openPositions = await prisma.openPosition.findMany({
      where: { 
        eventId: eventId,
        status: 'open'
      },
      include: {
        _count: {
          select: { 
            applications: {
              where: { status: 'pending' }
            }
          }
        }
      }
    });

    // TODO: Get confirmed team members (hosts, co-hosts, collaborators)
    // For now, just return the host as the only team member
    const host = await prisma.user.findUnique({
      where: { id: event.hostUserId },
      select: {
        id: true,
        username: true,
        profilePictureUrl: true
      }
    });

    const confirmedTeam = host ? [{
      collaboration_id: null, // Host doesn't have a collaboration record
      user_id: host.id,
      username: host.username,
      profile_picture_url: host.profilePictureUrl,
      role_title: 'Host',
      profit_share_percentage: 100, // Host owns 100% by default
      is_cohost: false
    }] : [];

    // TODO: Get pending proposals when Collaboration model is implemented
    const pendingProposals = [];

    // Format the response according to API contract
    const response = {
      confirmed_team: confirmedTeam,
      pending_proposals: pendingProposals,
      open_positions: openPositions.map(position => ({
        position_id: position.id,
        role_title: position.roleTitle,
        profit_share_percentage: position.profitSharePercentage ? 
          parseFloat(position.profitSharePercentage.toString()) : null,
        applicant_count: position._count.applications
      }))
    };

    res.json(response);

  } catch (error) {
    console.error('Error fetching collaboration data:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to retrieve collaboration data'
    });
  }
});

// =============================================
// OPEN POSITION MANAGEMENT ENDPOINTS
// =============================================

// Helper function to check if user is event host or co-host
async function checkEventPermission(eventId, userId) {
  // Check if user is the host
  const event = await prisma.event.findUnique({
    where: { id: eventId },
    select: { hostUserId: true }
  });

  if (event?.hostUserId === userId) {
    return { hasPermission: true, isHost: true };
  }

  // TODO: Check if user is a co-host when Collaboration model is implemented
  // For now, only hosts can manage positions
  return { hasPermission: false, isHost: false };
}

// Validation rules for position creation
const createPositionValidation = [
  body('role_title')
    .trim()
    .notEmpty()
    .withMessage('Role title is required')
    .isLength({ max: 30 })
    .withMessage('Role title cannot exceed 30 characters'),
  
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description cannot exceed 1000 characters'),
  
  body('profit_share_percentage')
    .optional()
    .isFloat({ min: 0, max: 100 })
    .withMessage('Profit share percentage must be between 0 and 100')
];

// Validation rules for position updates
const updatePositionValidation = [
  body('role_title')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Role title cannot be empty')
    .isLength({ max: 30 })
    .withMessage('Role title cannot exceed 30 characters'),
  
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description cannot exceed 1000 characters'),
  
  body('profit_share_percentage')
    .optional()
    .isFloat({ min: 0, max: 100 })
    .withMessage('Profit share percentage must be between 0 and 100')
];

// POST /events/:eventId/positions - Create a new open position
router.post('/:eventId/positions', authenticateToken, [
  param('eventId').isUUID().withMessage('Invalid event ID format'),
  ...createPositionValidation
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid input data',
        details: errors.array()
      });
    }

    const eventId = req.params.eventId;
    const { role_title, description, profit_share_percentage } = req.body;

    // Check if event exists and user has permission
    const { hasPermission } = await checkEventPermission(eventId, req.userId);
    
    if (!hasPermission) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only event hosts and co-hosts can manage positions'
      });
    }

    // Verify event exists
    const event = await prisma.event.findUnique({
      where: { id: eventId }
    });

    if (!event) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested event could not be found'
      });
    }

    // Create the position
    const position = await prisma.openPosition.create({
      data: {
        eventId: eventId,
        roleTitle: role_title,
        description: description || null,
        profitSharePercentage: profit_share_percentage || null,
        status: 'open'
      }
    });

    // Return formatted response
    const response = {
      position_id: position.id,
      event_id: position.eventId,
      role_title: position.roleTitle,
      description: position.description,
      profit_share_percentage: position.profitSharePercentage ? parseFloat(position.profitSharePercentage.toString()) : null,
      status: position.status,
      created_at: position.createdAt.toISOString()
    };

    res.status(201).json(response);
  } catch (error) {
    console.error('Error creating position:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to create position'
    });
  }
});

// PUT /positions/:positionId - Update an open position
router.put('/positions/:positionId', authenticateToken, [
  param('positionId').isUUID().withMessage('Invalid position ID format'),
  ...updatePositionValidation
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid input data',
        details: errors.array()
      });
    }

    const positionId = req.params.positionId;

    // Find the position and related event
    const position = await prisma.openPosition.findUnique({
      where: { id: positionId },
      include: {
        event: {
          select: { id: true, hostUserId: true }
        }
      }
    });

    if (!position) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested position could not be found'
      });
    }

    // Check if user has permission to update this position
    const { hasPermission } = await checkEventPermission(position.event.id, req.userId);
    
    if (!hasPermission) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only event hosts and co-hosts can manage positions'
      });
    }

    // Prepare update data
    const updateData = {};
    const allowedFields = {
      role_title: 'roleTitle',
      description: 'description',
      profit_share_percentage: 'profitSharePercentage'
    };

    // Map request fields to Prisma field names
    for (const [reqField, prismaField] of Object.entries(allowedFields)) {
      if (req.body[reqField] !== undefined) {
        updateData[prismaField] = req.body[reqField];
      }
    }

    // Update the position
    const updatedPosition = await prisma.openPosition.update({
      where: { id: positionId },
      data: updateData
    });

    // Return formatted response
    const response = {
      position_id: updatedPosition.id,
      event_id: updatedPosition.eventId,
      role_title: updatedPosition.roleTitle,
      description: updatedPosition.description,
      profit_share_percentage: updatedPosition.profitSharePercentage ? parseFloat(updatedPosition.profitSharePercentage.toString()) : null,
      status: updatedPosition.status,
      created_at: updatedPosition.createdAt.toISOString()
    };

    res.json(response);
  } catch (error) {
    console.error('Error updating position:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to update position'
    });
  }
});

// DELETE /positions/:positionId - Delete an open position
router.delete('/positions/:positionId', authenticateToken, [
  param('positionId').isUUID().withMessage('Invalid position ID format')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid position ID format',
        details: errors.array()
      });
    }

    const positionId = req.params.positionId;

    // Find the position and related event
    const position = await prisma.openPosition.findUnique({
      where: { id: positionId },
      include: {
        event: {
          select: { id: true, hostUserId: true }
        },
        applications: {
          select: { id: true }
        }
      }
    });

    if (!position) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested position could not be found'
      });
    }

    // Check if user has permission to delete this position
    const { hasPermission } = await checkEventPermission(position.event.id, req.userId);
    
    if (!hasPermission) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only event hosts and co-hosts can manage positions'
      });
    }

    // Check if position has existing applications
    if (position.applications.length > 0) {
      return res.status(409).json({
        error_code: 'CONFLICT',
        message: 'Cannot delete a position that has existing applications'
      });
    }

    // Delete the position
    await prisma.openPosition.delete({
      where: { id: positionId }
    });

    res.status(204).send();
  } catch (error) {
    console.error('Error deleting position:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to delete position'
    });
  }
});

// =============================================
// RSVP/TICKET ENDPOINTS
// =============================================

// POST /events/:eventId/rsvp - Create RSVP for free events
router.post('/:eventId/rsvp', authenticateToken, [
  param('eventId').isUUID().withMessage('Invalid event ID format'),
  body('rsvp_status')
    .optional()
    .isIn(['going', 'maybe', 'not_going'])
    .withMessage('RSVP status must be going, maybe, or not_going')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid input data',
        details: errors.array()
      });
    }

    const eventId = req.params.eventId;
    const userId = req.userId;
    const rsvpStatus = req.body.rsvp_status || 'going';

    // Find the event
    const event = await prisma.event.findUnique({
      where: { id: eventId },
      include: {
        tickets: {
          where: { userId: userId }
        }
      }
    });

    if (!event) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'Event not found'
      });
    }

    // Check if event is free (only free events support RSVP)
    if (event.pricingModel !== 'free_rsvp' && event.pricingModel !== 'donation_based') {
      return res.status(400).json({
        error_code: 'INVALID_OPERATION',
        message: 'This event requires a ticket purchase, not an RSVP'
      });
    }

    // Check capacity if going
    if (rsvpStatus === 'going' && event.maxCapacity) {
      const goingCount = await prisma.ticket.count({
        where: {
          eventId: eventId,
          rsvpStatus: 'going'
        }
      });

      if (goingCount >= event.maxCapacity) {
        return res.status(409).json({
          error_code: 'EVENT_FULL',
          message: 'Sorry, this event is at capacity'
        });
      }
    }

    // Check if user already has a ticket
    let ticket;
    if (event.tickets.length > 0) {
      // Update existing ticket
      ticket = await prisma.ticket.update({
        where: { id: event.tickets[0].id },
        data: { rsvpStatus: rsvpStatus }
      });
    } else {
      // Create new ticket
      ticket = await prisma.ticket.create({
        data: {
          eventId: eventId,
          userId: userId,
          rsvpStatus: rsvpStatus,
          // Extract referrer from headers if present
          referrerUserId: req.headers['x-referrer-id'] || null
        }
      });

      // Create event association
      await prisma.eventAssociation.create({
        data: {
          eventId: eventId,
          userId: userId,
          role: 'attendee'
        }
      }).catch(() => {
        // Ignore if already exists
      });
    }

    res.json({
      ticket_id: ticket.id,
      rsvp_status: ticket.rsvpStatus,
      message: rsvpStatus === 'going' ? "You're going!" : 
               rsvpStatus === 'maybe' ? "Marked as interested" : 
               "RSVP updated"
    });

  } catch (error) {
    console.error('Error creating RSVP:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to create RSVP'
    });
  }
});

// =============================================
// APPLICATION MANAGEMENT ENDPOINTS
// =============================================

// Validation rules for application creation
const createApplicationValidation = [
  body('message')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Message cannot exceed 1000 characters')
];

// Validation rules for application management
const manageApplicationValidation = [
  body('action')
    .isIn(['accept', 'decline'])
    .withMessage('Action must be either "accept" or "decline"')
];

// POST /positions/:positionId/applications - Apply for a position
router.post('/positions/:positionId/applications', authenticateToken, [
  param('positionId').isUUID().withMessage('Invalid position ID format'),
  ...createApplicationValidation
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid input data',
        details: errors.array()
      });
    }

    const positionId = req.params.positionId;
    const { message } = req.body;
    const userId = req.userId;

    // Find the position and verify it exists and is open
    const position = await prisma.openPosition.findUnique({
      where: { id: positionId },
      include: {
        event: {
          select: { id: true, hostUserId: true, title: true }
        }
      }
    });

    if (!position) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested position could not be found'
      });
    }

    // Check if position is still open
    if (position.status !== 'open') {
      return res.status(409).json({
        error_code: 'POSITION_NOT_AVAILABLE',
        message: 'This position is no longer accepting applications'
      });
    }

    // Check if user is trying to apply to their own event
    if (position.event.hostUserId === userId) {
      return res.status(409).json({
        error_code: 'INVALID_OPERATION',
        message: 'You cannot apply to positions on your own event'
      });
    }

    // Check if user has already applied for this position
    const existingApplication = await prisma.application.findUnique({
      where: {
        positionId_userId: {
          positionId: positionId,
          userId: userId
        }
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
        positionId: positionId,
        userId: userId,
        message: message || null,
        status: 'pending'
      }
    });

    res.status(201).json({
      application_id: application.id,
      message: 'Application submitted successfully'
    });

  } catch (error) {
    console.error('Error creating application:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to submit application'
    });
  }
});

// GET /positions/:positionId/applications - List applications for a position (Host only)
router.get('/positions/:positionId/applications', authenticateToken, [
  param('positionId').isUUID().withMessage('Invalid position ID format')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid position ID format',
        details: errors.array()
      });
    }

    const positionId = req.params.positionId;

    // Find the position and verify user has permission
    const position = await prisma.openPosition.findUnique({
      where: { id: positionId },
      include: {
        event: {
          select: { id: true, hostUserId: true }
        }
      }
    });

    if (!position) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested position could not be found'
      });
    }

    // Check if user has permission to view applications
    const { hasPermission } = await checkEventPermission(position.event.id, req.userId);
    
    if (!hasPermission) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only event hosts and co-hosts can view applications'
      });
    }

    // Get all applications for this position
    const applications = await prisma.application.findMany({
      where: { 
        positionId: positionId,
        status: 'pending' // Only show pending applications
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profilePictureUrl: true,
            bio: true,
            instagramHandle: true,
            personalWebsiteUrl: true
          }
        }
      },
      orderBy: {
        appliedAt: 'asc' // First come, first served
      }
    });

    // Format the response according to API contract
    const formattedApplications = applications.map(app => ({
      application_id: app.id,
      application_date: app.appliedAt.toISOString(),
      message: app.message,
      user_info: {
        user_id: app.user.id,
        username: app.user.username,
        profile_picture_url: app.user.profilePictureUrl,
        bio: app.user.bio,
        instagram_handle: app.user.instagramHandle,
        personal_website_url: app.user.personalWebsiteUrl
      }
    }));

    res.json(formattedApplications);

  } catch (error) {
    console.error('Error fetching applications:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to retrieve applications'
    });
  }
});

// POST /applications/:applicationId/manage - Accept or decline application (Host only)
router.post('/applications/:applicationId/manage', authenticateToken, [
  param('applicationId').isUUID().withMessage('Invalid application ID format'),
  ...manageApplicationValidation
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid input data',
        details: errors.array()
      });
    }

    const applicationId = req.params.applicationId;
    const { action } = req.body;

    // Find the application and related data
    const application = await prisma.application.findUnique({
      where: { id: applicationId },
      include: {
        position: {
          include: {
            event: {
              select: { id: true, hostUserId: true }
            }
          }
        },
        user: {
          select: { id: true, username: true }
        }
      }
    });

    if (!application) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested application could not be found'
      });
    }

    // Check if user has permission to manage this application
    const { hasPermission } = await checkEventPermission(application.position.event.id, req.userId);
    
    if (!hasPermission) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'Only event hosts and co-hosts can manage applications'
      });
    }

    // Check if application is still pending
    if (application.status !== 'pending') {
      return res.status(409).json({
        error_code: 'INVALID_OPERATION',
        message: 'This application has already been processed'
      });
    }

    // Check if position is still open (only for accept action)
    if (action === 'accept' && application.position.status !== 'open') {
      return res.status(409).json({
        error_code: 'POSITION_NOT_AVAILABLE',
        message: 'This position is no longer available'
      });
    }

    // Use transaction for consistency
    const result = await prisma.$transaction(async (tx) => {
      // Update application status
      const updatedApplication = await tx.application.update({
        where: { id: applicationId },
        data: { status: action === 'accept' ? 'accepted' : 'declined' }
      });

      // If accepting, mark position as filled
      if (action === 'accept') {
        await tx.openPosition.update({
          where: { id: application.position.id },
          data: { 
            status: 'filled',
            filledByUserId: application.userId
          }
        });

        // Decline all other pending applications for this position
        await tx.application.updateMany({
          where: {
            positionId: application.position.id,
            status: 'pending',
            id: { not: applicationId }
          },
          data: { status: 'declined' }
        });
      }

      return updatedApplication;
    });

    const responseMessage = action === 'accept' 
      ? 'Application accepted successfully'
      : 'Application declined successfully';

    res.json({
      application_id: result.id,
      status: result.status,
      message: responseMessage
    });

  } catch (error) {
    console.error('Error managing application:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to manage application'
    });
  }
});

// DELETE /applications/:applicationId - Withdraw application (Applicant only)
router.delete('/applications/:applicationId', authenticateToken, [
  param('applicationId').isUUID().withMessage('Invalid application ID format')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error_code: 'VALIDATION_FAILED',
        message: 'Invalid application ID format',
        details: errors.array()
      });
    }

    const applicationId = req.params.applicationId;
    const userId = req.userId;

    // Find the application
    const application = await prisma.application.findUnique({
      where: { id: applicationId },
      include: {
        position: {
          select: { status: true }
        }
      }
    });

    if (!application) {
      return res.status(404).json({
        error_code: 'RESOURCE_NOT_FOUND',
        message: 'The requested application could not be found'
      });
    }

    // Check if user owns this application
    if (application.userId !== userId) {
      return res.status(403).json({
        error_code: 'FORBIDDEN',
        message: 'You can only withdraw your own applications'
      });
    }

    // Check if application is still pending
    if (application.status !== 'pending') {
      return res.status(409).json({
        error_code: 'INVALID_OPERATION',
        message: 'You can only withdraw pending applications'
      });
    }

    // Check if position is already filled
    if (application.position.status === 'filled') {
      return res.status(409).json({
        error_code: 'INVALID_OPERATION',
        message: 'Cannot withdraw application from a filled position'
      });
    }

    // Update application status to withdrawn
    await prisma.application.update({
      where: { id: applicationId },
      data: { status: 'withdrawn' }
    });

    res.status(204).send();

  } catch (error) {
    console.error('Error withdrawing application:', error);
    res.status(500).json({
      error_code: 'INTERNAL_ERROR',
      message: 'Failed to withdraw application'
    });
  }
});

module.exports = router;