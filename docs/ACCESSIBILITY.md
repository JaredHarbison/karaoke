# Accessibility Guidelines

WCAG 2.1 AA is the project target, not a claim of completed compliance. Review
and test each user-facing change with the appropriate automated and manual
checks.

This document outlines accessibility standards and best practices for the Karaoke Queue application, based on WCAG 2.1 Level AA standards.

## Standards & Compliance

### WCAG 2.1 Level AA

- Target compliance level for all features
- Ensures usability for people with disabilities
- Legal requirement in many jurisdictions

### Key Principles (POUR)

1. **Perceivable** - Information must be presentable in ways users can perceive
2. **Operable** - Interface components must be operable via keyboard and assistive technologies
3. **Understandable** - Text and interface must be clear and predictable
4. **Robust** - Content must be compatible with assistive technologies

## Implementation Guidelines

### 1. Semantic HTML

Use correct HTML elements for meaning:

```html
<!-- ✅ Good -->
<button type="button" aria-label="Skip song">Skip</button>
<h1>Song Queue</h1>
<nav aria-label="Main navigation"></nav>
<main role="main"></main>
<aside role="complementary"></aside>

<!-- ❌ Avoid -->
<div onclick="skipSong()">Skip</div>
<div class="h1-style">Song Queue</div>
```

### 2. ARIA Labels & Landmarks

Provide context for screen readers:

```html
<!-- Button with label -->
<button aria-label="Add new song to queue">
  <i class="icon-plus"></i> Add Song
</button>

<!-- Form with fieldsets -->
<form>
  <fieldset>
    <legend>Song Details</legend>
    <label for="performer">Performer Name</label>
    <input id="performer" type="text" required>
  </fieldset>
</form>

<!-- Live regions for updates -->
<div aria-live="polite" aria-atomic="true" id="status-message">
  Song added to queue
</div>

<!-- Landmark regions -->
<header role="banner"></header>
<nav role="navigation" aria-label="Site"></nav>
<main role="main"></main>
<footer role="contentinfo"></footer>
```

### 3. Keyboard Navigation

All interactive elements must be keyboard accessible:

```javascript
// ✅ Good: Keyboard support built-in
<button>Click me</button>
<a href="/songs">Navigate</a>
<input type="text">

// ✅ Use tabindex sparingly (only when necessary)
<div tabindex="0" role="button" aria-label="Action">
  Custom interactive element
</div>

// ❌ Avoid: Keyboard inaccessible
<div onclick="action()">Not keyboard accessible</div>
<span role="button">Keyboard trap</span>
```

### 4. Color Contrast

Minimum contrast ratios (WCAG AA):

- Normal text: 4.5:1 (black on white, or equivalent)
- Large text (18pt+): 3:1
- UI components: 3:1

Use tools to verify:

```bash
# Check contrast in your CSS
# Use WebAIM Color Contrast Checker
# https://webaim.org/resources/contrastchecker/
```

### 5. Focus Management

Clear, visible focus indicators:

```css
/* ✅ Good: Very visible focus state */
button:focus,
input:focus,
a:focus {
  outline: 3px solid #4A90E2;
  outline-offset: 2px;
}

a:focus-visible {
  outline: 2px solid #4A90E2;
}

/* ❌ Avoid: Removing focus (NEVER do this) */
*:focus {
  outline: none; /* INACCESSIBLE */
}
```

### 6. Image Accessibility

Always provide meaningful alternatives:

```html
<!-- ✅ Good: Descriptive alt text -->
<img src="venue-photo.jpg" alt="Inside of Joe's Karaoke Bar with stage and seating">

<!-- ✅ Decorative images -->
<img src="divider.svg" alt="" aria-hidden="true">

<!-- ✅ Complex images with long description -->
<figure>
  <img src="queue-chart.png" alt="Song queue chart showing 5 pending songs">
  <figcaption>Current queue with estimated wait times</figcaption>
</figure>

<!-- ❌ Avoid: Missing or unhelpful alt text -->
<img src="image.jpg" alt="image">
<img src="button.png" alt="">
```

### 7. Form Accessibility

Make forms easy to complete:

```html
<!-- ✅ Good: Clear labels and error messages -->
<label for="email">Email Address</label>
<input id="email" type="email" required aria-required="true">
<span id="email-error" role="alert" aria-live="polite"></span>

<!-- ✅ Group related fields -->
<fieldset>
  <legend>Song Status</legend>
  <label>
    <input type="radio" name="status" value="upcoming"> Upcoming
  </label>
  <label>
    <input type="radio" name="status" value="finished"> Finished
  </label>
</fieldset>

<!-- ✅ Instructions are associated -->
<label for="youtube-url">YouTube URL</label>
<input id="youtube-url" type="url" aria-describedby="url-help">
<span id="url-help">Format: https://youtube.com/watch?v=dGw8w3tiWow</span>

<!-- ❌ Avoid: Placeholder only (disappears when typing) -->
<input type="text" placeholder="Enter your name">
```

