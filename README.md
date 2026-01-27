# Rails Design System

A comprehensive design system for Rails applications featuring modern, accessible components with a dark theme.

## Overview

This design system provides a collection of reusable SCSS components following BEM naming conventions. It includes buttons, badges, alerts, cards, tables, forms, and more.

## Components

- **Buttons** - Multiple variants (primary, secondary, success, danger, warning, info), sizes, and states
- **Badges** - Status indicators with semantic colors and pill variants
- **Alerts** - Contextual feedback messages
- **Cards** - Flexible content containers
- **Tables** - Data tables with hover states and nested content
- **Forms** - Form elements with validation states
- **Navigation** - Navigation components
- **Modals** - Modal dialogs
- **And more...**

## Color System

The design system uses a comprehensive color palette with CSS custom properties:

### Brand Colors
- Primary: Orange (`hsla(33, 100%, 61%, 1)`)
- Secondary: Teal (`hsla(169, 47%, 49%, 1)`)
- Accent: Navy Blue (`hsla(240, 93%, 29%, 1)`)
- Dark: Deep Blue (`hsla(240, 75%, 13%, 1)`)

### Semantic Colors
- Success: Green
- Warning: Orange
- Danger: Red
- Info: Blue

All colors can be customized via CSS custom properties for easy theming.

## Documentation Site

A live showcase of all components is available in the `/docs` directory. View it at:
`https://<your-username>.github.io/<repository-name>/`

## GitHub Pages Setup

### Option 1: Public Repository (Free)

1. Make your repository public in GitHub settings
2. Go to **Settings** → **Pages**
3. Under **Source**:
   - Branch: `main`
   - Folder: `/docs`
4. Click **Save**
5. Your site will be live at `https://<username>.github.io/<repository>/`

### Option 2: Private Repository (Requires GitHub Pro/Team/Enterprise)

1. Keep your repository private
2. Follow the same steps as Option 1
3. GitHub Pages for private repos requires a paid plan

## Project Structure

```
.
├── docs/                    # Compiled showcase site for GitHub Pages
│   ├── css/
│   │   └── styles.css      # Compiled CSS
│   ├── index.html          # Showcase page
│   └── README.md
├── alert.scss              # Alert component
├── app.scss                # Application layout
├── badge.scss              # Badge component
├── box.scss                # Box component
├── button.scss             # Button component
├── card.scss               # Card component
├── configuration.scss      # CSS variables and theme
├── filter_panel.scss       # Filter panel component
├── form.scss               # Form elements
├── icon.scss               # Icon styles
├── listing.scss            # Listing component
├── modal.scss              # Modal component
├── nav.scss                # Navigation component
├── pagination.scss         # Pagination component
├── stat_card.scss          # Statistics card
├── status_button.scss      # Status button
├── table.scss              # Table component
├── tabs.scss               # Tabs component
└── tom_select.scss         # Tom Select styles
```

## Usage in Rails

Import the SCSS files in your application:

```scss
@import "configuration";
@import "button";
@import "badge";
@import "alert";
@import "card";
@import "table";
@import "form";
// ... other components
```

Or import them individually as needed.

## Updating the Documentation

When you make changes to the SCSS files:

1. Update the corresponding styles in `docs/css/styles.css`
2. Update examples in `docs/index.html` if you add new components or variants
3. Commit and push your changes
4. GitHub Pages will automatically rebuild

## BEM Naming Convention

This design system follows BEM (Block Element Modifier) methodology:

- **Block**: `.Button`, `.Card`, `.Badge`
- **Element**: `.Button__icon`, `.Card__title`
- **Modifier**: `.Button--primary`, `.Badge--success`

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- CSS custom properties required

## License

[Your License Here]
