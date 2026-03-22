# UI Verification Protocol (Playwright MCP + Browser Use)

> This protocol is MANDATORY after any visual change. Claude executes it automatically.
> The user sees only screenshots and plain-language summaries.

---

## 1. Visual Verification Trigger

### Automatically activate when ANY of these files change:
- `.tsx`, `.jsx`, `.vue`, `.svelte` (components)
- `.html`, `.ejs`, `.hbs`, `.pug` (templates)
- `.css`, `.scss`, `.sass`, `.less`, `.styl` (stylesheets)
- `.module.css`, `.module.scss` (CSS modules)
- `tailwind.config.*`, `globals.css`, `theme.*` (global styles)
- Any file importing/using CSS-in-JS (`styled-components`, `emotion`, etc.)
- Layout files (`layout.tsx`, `_app.tsx`, `+layout.svelte`, etc.)
- Any image/icon/font asset change

---

## 2. Visual Verification Sequence

Execute this exact sequence after every visual change:

### Step 1: Ensure Dev Server is Running
```
- Check if dev server is already running (port 3000, 5173, 8080, etc.)
- If not running, start it in background
- Wait for server to be ready (check with network request)
- If server fails to start, diagnose and fix before proceeding
```

### Step 2: Navigate to Affected Page
```
Tool: mcp__playwright__browser_navigate
- Navigate to the page that was modified
- If multiple pages affected, check each one
- Wait for full page load (no loading spinners)
```

### Step 3: Desktop Screenshot (1440x900)
```
Tool: mcp__playwright__browser_resize → width: 1440, height: 900
Tool: mcp__playwright__browser_take_screenshot
- Full page screenshot
- Evaluate: layout, spacing, alignment, colors, typography
```

### Step 4: Mobile Screenshot (375x812)
```
Tool: mcp__playwright__browser_resize → width: 375, height: 812
Tool: mcp__playwright__browser_take_screenshot
- Check: no horizontal scroll, readable text, touch-friendly buttons
- Check: navigation is accessible (hamburger menu, bottom nav, etc.)
- Check: images scale properly, no overflow
```

### Step 5: Tablet Screenshot (768x1024)
```
Tool: mcp__playwright__browser_resize → width: 768, height: 1024
Tool: mcp__playwright__browser_take_screenshot
- Check: layout adapts properly (not just stretched mobile or squished desktop)
- Check: grid layouts reflow correctly
- Check: sidebar behavior (collapsed vs visible)
```

### Step 6: Accessibility Snapshot
```
Tool: mcp__playwright__browser_snapshot
- Verify DOM structure and accessibility tree
- Check for missing labels, roles, or aria attributes
- Identify any accessibility violations
```

### Step 7: Present to User
```
- Show desktop + mobile screenshots side by side (or sequentially)
- Provide brief plain-language description of what changed
- Ask: "ნახე შედეგი — კარგად გამოიყურება?"
- Wait for user approval before committing
```

---

## 3. Accessibility Checks

### Image Accessibility
- Every `<img>` must have an `alt` attribute
- Decorative images: `alt=""`
- Informative images: descriptive alt text
- No `alt="image"` or `alt="photo"` generic placeholders

### Heading Hierarchy
```
✅ Correct: h1 → h2 → h3 → h2 → h3
❌ Wrong:   h1 → h3 (skipped h2)
❌ Wrong:   h2 → h1 (h1 should come first)
```
- Only one `<h1>` per page
- Headings must not skip levels
- Use `mcp__playwright__browser_snapshot` to verify heading tree

### Color Contrast
- Text on backgrounds must meet WCAG AA minimum:
  - Normal text: 4.5:1 contrast ratio
  - Large text (18px+ or 14px+ bold): 3:1 contrast ratio
- Do not use color alone to convey information
- Check that links are distinguishable from regular text

### Keyboard Navigation
```
Tool: mcp__playwright__browser_press_key → key: "Tab"
- Tab through all interactive elements
- Verify visible focus indicators on every focusable element
- Verify logical tab order (left→right, top→bottom)
- Verify Enter/Space activates buttons and links
- Verify Escape closes modals and dropdowns
```

### Focus Management
- Modals must trap focus inside when open
- After closing modal, focus returns to trigger element
- Skip-to-content link exists (for screen readers)
- No focus traps outside of modals

---

## 4. Responsive Design Checks

### Viewport Breakpoints to Test:

| Device | Width | Height | Check Focus |
|--------|-------|--------|-------------|
| iPhone SE | 375 | 667 | Smallest common phone |
| iPhone 14 Pro | 393 | 852 | Standard modern phone |
| iPad | 768 | 1024 | Tablet portrait |
| iPad Landscape | 1024 | 768 | Tablet landscape |
| Laptop | 1440 | 900 | Standard desktop |
| Wide Monitor | 1920 | 1080 | Large desktop |

### Minimum Required Checks (375, 768, 1440):
These three viewports are always checked. The others are checked when layout complexity warrants it.

### What to Verify at Each Breakpoint:
- **No horizontal scrollbar** (content fits within viewport width)
- **Text is readable** (minimum 14px on mobile, 16px on desktop)
- **Touch targets** are at least 44x44px on mobile
- **Navigation** is accessible (visible menu or working hamburger)
- **Images** scale proportionally (no stretching or cropping)
- **Grid/flex layouts** reflow properly (3-col → 2-col → 1-col)
- **Tables** are scrollable or reformatted on mobile
- **Modals/popups** fit within the viewport
- **Fixed/sticky elements** don't cover content