### 8. Video & Media Accessibility

Provide captions and transcripts:

```html
<!-- ✅ Good: Video with captions -->
<video controls>
  <source src="karaoke-demo.mp4" type="video/mp4">
  <track kind="captions" src="captions.vtt" srclang="en" label="English">
</video>

<!-- ✅ Audio with transcript -->
<audio controls>
  <source src="instructions.mp3" type="audio/mpeg">
</audio>
<p><a href="instructions-transcript.txt">Read transcript</a></p>
```

### 9. Testing & Validation

#### Automated Tools

```bash
# Install accessibility testing gems
bundle add axe-core-rails erblint-accessibility

# Run accessibility checks in specs
bundle exec rspec spec/system --format documentation

# Use Pa11y for integration testing
npm install -g pa11y-ci
```

#### Manual Testing

1. **Keyboard Navigation**: Navigate entire site with Tab, Shift+Tab, Enter, Space, Escape
2. **Screen Reader**: Test with NVDA (Windows) or VoiceOver (Mac)
3. **Zoom**: Test at 200% zoom level
4. **Color Blindness**: Use simulator tools to test color relationships
5. **Contrast**: Use WebAIM Color Contrast Checker

#### Browser Extensions

- WAVE: Web Accessibility Evaluation Tool
- Lighthouse (Chrome DevTools)
- Axe DevTools
- Screen Reader: NVDA (free), JAWS (paid)

### 10. Common Issues & Fixes

| Issue | Fix | WCAG Criterion |
| ------- | ----- | ----------------- |
| No alt text on images | Add descriptive alt text or `alt=""` | 1.1.1 Non-text Content |
| Poor color contrast | Increase contrast ratio to 4.5:1+ | 1.4.3 Contrast (Minimum) |
| No focus indicator | Add visible `outline` or `box-shadow` | 2.4.7 Focus Visible |
| Keyboard trap | Ensure Tab key always progresses forward | 2.1.1 Keyboard |
| Form error invisible | Add role="alert" and aria-live="polite" | 3.3.4 Error Prevention |
| Time limits | Provide way to extend or disable | 2.2.1 Timing Adjustable |
| Motion/animation | Provide option to disable | 2.3.3 Animation from Interactions |
| PDFs inaccessible | Use tagged PDFs with proper structure | 1.3.1 Info and Relationships |

## Pre-Commit Accessibility Checks

Before committing, verify:

```bash
# Run accessibility tests
bundle exec rspec spec/system --tag accessibility

# Check HTML validity
bundle exec erblint --lint-all app/views/

# Use Pa11y for page audit
pa11y-ci --config .pa11y-ci-config.json

# Manual checklist
- [ ] All images have alt text or are marked decorative
- [ ] All buttons/links are keyboard accessible
- [ ] Focus indicators are visible throughout
- [ ] Color is not the only way to convey information
- [ ] Form labels are associated with inputs
- [ ] ARIA is only used when necessary (semantic HTML first)
- [ ] Page tested at 200% zoom
- [ ] Page tested with keyboard only
```

## Resources

### WCAG 2.1 Documentation

- <https://www.w3.org/WAI/WCAG21/quickref/> - Quick reference guide
- <https://www.w3.org/WAI/WCAG21/Understanding/> - Technical details

### Tools & Testing

- <https://webaim.org/> - Web Accessibility In Mind
- <https://www.chromevox.com/> - ChromeVox screen reader
- <https://wave.webaim.org/> - WAVE evaluation tool
- <https://www.tpgi.com/color-contrast-checker/> - Color contrast checker

### Learning Resources

- <https://www.a11y-101.com/> - Accessibility 101
- <https://www.deque.com/blog/> - Deque accessibility blog
- <https://accessible-components.com/> - Accessible component patterns

## Team Responsibilities

### All Developers

- Write semantic HTML
- Test features with keyboard
- Ensure color has sufficient contrast
- Add alt text to images
- Never remove focus indicators

### Design Team

- Design with accessibility from the start
- Test color palettes for contrast
- Ensure icons have labels
- Provide captions for videos

### QA

- Test with assistive technologies
- Verify keyboard navigation
- Check at multiple zoom levels
- Validate against WCAG criteria

### Accessibility Champion

- Review accessibility in code reviews
- Keep team trained on standards
- Research new tools and techniques
- Champion accessibility culture
