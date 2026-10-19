# Design System Showcase

`index.html` is the showcase served on GitHub Pages (Settings → Pages → `main`, `/docs`).
Open it locally straight from disk.

## Files

- `index.html` — the page: components, then patterns and whole pages copied from the apps
- `css/ds.css` — Bootstrap 5.3 + every component in this repo, **compiled** from the SCSS (`src/ds.scss`)
- `src/app_overrides.scss` — copies of what voltlink and litelink override in ds/ (their
  `components/ds_overrides.scss`), scoped under `.AppPage--<app>` so the app demos look as in the app
- `css/showcase.css` — hand-written: the showcase's own chrome, the app page frames, and the mock
  components of the older mockup sections (marked "mockup · … not in ds/" on the page)
- `build.sh` — rebuilds `css/ds.css`

## Updating

After changing a component (any `*.scss` in the repo root):

```sh
docs/build.sh
```

The build fetches Bootstrap once into `docs/.cache/` (ignored) and runs Dart Sass through `npx`.

Never edit the compiled CSS by hand — it is overwritten on the next build.

## App pages on the showcase

The "Patterns from the apps" and "App pages" sections are the apps' real rendered markup with invented
sample data. Their blocks (e.g. `.Cockpit`, `.Ledger`, `.CoverageGantt`, `.Prehled`, `.UserRow`) were
moved into ds/ from voltlink and litelink, so the showcase builds from this repo alone; each demo
names the ds file. When a page changes in the app, copy the new markup over and rerun `build.sh`.
