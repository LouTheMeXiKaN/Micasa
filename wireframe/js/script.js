// Micasa Web Wireframe - Interactivity Script

document.addEventListener('DOMContentLoaded', () => {

    // --- MODAL LOGIC ---
    // This script provides generic functionality for opening and closing modals.
    // To use:
    // 1. A button should have the attribute `data-modal-trigger="your-modal-id"`.
    // 2. The modal overlay element should have the `id="your-modal-id"` and the class `modal-overlay`.
    // 3. The close button inside the modal should have the class `modal-close-btn`.

    const modalTriggers = document.querySelectorAll('[data-modal-trigger]');
    const modalCloseBtns = document.querySelectorAll('.modal-close-btn');
    const modalOverlays = document.querySelectorAll('.modal-overlay');

    // Function to open a modal
    const openModal = (modalId) => {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.add('active');
            // Focus on the first focusable element in the modal for accessibility
            const firstFocusableElement = modal.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
            if (firstFocusableElement) {
                firstFocusableElement.focus();
            }
        }
    };

    // Function to close a modal
    const closeModal = (modal) => {
        if (modal) {
            modal.classList.remove('active');
        }
    };

    // Add click event listener to all modal trigger buttons
    modalTriggers.forEach(trigger => {
        trigger.addEventListener('click', () => {
            const modalId = trigger.dataset.modalTrigger;
            openModal(modalId);
        });
    });

    // Function to handle closing modals, to be attached to multiple elements
    const handleClose = (event) => {
        const modal = event.currentTarget.closest('.modal-overlay');
        closeModal(modal);
    };

    // Add click event listener to all modal close buttons
    modalCloseBtns.forEach(btn => {
        btn.addEventListener('click', handleClose);
    });

    // Add click event listener to all modal overlays to close them on background click
    modalOverlays.forEach(overlay => {
        overlay.addEventListener('click', (event) => {
            // Only close if the overlay itself is clicked, not its content
            if (event.target === overlay) {
                closeModal(overlay);
            }
        });
    });

    // Add keydown event listener to close modal with Escape key
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            const activeModal = document.querySelector('.modal-overlay.active');
            if (activeModal) {
                closeModal(activeModal);
            }
        }
    });

    console.log('Micasa interactivity script loaded.');

    // Note: The smooth scrolling for the "Apply to Collaborate" button is handled
    // by the `scroll-behavior: smooth;` property in the CSS `html` rule.
    // No additional JavaScript is needed for that feature at this time.
});
