// Micasa Mobile Wireframe - Interactivity Script

document.addEventListener('DOMContentLoaded', () => {
    console.log('Micasa mobile interactivity script loaded.');

    // Tab switching logic for My Events page
    const tabLinks = document.querySelectorAll('.tab-link');
    const tabContents = document.querySelectorAll('.tab-content');

    tabLinks.forEach(link => {
        link.addEventListener('click', () => {
            const targetId = link.dataset.target;

            // Update active link
            tabLinks.forEach(innerLink => {
                innerLink.classList.remove('active');
            });
            link.classList.add('active');

            // Update active content
            tabContents.forEach(content => {
                if (content.id === targetId) {
                    content.classList.add('active');
                } else {
                    content.classList.remove('active');
                }
            });
        });
    });
});
