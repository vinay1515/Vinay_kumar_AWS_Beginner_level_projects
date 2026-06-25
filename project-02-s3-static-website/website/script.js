document.addEventListener('DOMContentLoaded', () => {
  console.log('AWS Portfolio Static Website Loaded Successfully.');

  // Intersection Observer for scroll animations
  const cards = document.querySelectorAll('.glass-card');
  
  // Set initial state
  cards.forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(30px)';
    card.style.transition = 'opacity 0.6s ease-out, transform 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
  });

  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -50px 0px"
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  cards.forEach((card, index) => {
    // Add staggered delay based on index for initial load
    if (index < 3) {
      card.style.transitionDelay = `${index * 0.15}s`;
    }
    observer.observe(card);
  });
});
