#!/bin/bash
# Builds "מאמן שפות.app" into ~/Applications.
# The app starts the local server in the background (if it isn't running)
# and opens the trainer in its own Chrome window.
set -e
cd "$(dirname "$0")"
PROJECT="$(cd .. && pwd -P)"
APP="$HOME/Applications/מאמן שפות.app"

# Icon
swift make_icon.swift icon.png
ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s icon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) icon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>מאמן שפות</string>
  <key>CFBundleDisplayName</key><string>מאמן שפות</string>
  <key>CFBundleIdentifier</key><string>local.spanish-trainer.launcher</string>
  <key>CFBundleExecutable</key><string>launcher</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

cat > "$APP/Contents/Resources/launch.sh" <<LAUNCHER
#!/bin/bash
PROJECT="$PROJECT"
URL="http://127.0.0.1:8124"
LOG="\$HOME/Library/Logs/spanish-trainer.log"

if ! curl -s -o /dev/null "\$URL"; then
  nohup "\$PROJECT/run.sh" > "\$LOG" 2>&1 &
  # First run installs Flask, so allow up to a minute
  for i in \$(seq 1 120); do
    curl -s -o /dev/null "\$URL" && break
    sleep 0.5
  done
fi

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app="\$URL" >/dev/null 2>&1 &
LAUNCHER
chmod +x "$APP/Contents/Resources/launch.sh"

# Native executable that runs launch.sh.
# Note: the project must not live in Desktop/Documents/Downloads, which macOS
# blocks apps from reading.
swiftc -O -o "$APP/Contents/MacOS/launcher" launcher.swift
codesign --force --deep -s - "$APP" >/dev/null 2>&1

touch "$APP"
echo "Built: $APP"
