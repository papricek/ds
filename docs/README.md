# Design System Showcase

`index.html` is the showcase served on GitHub Pages (Settings → Pages → `main`, `/docs`).
Open it locally straight from disk.

## Files

- `index.html` — the page: components, then patterns and whole pages copied from the apps
- `css/ds.css` — Bootstrap 5.3 + every component in this repo, **compiled** from the SCSS (`src/ds.scss`)
- `css/apps.css` — the apps' own page styles, **compiled** from the app checkouts (`src/apps.scss`),
  each app scoped under `.AppPage--<app>`
- `css/showcase.css` — hand-written: the showcase's own chrome, the app page frames, and the mock
  components of the older mockup sections (marked "mockup · … not in ds/" on the page)
- `build.sh` — rebuilds `css/ds.css` and `css/apps.css`

## Updating

After changing a component (any `*.scss` in the repo root):

```sh
docs/build.sh
```

`css/apps.css` needs local checkouts of the apps (`VOLTLINK_DIR`, `LITELINK_DIR`, default
`~/Work/voltlink` and `~/Work/litelink`). Rebuild it when a page style an app section uses changes.
The build fetches Bootstrap once into `docs/.cache/` (ignored) and runs Dart Sass through `npx`.

Never edit the compiled CSS by hand — it is overwritten on the next build.

## App pages on the showcase

The "Patterns from the apps" and "App pages" sections are the apps' real rendered markup with invented
sample data. Their page-level blocks (e.g. voltlink `.Cockpit`, `.Ledger`, `.CoverageGantt`) stay
app-local — they live in the app, not in `ds/`; each demo names the SCSS file it comes from.
When a page changes in the app, copy the new markup over and rerun `build.sh`.
