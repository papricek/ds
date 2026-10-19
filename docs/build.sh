#!/usr/bin/env bash
# Rebuilds the showcase stylesheet from source: css/ds.css = Bootstrap + every component
# in this repo + the apps' ds overrides for the app demos (src/ds.scss).
# Run it after changing a component.
set -euo pipefail
cd "$(dirname "$0")"

SASS_VERSION=1.83.4
BOOTSTRAP_VERSION=5.3.5   # keep in step with the apps' bootstrap gem
CACHE=.cache

if [ ! -d "$CACHE/bootstrap-$BOOTSTRAP_VERSION" ]; then
  mkdir -p "$CACHE"
  curl -sSL "https://registry.npmjs.org/bootstrap/-/bootstrap-$BOOTSTRAP_VERSION.tgz" | tar -xz -C "$CACHE"
  mv "$CACHE/package" "$CACHE/bootstrap-$BOOTSTRAP_VERSION"
fi

# ds/ goes first on the load path: Bootstrap has its own _alert, _card, _nav… partials.
sass() { npx -y "sass@$SASS_VERSION" --no-source-map --style=compressed --quiet-deps --silence-deprecation=import,global-builtin,color-functions,mixed-decls "$@"; }

sass --load-path=.. --load-path="$CACHE/bootstrap-$BOOTSTRAP_VERSION/scss" src/ds.scss css/ds.css
echo "css/ds.css"

