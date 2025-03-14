#!/bin/bash
cat <<'EOF' | sudo tee /usr/local/bin/apply-vivaldi-mods
#!/bin/bash

# Original version by Isildur, adapted by luetage

# Quit Vivaldi
osascript -e 'quit app "Vivaldi.app"'

# Find path to Framework folder of current version and save it as variable
findPath="$(find /Applications/Vivaldi.app -name Vivaldi\ Framework.framework)"

# Copy custom js file to Vivaldi.app
cp "$HOME/.config/vivaldi-mods/mod.js" "$findPath"/Resources/vivaldi/

# Save path to window.html as variable
browserHtml="$findPath"/Resources/vivaldi/window.html

# Insert references, if not present, and save to temporary file
if grep -q "mod.js" "$browserHtml"; then
  echo "custom.js already referenced in window.html"
else
  sed 's|</body>|</body><script src="mod.js"></script>|' "$browserHtml" >"$browserHtml".temp
  # Backup original file
  cp "$browserHtml" "$browserHtml".bak
  # Overwrite
  mv "$browserHtml".temp "$browserHtml"
fi

# Open Vivaldi
sleep 1
open /Applications/Vivaldi.app
EOF

sudo chmod +x /usr/local/bin/apply-vivaldi-mods