### Common Responsive Issues to Flag:
```
❌ Text overflows container (white-space: nowrap without overflow handling)
❌ Images extend beyond viewport (missing max-width: 100%)
❌ Fixed-width elements on mobile (width: 500px instead of max-width)
❌ Tiny touch targets (buttons/links smaller than 44px)
❌ Unreadable text (font-size < 14px on mobile)
❌ Hidden content with no way to access it
❌ Overlapping elements
```

---

## 5. Performance Checks

### Page Load Metrics:
```
Tool: mcp__playwright__browser_evaluate
Script: performance measurement
```

| Metric | Target | Critical |
|--------|--------|----------|
| Page Load | < 3s | > 5s |
| Largest Contentful Paint (LCP) | < 2.5s | > 4s |
| First Input Delay (FID) | < 100ms | > 300ms |
| Cumulative Layout Shift (CLS) | < 0.1 | > 0.25 |
| Time to Interactive (TTI) | < 3.5s | > 7s |

### Console Error Check:
```
Tool: mcp__playwright__browser_console_messages
- Zero errors expected
- Warnings are acceptable but should be noted
- If errors found → investigate and fix before showing to user
```

### Network Request Check:
```
Tool: mcp__playwright__browser_network_requests
- No 4xx or 5xx responses
- No failed resource loads (broken images, missing CSS/JS)
- No mixed content warnings (HTTP resources on HTTPS page)
- Flag unusually large responses (> 1MB for single resources)
```

### Resource Loading:
- All images load correctly (no broken image icons)
- All fonts load (no FOUT/FOIT beyond acceptable threshold)
- All scripts execute without errors
- All stylesheets apply correctly

---

## 6. Interactive Element Verification

### Buttons:
```
Tool: mcp__playwright__browser_click
- Every visible button must be clickable
- Disabled buttons must not trigger actions
- Loading states must show feedback (spinner, disabled state)
- After click: verify expected action occurred
```

### Forms:
```
Tool: mcp__playwright__browser_fill_form / mcp__playwright__browser_type
- Fill all fields with valid test data
- Submit the form
- Verify success feedback (toast, redirect, message)
- Test with empty required fields → verify error messages
- Test with invalid data (wrong email format, etc.) → verify validation
```

### Links:
```
Tool: mcp__playwright__browser_click / mcp__playwright__browser_navigate
- All internal links navigate to correct pages
- External links open (verify href exists)
- No dead links (404 pages)
- Back button works after navigation
```

### Dropdowns and Selects:
```
Tool: mcp__playwright__browser_select_option / mcp__playwright__browser_click
- All options are selectable
- Selected value is displayed correctly
- Multi-select works if applicable
```

### Modals and Dialogs:
```
- Open modal → verify content displays
- Close with X button → modal disappears
- Close with overlay click → modal disappears
- Close with Escape key → modal disappears
- Verify background scroll is locked when modal is open
```

---

## 7. Before/After Comparison

### When Modifying Existing UI:
```
1. BEFORE making changes:
   - Take "before" screenshot at all 3 viewports
   - Save accessibility snapshot

2. Make the code changes

3. AFTER changes:
   - Take "after" screenshot at all 3 viewports
   - Save accessibility snapshot

4. Compare:
   - Layout differences (intentional vs unintentional)
   - Missing elements (something disappeared that shouldn't have)
   - New issues introduced (overflow, misalignment)

5. Show both to user:
   - "Here's how it looked before → here's how it looks now"
   - Highlight what changed
```

---

## 8. Dark Mode / Theme Verification

### If Project Has Theme Support:
- Test in light mode (default screenshot)
- Test in dark mode (if available)
- Verify: text is readable in both modes
- Verify: images/icons are visible in both modes
- Verify: form inputs are styled in both modes
- Verify: no hard-coded colors that break in dark mode

### Toggle Method:
```
Tool: mcp__playwright__browser_evaluate
Script: document.documentElement.classList.toggle('dark')
— or —
Script: document.documentElement.setAttribute('data-theme', 'dark')
```

---

## 9. Error State Verification

### Test These Error States Visually:
- Empty states (no data to display)
- Loading states (skeleton screens, spinners)
- Error states (API failure, network error)
- 404 page exists and looks correct
- Form validation error messages are visible and clear
- Session expired / auth error handling

### How to Trigger:
```
- Empty state: Ensure no data exists / mock empty response
- Loading: Check if skeleton/spinner shows during load
- Error: Temporarily break an API call, take screenshot, then fix
- 404: Navigate to a non-existent route
```

---

## 10. Quick Checklist (Claude's Internal Reference)

After every visual change, mentally check:

```
□ Dev server running
□ Page loads without errors
□ Desktop screenshot taken and evaluated
□ Mobile screenshot taken and evaluated
□ No console errors
□ No broken resources (images, fonts, scripts)
□ All buttons/links clickable
□ Forms work (if applicable)
□ Text is readable at all sizes
□ No layout overflow
□ Accessibility tree is valid
□ Screenshots shown to user
□ User approval received
```

> This checklist is for Claude's internal use only. Never show it to the user.
> Just do the work and show the results.
