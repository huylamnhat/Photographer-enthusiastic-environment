---
version: alpha
name: Warm Paper Lab
description: A flat, warm, dense admin console for film lab managers. Off-white paper surfaces, hairline borders, one amber accent, one type family. No gradients, no glass, no decoration.
colors:
  primary: "#A9511C"
  primary-hover: "#8C3F12"
  on-primary: "#FFFFFF"
  secondary: "#4A6B5D"
  on-secondary: "#FFFFFF"
  surface: "#FAF8F4"
  surface-raised: "#FFFFFF"
  surface-sunken: "#F2EFE9"
  outline: "#E3DFD7"
  ink: "#1F1C18"
  ink-muted: "#5F5A52"
  success: "#166534"
  success-bg: "#DCFCE7"
  warning: "#92400E"
  warning-bg: "#FEF3C7"
  danger: "#991B1B"
  danger-bg: "#FEE2E2"
  neutral: "#374151"
  neutral-bg: "#F1EFEA"
typography:
  page-title:
    fontFamily: IBM Plex Sans
    fontSize: 26px
    fontWeight: 600
    lineHeight: 1.25
  section-heading:
    fontFamily: IBM Plex Sans
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.3
  card-title:
    fontFamily: IBM Plex Sans
    fontSize: 15px
    fontWeight: 600
    lineHeight: 1.4
  body:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
  table-cell:
    fontFamily: IBM Plex Sans
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.5
  caption:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
  label-caps:
    fontFamily: IBM Plex Sans
    fontSize: 11px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0.06em
  metric:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: 600
    lineHeight: 1.1
  data-mono:
    fontFamily: IBM Plex Mono
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
rounded:
  sm: 4px
  md: 8px
  lg: 12px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  2xl: 32px
  3xl: 48px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    height: 36px
    padding: 8px 16px
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
    textColor: "{colors.on-primary}"
  button-secondary:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    height: 36px
    padding: 8px 16px
  input:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    height: 36px
    padding: 8px 12px
  filter-bar:
    backgroundColor: "{colors.surface-sunken}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: 12px
  card:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: 24px
  sidebar:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.ink}"
    width: 256px
  nav-item:
    textColor: "{colors.ink-muted}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    height: 36px
    padding: 0 12px
  nav-item-active:
    backgroundColor: "{colors.surface-sunken}"
    textColor: "{colors.primary}"
  table-header:
    backgroundColor: "{colors.surface-sunken}"
    textColor: "{colors.ink-muted}"
    typography: "{typography.label-caps}"
    height: 40px
  table-row:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.ink}"
    typography: "{typography.table-cell}"
    height: 56px
  metric-value:
    textColor: "{colors.ink}"
    typography: "{typography.metric}"
  chip-success:
    backgroundColor: "{colors.success-bg}"
    textColor: "{colors.success}"
    typography: "{typography.caption}"
    rounded: "{rounded.sm}"
    padding: 2px 8px
  chip-warning:
    backgroundColor: "{colors.warning-bg}"
    textColor: "{colors.warning}"
    typography: "{typography.caption}"
    rounded: "{rounded.sm}"
    padding: 2px 8px
  chip-danger:
    backgroundColor: "{colors.danger-bg}"
    textColor: "{colors.danger}"
    typography: "{typography.caption}"
    rounded: "{rounded.sm}"
    padding: 2px 8px
  chip-neutral:
    backgroundColor: "{colors.neutral-bg}"
    textColor: "{colors.neutral}"
    typography: "{typography.caption}"
    rounded: "{rounded.sm}"
    padding: 2px 8px
  checkbox-checked:
    backgroundColor: "{colors.secondary}"
    textColor: "{colors.on-secondary}"
    rounded: "{rounded.sm}"
    size: 16px
---

## Overview

An admin console for managers at film labs. Sessions run long and the screens are mostly tables, queues and verification grids, so the interface is built for scanning, not for first impressions. Think of a printed ledger on warm paper: flat surfaces, thin rules, one accent color, one type family.

The warmth comes only from flat warm fills (off-white paper, warm gray, amber). There are no gradients, no grain, no glass and no glow anywhere in the product.

UI copy is in Vietnamese. This specification is in English.

## Colors

