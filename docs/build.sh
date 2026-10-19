#!/usr/bin/env bash
# Rebuilds the showcase stylesheets from source:
#   css/ds.css    Bootstrap + every component in this repo (src/ds.scss)
#   css/apps.css  page styles of the apps, each scoped under .AppPage--<app> (src/apps.scss)
#
# The page styles live in the apps, not here, so apps.css needs local checkouts:
#   VOLTLINK_DIR (default ~/Work/voltlink), LITELINK_DIR (default ~/Work/litelink)
# Run it after changing a component, and after changing a page style an app showcase uses.
set -euo pipefail
cd "$(dirname "$0")"

SASS_VERSION=1.83.4
BOOTSTRAP_VERSION=5.3.5   # keep in step with the apps' bootstrap gem
CACHE=.cache
VOLTLINK_DIR=${VOLTLINK_DIR:-$HOME/Work/voltlink}
LITELINK_DIR=${LITELINK_DIR:-$HOME/Work/litelink}

if [ ! -d "$CACHE/bootstrap-$BOOTSTRAP_VERSION" ]; then
  mkdir -p "$CACHE"
  curl -sSL "https://registry.npmjs.org/bootstrap/-/bootstrap-$BOOTSTRAP_VERSION.tgz" | tar -xz -C "$CACHE"
  mv "$CACHE/package" "$CACHE/bootstrap-$BOOTSTRAP_VERSION"
fi

# ds/ goes first on the load path: Bootstrap has its own _alert, _card, _nav… partials.
sass() { npx -y "sass@$SASS_VERSION" --no-source-map --style=compressed --quiet-deps --silence-deprecation=import,global-builtin,color-functions,mixed-decls "$@"; }

sass --load-path=.. --load-path="$CACHE/bootstrap-$BOOTSTRAP_VERSION/scss" src/ds.scss css/ds.css
echo "css/ds.css"

for dir in "$VOLTLINK_DIR" "$LITELINK_DIR"; do
  [ -d "$dir/app/assets/stylesheets" ] || { echo "missing $dir — set VOLTLINK_DIR / LITELINK_DIR" >&2; exit 1; }
done
mkdir -p "$CACHE/apps"
ln -sfn "$VOLTLINK_DIR/app/assets/stylesheets" "$CACHE/apps/voltlink"
ln -sfn "$LITELINK_DIR/app/assets/stylesheets" "$CACHE/apps/litelink"
sass --load-path=.. --load-path="$CACHE/bootstrap-$BOOTSTRAP_VERSION/scss" --load-path="$CACHE/apps" \
  src/apps.scss css/apps.css
echo "css/apps.css"
