# Wattlink Design System

Design system for the Wattlink family of energy management applications. Dark-themed, SCSS-based component library following BEM conventions.

**[Live Showcase](https://papricek.github.io/ds/)**

## Components

- **Buttons** - Primary, secondary, success, danger, warning, info variants with outlined, rounded, and size modifiers
- **Badges** - Status indicators with semantic colors, sizes, and pill variants
- **Alerts** - Contextual feedback messages
- **Cards** - Content containers with metrics, accent variants, and no-data states
- **Tables** - Data tables with row states, cell formatting, sortable headers, badges, and footer
- **Forms** - Inputs, labels, granularity buttons, role selectors, checkbox groups, filter labels
- **Modals** - Dialog overlays with payment details and form combinations
- **Tabs** - Primary and secondary tab navigation
- **Navigation** - Horizontal and vertical navigation with dividers
- **Pagination** - Page controls with active and disabled states
- **Icons** - Circular icon containers in 4 sizes with 7 semantic color variants
- **Stat Cards** - Dashboard metric cards with compact and border variants
- **Status Buttons** - Process state indicators (pending, running, success, error)
- **Box** - Content boxes with items, icons, actions, compact/supercompact/accent variants, and a loading overlay (`.Box__overlay` shown when container has `.is-loading`)
- **Listings** - List items with status indicators, badges, actions, and empty states
- **Filter Panel** - Sidebar filters with toggles, groups, and search
- **Flash toasts** - Floating dismissible notifications (`.FlashStack` > `.Flash--success|warning|danger|info`, in `alert.scss`)
- **AI assistant** - `AssistantLauncher` (idle / thinking / attention / unread / open), `AssistantPanel` (docked, floating, mobile sheet), `AssistantChat` with messages, action cards (`AssistantCard`), composer, history and a full-page `--expanded` variant (`assistant.scss`)
- **Form helpers** - `.Form__btn--primary` / `--ghost` compact action buttons, `.ToggleField` (label + hint + switch), `.IconPicker` (radio icon tiles)
- **Table variants** - `.Table--panel` and `.Table--surface` (inside `.TableSurface`), `.Table__code`
- **Chart editor pieces** - `Chip`, `Segment`, `Swatch`, `Skeleton`, `InlineTitle`, `SeriesRow`, `PickerRow`, `SeriesPicker`, plus `--series-1…8` palette tokens
- **App patterns and page blocks** (moved from voltlink and litelink, not imported by any app yet):
  - filtering - `ExpenseState` + `FilterChip` (filter state bar), `ExpenseOverview__layout` (collapsible filter sidebar)
  - listings - `CategoryIcon`/`CategoryDot`/`GroupHeader__divider`, `DocumentList`/`DocumentGroup`/`DocumentRow`, `BuildingListing`, `UserList`/`UserRow`/`ListRow` (`list_row.scss`), `UsersToolbar`/`RoleTabs`/`Filters`
  - overviews - `Dashboard`, `Cockpit` (Přehled tiles), `Matrix` (building matrix), `Prehled` (Air energy overview with `TreeNode` filter), `AppSwitcher`
  - economics - `Ledger`, `LedgerYears`, `LedgerCard`, `PairedBars` (cost table), `CoverageGantt` (invoice coverage)
  - sharing - `AllocationMatrix` + `MatrixCell` (litelink's `.Matrix`, renamed: voltlink owns `.Matrix`), `SharingOverview`/`AddressCard`, `MonthStepper`, `SubTabs`, `StatPill`, `OptiCard`, `EnergyFlow`, `RunDetail`
  - other - `ActionCard`, `ProvozSegmentBar`, `Chip--warning`, `Nav__badge`
- **Other components** - `ChartCard`, `ChartPreview`, `ComparisonCard`, `CoverageBar`, `FormCard`, `SelectableCard`, `Stepper`, `QuickActions`, `CategoryPicker`, `ChipInput`, `ConfidenceMeter`, `AutoBadge`, `PeriodRange`, `FileUpload`, `Calendar`

## Color System

### Brand Colors
- Primary: Orange (`hsla(33, 100%, 61%, 1)`)
- Secondary: Teal (`hsla(169, 47%, 49%, 1)`)
- Accent: Navy Blue (`hsla(240, 93%, 29%, 1)`)
- Dark: Deep Blue (`hsla(240, 75%, 13%, 1)`)

### Semantic Colors
- Success, Warning, Danger, Info

All colors are customizable via CSS custom properties for per-tenant theming.

## Project Structure

```
.
├── docs/                    # Showcase site (GitHub Pages), see docs/README.md
│   ├── build.sh             # Compiles css/ds.css from SCSS
│   ├── css/                 # ds.css (compiled), showcase.css (hand-written)
│   ├── index.html           # Components, app patterns and whole app pages
│   └── logo_white.svg
├── configuration.scss       # CSS variables and theme
├── button.scss              # Button component
├── badge.scss               # Badge component
├── alert.scss               # Alert component
├── card.scss                # Card component
├── table.scss               # Table component
├── form.scss                # Form elements
├── modal.scss               # Modal component
├── tabs.scss                # Tabs component
├── nav.scss                 # Navigation component
├── pagination.scss          # Pagination component
├── icon.scss                # Icon styles
├── stat_card.scss           # Statistics card
├── status_button.scss       # Status button
├── box.scss                 # Box component
├── listing.scss             # Listing component
├── filter_panel.scss        # Filter panel component
├── app.scss                 # Application layout
└── tom_select.scss          # Tom Select overrides
```

## What belongs here

Reusable components and elements, plus the app patterns and page blocks worth sharing across the
suite (filter bar and sidebar, listings, overview tiles, cost ledger, coverage chart…). Each app
imports only the files it uses. Styles only one page needs stay in the app's own stylesheets
(`app/assets/stylesheets/components/`), and an app that wants a component to look
different overrides it in `components/ds_overrides.scss` rather than editing `ds/`.
Changing an existing rule here changes every app, so prefer adding a modifier.

## Usage in Rails

```scss
@import "configuration";
@import "button";
@import "badge";
@import "alert";
@import "card";
@import "table";
@import "form";
// ... other components as needed
```

## BEM Naming Convention

- **Block**: `.Button`, `.Card`, `.Badge`
- **Element**: `.Card__title`, `.Listing__action`
- **Modifier**: `.Button--primary`, `.StatCard--compact`, `.Table__row--success`

## Showcase

`docs/index.html` shows every component, then patterns and whole pages taken from the apps
(Wattlink EnMS, Wattlink Air) with invented data. Its CSS is compiled from this repo, so after
changing a component run `docs/build.sh` (details in `docs/README.md`).

## GitHub Pages

The showcase is served from the `/docs` folder on the `main` branch. To enable:

1. Go to **Settings** > **Pages**
2. Source: `main` branch, `/docs` folder
3. Save

## Browser Support

Modern browsers (Chrome, Firefox, Safari, Edge). Requires CSS custom properties.