- **Primary (#A9511C):** Darkened film-box amber. It is the only accent. Use it for the single main action in a view, the active navigation label, and the keyboard focus ring. Text on it is white (#FFFFFF), at roughly 5:1 contrast. The brighter amber #D97736 is not used for filled buttons because white text on it fails AA.
- **Primary hover (#8C3F12):** Fill for the pressed and hovered primary button.
- **Secondary (#4A6B5D):** Sage. Used for checked checkboxes, selected rows and confirmation marks, never as a second brand color.
- **Surface (#FAF8F4):** Page background. It is a warm off-white. Do not use a cool or lavender-tinted gray such as #F9F9FC.
- **Surface raised (#FFFFFF):** Cards, tables, sidebar, modals. White appears only on raised elements, never as the page background.
- **Surface sunken (#F2EFE9):** Filter bars, table header rows, active nav item, secondary input areas.
- **Outline (#E3DFD7):** The only border color. 1px hairlines.
- **Ink (#1F1C18) and ink-muted (#5F5A52):** Primary and secondary text. Warm near-black instead of pure black.
- **Status colors:** Each status is a dark text color on a pale tint of the same hue: success, warning, danger, neutral. Always pair color with a text label, never color alone.

Rules:
- Flat fills only. No gradients on backgrounds, buttons, text or charts.
- Light theme only in this version. If a dark theme is added later, every text pair must reach 4.5:1 and every border 3:1, with no gray text on gray surfaces.

## Typography

One family: **IBM Plex Sans** for all interface text, **IBM Plex Mono** for data such as serial numbers, order IDs and timestamps. Both support the full Vietnamese character set. Test every screen with strings like "Nguyễn Thị Ánh" and "Quận Bình Thạnh" so stacked diacritics are not clipped.

- Hierarchy comes from size and weight only. No serif face, no italic accents, no second display font.
- Use tabular numerals (font-variant-numeric: tabular-nums) in tables and metrics so columns align.
- Table headers use label-caps. Keep them to one or two words so stacked Vietnamese diacritics stay legible.
- Page title 26px, section heading 18px, card title 15px, body 14px, table cell 13px, caption 12px.

## Layout

A 4px base grid. Every margin, padding and gap uses a spacing token (4, 8, 12, 16, 24, 32, 48). Do not use values outside this scale.

- Sidebar: 256px, fixed, left. Content area: max width 1280px, 12 columns, 24px gap.
- Card padding: 24px. Table header row: 40px. Table body rows: 56px.
- Page header: title on the left, actions on the right. No eyebrow badge or tag above a page title.
- Metric areas are not a row of identical boxes. Give the most important number more width than the others and let the rest sit in a plain list or a single bordered panel.

## Elevation & Depth

Flat. Depth comes from surface tone (surface, then surface-raised) and a 1px outline.

- Cards and tables: no shadow at rest.
- Menus, popovers and modals are the only elements with a shadow: 0 8px 24px rgba(31, 28, 24, 0.12).
- No blur, no backdrop-filter, no translucent panels.

## Shapes

Three radii only: 4px for chips, checkboxes and thumbnails; 8px for buttons, inputs and the filter bar; 12px for cards and modals. No fully rounded pills.

- Borders are always 1px in the outline color. A card never has a colored border, colored left stripe or colored top edge. Status is shown by a chip inside the card.
- Focus ring: 2px primary with a 2px offset, on every interactive element.

## Components

- **Sidebar and header:** Sidebar items are text labels with an optional count, no leading icons. Header holds breadcrumb, global search, notifications and one primary action. Notification count is a number on the bell, not a colored dot with a glow.
- **Buttons:** One filled primary button per view at most. Everything else is the secondary button or a text link. Hover and pressed states change the fill instantly with no fade.
- **Icons:** Use an icon only where the symbol is universally understood (search, close, upload, download, notifications, more actions) and always one per control. Do not place icons in front of headings, card titles, list items or table headers. Draw them from a single set at 16px with a consistent stroke.
- **Cards:** surface-raised, 1px outline, 12px radius, 24px padding, no shadow. Do not stack card inside card.
- **Metrics:** A large number, a plain label, and a delta written as text, for example "+3 so với tuần trước". No icon tile beside the number.
- **Tables:** sunken header row with label-caps text, 1px row dividers, 56px rows, Lab avatar or initials at 32px, actions as short text buttons. Numeric columns are right-aligned with tabular numerals.
- **Status chips:** 4px radius, caption text, text label always present, no icon. Colors map as: active or approved is success, waiting for review is warning, locked or disputed is danger, everything else is neutral.
- **Verification grid:** Images at 4:3 or 16:9 with 4px corners, capture time and camera serial underneath in data-mono, and a checkbox to confirm the quality check.
- **Using shadcn/ui or any component kit:** override the defaults before building screens. Replace the stock zinc or slate neutrals with the warm tokens above, set the radius scale to 4/8/12, set table density to the row heights above, and restyle focus rings. No component ships at its default look.
- **Motion:** None on scroll, none following the cursor, no hover glow, no decorative entrance animation. The only transitions allowed are functional ones such as a menu opening or a toast appearing, 120ms or less. Respect prefers-reduced-motion.

## Do's and Don'ts

Do:
- Use primary amber for one main action per view.
- Use only the spacing, radius and type tokens defined here.
- Pair every status color with a text label.
- Write labels as short verbs: "Duyệt", "Từ chối", "Yêu cầu bổ sung ảnh".
- State facts in empty and error messages: "Chưa có hồ sơ nào chờ duyệt." and "Không lưu được. Kiểm tra kết nối rồi thử lại."

Don't (these are the patterns that make a UI look auto-generated):
- No purple-to-blue gradient, no gradient text, no grain over a gradient.
- No glassmorphism or translucent cards.
- No emojis in headings or labels.
- No Inter as the main face, no Space Grotesk, no Instrument Serif, no serif italic accents.
- No colored-border cards.
- No row of three identical icon-in-a-box cards.
- No badge or pill above a headline.
- No icons on every item, and no untouched shadcn/ui components.
- No fade-in on scroll, no cursor-following beam, no buttons that fade on hover.
- No inconsistent spacing: only the spacing tokens.
- No low-contrast dark mode.
- No em dashes in UI text. Use a period, comma or colon instead.
- No buzzword copy such as "seamless", "powerful", "elevate", "unlock", "next-generation", "all-in-one". Say what the screen does and what the button does.