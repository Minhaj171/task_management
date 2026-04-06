#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Auto-push to GitHub on file change
# Usage: bash watch_and_push.sh
# Stop:  Ctrl+C
# ─────────────────────────────────────────────────────────────

FOLDER="/Users/macbookpro/Desktop/Team workflow 2026"
BRANCH="main"

cd "$FOLDER"

echo "👀 Watching for changes in: $FOLDER"
echo "🔗 Remote: $(git remote get-url origin)"
echo "🌿 Branch: $BRANCH"
echo "──────────────────────────────────────"
echo "Press Ctrl+C to stop"
echo ""

# Check if fswatch is available (brew install fswatch)
if command -v fswatch &>/dev/null; then
  echo "✅ Using fswatch (instant detection)"
  fswatch -o --exclude=".git" --exclude=".DS_Store" "$FOLDER" | while read -r change; do
    sleep 1   # brief debounce
    CHANGED=$(git status --porcelain | grep -v "\.DS_Store" | grep -v "\.xlsx")
    if [ -n "$CHANGED" ]; then
      TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
      echo "📦 Change detected at $TIMESTAMP"
      git add index.html .gitignore 2>/dev/null
      git diff --cached --quiet && echo "  (nothing new to commit)" && continue
      git commit -m "Auto update: $TIMESTAMP" --quiet
      echo "  ✅ Committed"
      git push origin "$BRANCH" --quiet 2>&1
      if [ $? -eq 0 ]; then
        echo "  🚀 Pushed to GitHub Pages"
      else
        echo "  ❌ Push failed — check credentials"
      fi
      echo ""
    fi
  done
else
  echo "⚠️  fswatch not found — using 5-second polling"
  echo "   (Run: brew install fswatch  for instant detection)"
  echo ""
  while true; do
    sleep 5
    CHANGED=$(git status --porcelain | grep -v "\.DS_Store" | grep -v "\.xlsx")
    if [ -n "$CHANGED" ]; then
      TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
      echo "📦 Change detected at $TIMESTAMP"
      git add index.html .gitignore 2>/dev/null
      git diff --cached --quiet && continue
      git commit -m "Auto update: $TIMESTAMP" --quiet
      echo "  ✅ Committed"
      git push origin "$BRANCH" --quiet 2>&1
      if [ $? -eq 0 ]; then
        echo "  🚀 Pushed to GitHub Pages"
      else
        echo "  ❌ Push failed — check credentials"
      fi
      echo ""
    fi
  done
fi
