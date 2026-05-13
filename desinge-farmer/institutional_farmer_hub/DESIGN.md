---
name: Institutional Farmer Hub
colors:
  surface: '#f8f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f8f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3c4a3c'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6c7b6a'
  outline-variant: '#bbcbb8'
  surface-tint: '#006e2a'
  primary: '#006e2a'
  on-primary: '#ffffff'
  primary-container: '#00c853'
  on-primary-container: '#004c1b'
  inverse-primary: '#3ce36a'
  secondary: '#2a6b2c'
  on-secondary: '#ffffff'
  secondary-container: '#acf4a4'
  on-secondary-container: '#307231'
  tertiary: '#004ee8'
  on-tertiary: '#ffffff'
  tertiary-container: '#93a9ff'
  on-tertiary-container: '#0035a5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#69ff87'
  primary-fixed-dim: '#3ce36a'
  on-primary-fixed: '#002108'
  on-primary-fixed-variant: '#00531e'
  secondary-fixed: '#acf4a4'
  secondary-fixed-dim: '#91d78a'
  on-secondary-fixed: '#002203'
  on-secondary-fixed-variant: '#0c5216'
  tertiary-fixed: '#dce1ff'
  tertiary-fixed-dim: '#b6c4ff'
  on-tertiary-fixed: '#001550'
  on-tertiary-fixed-variant: '#003ab3'
  background: '#f8f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Geist
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Geist
    fontSize: 18px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
  data-mono:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  gutter: 16px
  section-gap: 32px
  stack-compact: 8px
  stack-default: 16px
---

## Brand & Style

The visual identity of this design system is rooted in authority, reliability, and precision. It serves as a digital ledger for agricultural management, requiring an "official" tone that feels government-certified and institutionally backed. The aesthetic avoids consumer-facing trends in favor of a **Corporate Modern** style with **Minimalist** leanings—prioritizing function over form.

The brand personality is steady and industrious. It evokes a sense of growth through the strategic use of emerald green, balanced against a rigid, structured environment of soft greys and crisp whites. High information density is handled through clear grouping and a systematic approach to borders, ensuring the user feels in control of complex data sets.

## Colors

The palette is designed to simulate a professional ledger or administrative portal. 

- **Primary Emerald (#00C853):** Used purposefully for brand presence, primary actions, and "verified" status indicators. It represents vitality and official approval.
- **Surface & Backgrounds:** The application uses a "Paper White" (#FFFFFF) for main content areas and "Soft Slate" (#F5F7F9) for page backgrounds and sidebar containers to create structural contrast without using shadows.
- **Accents:** A deep Forest Green (#1B5E20) is utilized for high-contrast text or dark-mode headers to maintain readability.
- **Functional Greys:** Borders and dividers utilize a consistent palette of cool greys to define information boundaries without cluttering the visual field.

## Typography

The typography system relies exclusively on **Geist**, leveraging its technical, monospaced-influenced clarity to handle dense tabular data and institutional messaging. 

- **Data Legibility:** For numerical values, harvest yields, or coordinates, Geist provides the necessary precision and alignment.
- **Hierarchy:** We use semi-bold weights for headlines to establish clear section breaks. 
- **Labels:** Small caps or uppercase labels are used for metadata to distinguish them from actionable body text.
- **Readability:** Line heights are kept generous (1.5 - 1.6) for body text to reduce eye strain during long-form data entry or auditing tasks.

## Layout & Spacing

The layout follows a **Fixed-Fluid Hybrid Grid**. On desktop, the sidebar navigation is fixed, while the main content area utilizes a 12-column fluid grid that caps at a maximum width of 1440px to ensure data columns do not become overextended.

- **Rhythm:** A 4px baseline grid ensures vertical consistency.
- **Information Grouping:** Content is grouped into "cells" or "modules" defined by 1px borders rather than negative space alone.
- **Density:** Padding within components is kept tight (12px - 16px) to allow more information to be visible above the fold, mimicking the efficiency of a physical ledger or spreadsheet.
- **Breakpoints:** 
  - Mobile (<600px): Single column, 16px margins.
  - Tablet (600px - 1024px): 6-column grid, 20px margins.
  - Desktop (>1024px): 12-column grid, 24px margins.

## Elevation & Depth

This design system rejects traditional shadows and blurred depth. Instead, it utilizes **Tonal Layering and Defined Borders**.

- **Flat Hierarchy:** Hierarchy is communicated through surface color shifts (e.g., a light grey background with white cards) and 1px solid borders (#E0E4E8).
- **Active State:** Depth is signaled by shifting the background color of an element (e.g., a button becomes slightly darker on press) or adding a 2px high-contrast border.
- **No Diffusion:** Do not use drop shadows. If an element must "float" (like a modal), use a thick 2px border with a high-contrast neutral color to separate it from the background layer.

## Shapes

The shape language is **Soft (0.25rem)**. This slight rounding prevents the UI from feeling overly aggressive or "brutalist," maintaining a professional and approachable government-modern feel while retaining the structure of a grid-based system.

- **Standard Elements:** Inputs, buttons, and small cards use a 4px (0.25rem) radius.
- **Large Containers:** Dashboard widgets or main content panels may use up to 8px (0.5rem) to subtly distinguish them from smaller UI components.
- **Interactive States:** Focus states should follow the 4px radius with an additional 2px offset ring for accessibility.

## Components

### Buttons
- **Primary:** Solid Emerald Green (#00C853) with white Geist Medium text. Square edges with 4px radius.
- **Secondary:** White background with a 1px border of Emerald Green.
- **Ghost:** Transparent background with Grey text, used for tertiary actions like "Cancel."

### Inputs & Forms
- **Standard Field:** White background, 1px grey border, 4px radius. On focus, the border thickens to 2px Emerald Green.
- **Labels:** Always positioned above the field in Label-MD typography.
- **Validation:** Error states use a 1px Red border and a small error icon.

### Data Tables (The Core Component)
- **Header:** Soft grey background (#F5F7F9) with uppercase Geist labels.
- **Rows:** White background with 1px bottom borders. High contrast on hover (Light Grey).
- **Cells:** High-density padding (8px vertical).

### Chips & Tags
- **Status Tags:** Rectangular with a 2px radius. Use subtle background tints (e.g., Light Green background for "Active" status) with dark green text.
- **Dismissible Chips:** Grey background with a clear 'X' icon for filter management.

### Cards & Modules
- No shadows. Use a 1px solid border (#E0E4E8). Header areas within cards should be separated by a horizontal rule to reinforce the ledger feel.

### Alerts
- Full-width banners or inline blocks. Use solid left-border accents (4px width) in the status color (Green for Success, Red for Alert) to draw the eye without being overly decorative.