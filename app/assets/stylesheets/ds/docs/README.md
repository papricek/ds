# Design System Documentation

This directory contains the compiled showcase site for the design system.

## Files

- `index.html` - Main showcase page with all component examples
- `css/styles.css` - Compiled CSS from all SCSS source files

## GitHub Pages Setup

To publish this documentation site on GitHub Pages:

1. Go to your repository settings on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select:
   - Branch: `main` (or your default branch)
   - Folder: `/docs`
4. Click **Save**
5. Your site will be published at `https://<username>.github.io/<repository>/`

## Updating the Showcase

When you make changes to the SCSS files in the root directory:

1. Update the corresponding styles in `docs/css/styles.css`
2. Update examples in `docs/index.html` if needed
3. Commit and push the changes
4. GitHub Pages will automatically rebuild and deploy your site

## Local Development

To view the showcase locally, simply open `index.html` in a web browser.

## Source Files

The original SCSS source files are located in the repository root:

- `configuration.scss` - CSS variables and theme configuration
- `button.scss` - Button component styles
- `badge.scss` - Badge component styles
- `alert.scss` - Alert component styles
- `card.scss` - Card component styles
- `table.scss` - Table component styles
- And more...
