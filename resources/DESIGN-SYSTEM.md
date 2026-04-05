# Copilot How To - Design System

## Visual Identity

### Icon Design Concept: Compass with Code Bracket

The Copilot How To icon uses a **compass with a `>` code bracket** to represent guided navigation through code:

```
     N (green)
     ▲
     │
W ───>─── E     Compass = Guidance/Direction
     │          > Bracket = Code/Terminal/CLI
     ▼
     S (black)
```

This creates:
- **Visual Clarity**: Immediately communicates "code navigation guide"
- **Symbolic Meaning**: Compass = finding your way; `>` = code/terminal
- **Scalability**: Works at any size from 16px to 512px
- **Brand Alignment**: Matches the developer tool aesthetic with minimal palette

---

## Color System

### Palette

| Color | Hex | RGB | Usage |
|-------|-----|-----|-------|
| Black (Primary) | `#000000` | 0, 0, 0 | Main strokes, text, south needle |
| White (Background) | `#FFFFFF` | 255, 255, 255 | Light backgrounds |
| Gray (Secondary) | `#6B7280` | 107, 114, 128 | Minor tick marks, secondary text |
| Bright Green (Accent) | `#22C55E` | 34, 197, 94 | North needle, center dot, accent lines |
| Near Black (Dark BG) | `#0A0A0A` | 10, 10, 10 | Dark mode backgrounds |

### Contrast Ratios (WCAG)

- Black on White: **21:1** AAA
- Gray on White: **4.6:1** AA
- Green on White: **3.2:1** (decorative only, not for text)
- White on Dark: **19.5:1** AAA

### Accent Color Rule

**Bright Green (#22C55E) is reserved for highlights only:**
- Compass north needle
- Center dot
- Accent underlines/borders
- Never as a background color
- Never for body text

---

## Typography

### Logo Font
- **Family**: Inter, SF Pro Display, -apple-system, Segoe UI, sans-serif
- **"Copilot How To"**: 42px, weight 700 (bold), Black
- **"How-To"**: 32px, weight 500 (medium), Gray (#6B7280)
- **Subtitle**: 10px, weight 500, Gray, letter-spacing 1.5px, uppercase

### Interface Font
- **Family**: Inter, SF Pro, system fonts (sans-serif)
- **Weight**: 400-600
- **Style**: Clean, readable

---

## Icon Details

### Compass Specifications

The compass mark is built from these geometric elements:

```
Element             | Stroke/Fill    | Color
--------------------|----------------|------------------
Outer ring          | 3px stroke     | Black / White (dark mode)
North tick          | 2.5px stroke   | Black / White (dark mode)
Other cardinal ticks| 2px stroke     | Gray / White 50% (dark mode)
Intercardinal ticks | 1.5px stroke   | Gray / White 40% (dark mode)
North needle        | filled polygon | #22C55E (always green)
South needle        | filled polygon | Black / White (dark mode)
> bracket           | 3px stroke     | Black / White (dark mode)
Center dot          | filled circle  | #22C55E (always green)
```

### Size Progression

```
16px  → Ring + needles + chevron only (minimal)
32px  → Adds cardinal tick marks
64px  → Adds intercardinal tick marks
128px → Full detail, all elements crisp
256px → Maximum detail, thick strokes
```

---

## Sizing Guidelines

### Logo Sizing

- **Minimum**: 200px width (for web)
- **Recommended**: 520px (native size)
- **Maximum**: Unlimited (vector format)
- **Aspect Ratio**: ~4.3:1 (width:height)

### Icon Sizing

- **Minimum**: 16px (favicon)
- **Recommended**: 64-256px (apps, avatars)
- **Maximum**: Unlimited (vector format)
- **Aspect Ratio**: 1:1 (square)

---

## Spacing & Alignment

### Logo Spacing

```
┌─────────────────────────────────────┐
│                                     │
│        Clear Space Minimum          │
│         (logo height / 2)           │
│                                     │
│    [COMPASS]  Claude                │
│               How-To                │
│                                     │
└─────────────────────────────────────┘
```

### Icon Center Point

All icons center at the midpoint of their canvas:
- 128×128 for 256px canvas
- 64×64 for 128px canvas
- Maintains alignment with other UI elements

---

## Accessibility

### Color Contrast
- All text meets WCAG AA (4.5:1 minimum)
- Green accent is decorative, not informational
- No red-green color dependency

### Scalability
- Vector format ensures clarity at any size
- Geometric shapes remain recognizable at 16px
- Progressive detail based on available size

---

## Application Examples

### Web Header
- Size: 520×120px logo
- File: `logos/copilot-howto-logo.svg`
- Background: White or dark (#0A0A0A)
- Padding: 20px minimum

### App Icon
- Size: 256×256px
- File: `icons/copilot-howto-icon.svg`
- Background: White or dark
- Use: App shortcuts, avatars

### Browser Favicon
- Size: 32px (primary), 16px (fallback)
- File: `favicons/favicon-32.svg`
- Format: SVG for crisp display

### Social Media
- Profile: 256×256px icon
- Banner: 520×120px logo (centered)

### Documentation
- Chapter Headers: Logo scaled to fit
- Section Icons: 64×64px favicon
- Inline: 32×32px favicon

---

## File Format Details

### SVG Structure

All SVG files are flat design:
- No gradients (solid colors only)
- No filter effects (no blur, glow, or shadow)
- Clean stroke and fill geometry
- ViewBox for responsive scaling
- Readable, commented code

### Cross-Browser Compatibility

- Chrome/Edge: Full support
- Firefox: Full support
- Safari: Full support
- iOS Safari: Full support
- All modern browsers: Full support

---

## Customization

### Changing the Accent Color

To create variants with a different accent:

1. Replace all instances of `#22C55E` with your accent color
2. Ensure contrast ratio stays above 3:1 for decorative elements
3. Keep black/white/gray structure unchanged

### Scaling

```css
svg {
  width: 256px;
  height: 256px;
}
```

SVGs scale automatically via viewBox — no transforms needed.

---

## Version Control

Track design changes in git:
- Version SVG files normally (they're text)
- Tag releases with design changes
- Include DESIGN-SYSTEM.md in commits

---

**Last Updated**: February 2026
**Design System Version**: 3.0
