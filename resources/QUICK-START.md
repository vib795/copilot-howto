# Quick Start - Brand Assets

## Copy Assets to Your Project

```bash
# Copy all resources to your web project
cp -r resources/ /path/to/your/website/

# Or just the favicons for web
cp resources/favicons/* /path/to/your/website/public/
```

## Add to HTML (Copy & Paste)

```html
<!-- Favicons -->
<link rel="icon" type="image/svg+xml" href="/resources/favicons/favicon-32.svg" sizes="32x32">
<link rel="icon" type="image/svg+xml" href="/resources/favicons/favicon-16.svg" sizes="16x16">
<link rel="apple-touch-icon" href="/resources/favicons/favicon-128.svg">
<link rel="icon" type="image/svg+xml" href="/resources/favicons/favicon-256.svg" sizes="256x256">
<meta name="theme-color" content="#000000">
```

## Use in Markdown/Documentation

```markdown
# Copilot How To

![Copilot How To Logo](resources/logos/copilot-howto-logo.svg)

![Icon](resources/icons/copilot-howto-icon.svg)
```

## Recommended Sizes

| Purpose | Size | File |
|---------|------|------|
| Website header | 520×120 | `logos/copilot-howto-logo.svg` |
| App icon | 256×256 | `icons/copilot-howto-icon.svg` |
| Browser tab | 32×32 | `favicons/favicon-32.svg` |
| Mobile home screen | 128×128 | `favicons/favicon-128.svg` |
| Desktop app | 256×256 | `favicons/favicon-256.svg` |
| Small avatar | 64×64 | `favicons/favicon-64.svg` |

## Color Values

```css
/* Use these in your CSS */
--color-primary: #000000;
--color-secondary: #6B7280;
--color-accent: #22C55E;
--color-bg-light: #FFFFFF;
--color-bg-dark: #0A0A0A;
```

## Icon Design Meaning

**Compass with Code Bracket**:
- Compass ring = Navigation, structured learning path
- Green north needle = Direction, progress, guidance
- Black south needle = Grounding, solid foundation
- `>` bracket = Terminal prompt, code, CLI context
- Tick marks = Precision, structured steps

This symbolizes "finding your way through code with clear guidance."

## What to Use Where

### Website
- **Header**: Logo (`logos/copilot-howto-logo.svg`)
- **Favicon**: 32px (`favicons/favicon-32.svg`)
- **Social preview**: Icon (`icons/copilot-howto-icon.svg`)

### GitHub
- **README badge**: Icon (`icons/copilot-howto-icon.svg`) at 64-128px
- **Repository avatar**: Icon (`icons/copilot-howto-icon.svg`)

### Social Media
- **Profile picture**: Icon (`icons/copilot-howto-icon.svg`)
- **Banner**: Logo (`logos/copilot-howto-logo.svg`)
- **Thumbnail**: Icon at 256×256px

### Documentation
- **Chapter headers**: Logo or icon (scaled to fit)
- **Navigation icons**: Favicon (32-64px)

---

See [README.md](README.md) for complete documentation.
