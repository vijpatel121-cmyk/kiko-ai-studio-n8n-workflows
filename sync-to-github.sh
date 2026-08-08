#!/bin/bash
# Exports all n8n workflows and pushes any changes to GitHub.
# Run manually whenever you want to snapshot the current n8n state.
set -e

cd "$(dirname "$0")"

echo "Exporting workflows from n8n..."
n8n export:workflow --all --output="$(pwd)" --separate

echo "Pretty-printing JSON for readable diffs..."
for f in *.json; do
  node -e "
    const fs = require('fs');
    const data = JSON.parse(fs.readFileSync('$f', 'utf8'));
    fs.writeFileSync('$f', JSON.stringify(data, null, 2) + '\n');
  "
done

git add -A

if git diff --cached --quiet; then
  echo "No changes since last sync."
  exit 0
fi

git commit -m "Sync workflows from n8n - $(date -u +%Y-%m-%dT%H:%M:%SZ)"
git push origin master

echo "Synced and pushed to GitHub."
