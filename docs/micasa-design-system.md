# Micasa Design System v1.0

## Design Philosophy

**Core Principle**: "Digital with Soul"
- Every interface element should feel crafted, not generated
- Celebrate imperfection and personality over clinical perfection
- Layer-based design creates depth and hierarchy
- Interactive elements feel tangible and pressable

## Color System

### Primary Palette
Based on your provided color scheme, organized by function:

#### Brand Colors
- **Deep Purple** `#390F37` - Primary brand color, used for key CTAs
- **Medium Purple** `#815288` - Secondary actions, active states
- **Light Purple** `#BD9FD1` - Backgrounds, disabled states

#### Accent Colors
- **Vibrant Orange** `#FE4C01` - High-priority CTAs, urgent actions
- **Warm Orange** `#FF8A01` - Success states, celebrations
- **Light Peach** `#FFB381` - Subtle highlights, hover states

#### Supporting Colors
- **Deep Teal** `#003D59` - Navigation, headers
- **Forest Green** `#167070` - Co-host indicators, secondary accents
- **Sage** `#44857D` - Collaborator badges, tertiary elements

#### Feedback Colors
- **Coral Red** `#FF5558` - Errors, destructive actions
- **Success Green** `#44857D` - Confirmations
- **Warning Amber** `#FF8A01` - Cautions

### Neutrals
```
--neutral-950: #0A0809  // Near black for text
--neutral-900: #1A1618
--neutral-800: #2B2529
--neutral-700: #3C3539
--neutral-600: #4D4649
--neutral-500: #6B6565
--neutral-400: #898383
--neutral-300: #A7A1A1
--neutral-200: #C5BFBF
--neutral-100: #E3DDDD
--neutral-50:  #F5F2F2  // Off-white backgrounds
```

## Typography

### Custom Font Integration
```css
/* Dallas Print Shop - Your custom display font */
@font-face {
  font-family: 'Dallas Print Shop';
  src: url('/fonts/DallasPrintShop-Regular.otf') format('opentype');
  font-weight: 400;
  font-style: normal;
  font-display: swap; /* Ensures text remains visible during font load */
}

/* If you have multiple weights */
@font-face {
  font-family: 'Dallas Print Shop';
  src: url('/fonts/DallasPrintShop-Bold.otf') format('opentype');
  font-weight: 700;
  font-style: normal;
  font-display: swap;
}
```

### Font Stack
```css
--font-display: 'Dallas Print Shop', 'Instrument Serif', Georgia, serif;
--font-body: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'JetBrains Mono', 'Courier New', monospace;
```

### Font Usage Guidelines
- **Dallas Print Shop**: Use for event titles, hero text, and key CTAs
- **Inter**: Body text, form inputs, and UI elements
- **Monospace**: Dates, times, prices, and codes

### Type Scale (Mobile-First)
```css
--text-xs:   0.75rem;   // 12px - Captions, labels
--text-sm:   0.875rem;  // 14px - Secondary text
--text-base: 1rem;      // 16px - Body text
--text-lg:   1.125rem;  // 18px - Emphasized body
--text-xl:   1.5rem;    // 24px - Section headers
--text-2xl:  2rem;      // 32px - Page titles
--text-3xl:  2.5rem;    // 40px - Hero text

/* Desktop adjustments */
@media (min-width: 768px) {
  --text-xl:  1.75rem;   // 28px
  --text-2xl: 2.25rem;   // 36px
  --text-3xl: 3rem;      // 48px
}
```

### Font Weights
- Light: 300 (Display font only)
- Regular: 400
- Medium: 500 (CTAs, emphasis)
- Semibold: 600 (Headers)
- Bold: 700 (Critical actions)

## Spacing System
Based on 4px grid with golden ratio progression:
```css
--space-1: 0.25rem;   // 4px
--space-2: 0.5rem;    // 8px
--space-3: 0.75rem;   // 12px
--space-4: 1rem;      // 16px
--space-5: 1.5rem;    // 24px
--space-6: 2.5rem;    // 40px
--space-7: 4rem;      // 64px
--space-8: 6.5rem;    // 104px
```

## Layout Principles

### Card-Based Architecture
- Content lives in elevated cards, not flat on background
- Cards have subtle shadows and rounded corners
- Background uses subtle texture or gradient

### Layering System
```css
--layer-base: 0;        // Background
--layer-card: 1;        // Content cards
--layer-float: 2;       // Floating elements
--layer-modal: 10;      // Modals
--layer-popover: 15;    // Tooltips, dropdowns
--layer-toast: 20;      // Notifications
```

