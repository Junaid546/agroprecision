---
name: Poultry Management Design System
colors:
  surface: '#f8faf4'
  surface-dim: '#d8dbd5'
  surface-bright: '#f8faf4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4ee'
  surface-container: '#ecefe9'
  surface-container-high: '#e7e9e3'
  surface-container-highest: '#e1e3dd'
  on-surface: '#191c19'
  on-surface-variant: '#404941'
  inverse-surface: '#2e312d'
  inverse-on-surface: '#eff2eb'
  outline: '#717970'
  outline-variant: '#c0c9be'
  surface-tint: '#2e6a41'
  primary: '#003b1b'
  on-primary: '#ffffff'
  primary-container: '#14532d'
  on-primary-container: '#87c695'
  inverse-primary: '#96d5a3'
  secondary: '#855300'
  on-secondary: '#ffffff'
  secondary-container: '#fea619'
  on-secondary-container: '#684000'
  tertiary: '#591d28'
  on-tertiary: '#ffffff'
  tertiary-container: '#75333e'
  on-tertiary-container: '#f79eaa'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f2be'
  primary-fixed-dim: '#96d5a3'
  on-primary-fixed: '#00210d'
  on-primary-fixed-variant: '#12512c'
  secondary-fixed: '#ffddb8'
  secondary-fixed-dim: '#ffb95f'
  on-secondary-fixed: '#2a1700'
  on-secondary-fixed-variant: '#653e00'
  tertiary-fixed: '#ffd9dc'
  tertiary-fixed-dim: '#ffb2bb'
  on-tertiary-fixed: '#3c0613'
  on-tertiary-fixed-variant: '#73323d'
  background: '#f8faf4'
  on-background: '#191c19'
  surface-variant: '#e1e3dd'
typography:
  display-stat:
    fontFamily: Manrope
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 20px
  stack-gap: 16px
  inline-gap: 12px
  card-padding: 20px
  section-margin: 32px
---

## Brand & Style

The design system is engineered for the modern agricultural enterprise, balancing high-end SaaS sophistication with the rugged utility required for field operations. The brand personality is authoritative, dependable, and precision-oriented. 

The aesthetic is rooted in **Minimalism** and **Modern Corporate** styles, drawing inspiration from industry leaders like Stripe and Linear. It utilizes a card-based architecture to organize complex data into digestible units. To ensure efficacy in outdoor farm environments, the design system prioritizes high-contrast ratios and substantial touch targets, evoking an emotional response of control, clarity, and premium craftsmanship.

## Colors

The palette is anchored by a sophisticated **Deep Green**, establishing an immediate connection to agriculture and growth while maintaining a professional SaaS posture. **Amber** serves as the secondary accent, utilized for tactical highlights, warnings, and high-priority indicators. 

The neutral foundation relies on a crisp **Light Gray** background to reduce glare, paired with pure **White** cards to create a clear physical separation of data. High-contrast **Dark Gray** is used for all primary text to ensure maximum legibility under direct sunlight. Success and Danger colors are calibrated for high visibility to signal health and environmental alerts immediately.

## Typography

This design system utilizes a dual-font strategy to balance character with utility. **Manrope** is used for headlines and high-impact statistics, offering a refined, modern geometric feel that commands attention. **Inter** is the workhorse for body copy and UI labels, chosen for its exceptional legibility and systematic performance in data-heavy layouts.

A specialized `display-stat` tier is defined for key metrics (e.g., bird count, temperature, humidity), featuring extra-bold weights and tight letter spacing to ensure these figures are the primary focal point of the dashboard.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile constraints. It uses a 4px baseline rhythm to ensure mathematical harmony across all components. 

Primary containers utilize a **20px side margin** to provide ample breathing room on mobile devices. Vertical spacing between cards is standardized at **16px**, while internal card elements use **12px** for tighter grouping. Large sections are separated by **32px** to create clear visual chapters in the user journey. The "Safe Area" at the bottom of the screen is strictly respected, specifically for the persistent bottom navigation.

## Elevation & Depth

Hierarchy in this design system is achieved through **Ambient Shadows** and tonal layering rather than heavy borders. 

- **Level 0 (Background):** Solid #F8FAFC, the deepest layer.
- **Level 1 (Cards):** Pure white surfaces with a soft, diffused shadow (0px 4px 20px rgba(0, 0, 0, 0.05)). This creates a subtle "lift" from the background.
- **Level 2 (Interactive Elements):** Buttons and active inputs use a slightly more pronounced shadow (0px 8px 24px rgba(20, 83, 45, 0.12)) when using the primary color, suggesting pressability.
- **Level 3 (Modals/Overlays):** Significant depth via high-blur shadows (0px 20px 48px rgba(0, 0, 0, 0.1)) to pull the focus away from the dashboard.

## Shapes

The shape language is defined by generous, friendly **Rounded** corners. Standard containers and cards utilize a **16px to 20px radius**, creating a soft, high-end consumer feel that counteracts the industrial nature of farm data. 

Buttons follow the same radius for consistency, while smaller UI elements like chips or badges utilize a fully rounded (pill-shaped) approach to distinguish them from structural cards.

## Components

### Buttons
- **Primary:** Filled #14532D with white text. 16px padding, 56px minimum height for mobile accessibility.
- **Secondary:** Ghost style with #14532D border or subtle gray background.
- **Status:** Icons inside buttons should be 20px to maintain visual balance.

### Cards
- The central building block. Each card must have a white background, 20px internal padding, and a 16px corner radius. Headlines within cards should use `headline-md`.

### Inputs & Selection
- **Text Fields:** 1px border (#E2E8F0) with a 12px radius. Active state transitions to a 2px Primary Green border.
- **Chips:** Small, rounded pill-shapes used for status (e.g., "Active", "Quarantine"). Text within chips uses `label-bold`.
- **Checkboxes/Radios:** Oversized targets (24x24px) for easy tapping in field conditions.

### Specialized Data Components
- **Metric Group:** A card containing a `display-stat` number, a `label-md` descriptor, and a small sparkline chart or trend indicator.
- **Environmental Gauge:** A semi-circular progress bar for temperature or humidity monitoring.
- **Status List:** High-density rows with 16px vertical padding, separated by subtle #F1F5F9 dividers.