### Border Radius
```css
--radius-sm: 0.375rem;  // 6px - Buttons, inputs
--radius-md: 0.75rem;   // 12px - Cards
--radius-lg: 1rem;      // 16px - Modals
--radius-xl: 1.5rem;    // 24px - Feature cards
--radius-full: 9999px;  // Pills, avatars
```

## Component Patterns

### Buttons

#### Primary Button
```css
.btn-primary {
  background: linear-gradient(135deg, #390F37 0%, #4A1248 100%);
  color: white;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius-sm);
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(57, 15, 55, 0.25);
  transition: all 0.2s ease;
  border: none;
  position: relative;
  overflow: hidden;
}

.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(57, 15, 55, 0.35);
}

.btn-primary:active {
  transform: translateY(0);
  box-shadow: 0 2px 8px rgba(57, 15, 55, 0.25);
}
```

#### Secondary Button
```css
.btn-secondary {
  background: white;
  color: var(--deep-purple);
  border: 2px solid currentColor;
  /* Intentionally imperfect border */
  border-radius: var(--radius-sm) var(--radius-sm) calc(var(--radius-sm) * 1.2) calc(var(--radius-sm) * 0.9);
}
```

### Cards
```css
.card {
  background: white;
  border-radius: var(--radius-md);
  padding: var(--space-5);
  box-shadow: 
    0 1px 3px rgba(0, 0, 0, 0.04),
    0 4px 16px rgba(0, 0, 0, 0.08);
  position: relative;
  /* Subtle paper texture */
  background-image: 
    linear-gradient(135deg, transparent 0%, rgba(255,255,255,0.5) 50%, transparent 100%),
    url('data:image/svg+xml;utf8,<svg>...</svg>');
}
```

### Form Elements

#### Input Fields
```css
.input {
  background: rgba(255, 255, 255, 0.7);
  border: 2px solid transparent;
  border-bottom-color: var(--neutral-300);
  border-radius: var(--radius-sm) var(--radius-sm) 0 0;
  padding: var(--space-3) var(--space-4);
  transition: all 0.2s ease;
}

.input:focus {
  background: white;
  border-bottom-color: var(--deep-purple);
  box-shadow: 0 4px 12px rgba(57, 15, 55, 0.1);
}
```

### Badges & Tags
```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-full);
  font-size: var(--text-sm);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.025em;
  /* Slightly imperfect circle */
  transform: rotate(-1deg);
}

.badge-host {
  background: var(--deep-purple);
  color: white;
}

.badge-cohost {
  background: var(--forest-green);
  color: white;
}
```

## Motion & Interaction

### Timing Functions
```css
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);
--ease-in: cubic-bezier(0.7, 0, 0.84, 0);
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

### Hover Effects
- Subtle elevation changes (translateY)
- Shadow expansion
- Color brightness adjustments
- Micro-rotations for personality

### Page Transitions
- Fade + slight scale (0.98 → 1)
- Stagger animations for list items
- Smooth scrolling with eased timing

## Unique Design Elements

### Hand-Drawn Accents
- SVG scribbles for emphasis
- Rough circle highlights on CTAs
- Underline decorations that look hand-drawn

### Texture Overlays
```css
.textured-bg {
  background-image: 
    radial-gradient(circle at 20% 80%, var(--light-purple) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, var(--light-peach) 0%, transparent 50%),
    url('noise-texture.svg');
}
```

### Custom Icons
- Line-based, slightly imperfect
- Consistent 2px stroke weight
- Rounded line caps
- Slight rotation variations

## Responsive Breakpoints
```css
--screen-xs: 375px;   // Small phones
--screen-sm: 640px;   // Large phones
--screen-md: 768px;   // Tablets
--screen-lg: 1024px;  // Small laptops
--screen-xl: 1280px;  // Desktops
--screen-2xl: 1536px; // Large screens
```

## Accessibility

### Focus States
- High contrast focus rings (3px)
- Consistent tab navigation
- Skip links for navigation

### Color Contrast
- All text meets WCAG AA standards
- Interactive elements have 3:1 contrast
- Error states use patterns + color

### Motion Preferences
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Implementation Notes

### CSS Architecture
- Use CSS custom properties for theming
- Component-based organization
- Mobile-first responsive design
- Progressive enhancement

### Performance
- Optimize font loading (font-display: swap)
- Use CSS containment for card layouts
- Lazy load images below the fold
- Minimize animation repaints

This design system emphasizes personality and craftsmanship while maintaining usability and accessibility. Each element should feel intentionally designed rather than defaulting to standard patterns.