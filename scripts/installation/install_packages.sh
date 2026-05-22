#!/bin/bash

read -p "Enter the Access Token: " ACCESS_TOKEN
read -p "Enter the Instance URL (e.g., https://login.salesforce.com): " INSTANCE_URL

TARGET_ORG="packageInstallOrg"
PACKAGE_DIR="src/packages"

export SF_ACCESS_TOKEN="$ACCESS_TOKEN"
sf org login access-token -r "$INSTANCE_URL" -s -a "$TARGET_ORG" -p

if [ $? -ne 0 ]; then
  echo "❌ Authentication failed. Please check your Access Token and Instance URL."
  exit 1
fi

echo "✅ Successfully authenticated with the target org: $TARGET_ORG"
echo ""

rm -f "$PACKAGE_DIR/success.log" "$PACKAGE_DIR/failure.log"

echo "🚀 Starting package installations 🚀"
echo "----------------------------------------"
echo ""

for PACKAGE_FILE in $(ls "$PACKAGE_DIR"/*.txt 2>/dev/null | sort); do
  [ -f "$PACKAGE_FILE" ] || continue

  PACKAGE_NAME=$(sed -n '1p' "$PACKAGE_FILE")
  PACKAGE_GEN=$(sed -n '2p' "$PACKAGE_FILE")
  PACKAGE_VERSION=$(sed -n '3p' "$PACKAGE_FILE")
  PACKAGE_ID=$(sed -n '4p' "$PACKAGE_FILE")
  PACKAGE_PASSWORD=$(sed -n '5p' "$PACKAGE_FILE")

  echo "➕ Installing $PACKAGE_GEN Package: $PACKAGE_NAME@$PACKAGE_VERSION"
  echo "Package ID: $PACKAGE_ID"

  sf package install -p "$PACKAGE_ID" -k "$PACKAGE_PASSWORD" -o "$TARGET_ORG" -w 30 -b 10 -r

  if [ $? -eq 0 ]; then
    echo "✅ Package $PACKAGE_NAME@$PACKAGE_VERSION installed successfully."
    echo "$PACKAGE_NAME@$PACKAGE_VERSION" >> "$PACKAGE_DIR/success.log"
  else
    echo "❌ Failed to install package $PACKAGE_NAME@$PACKAGE_VERSION."
    echo "$PACKAGE_NAME@$PACKAGE_VERSION" >> "$PACKAGE_DIR/failure.log"
  fi

  echo "----------------------------------------"
  echo ""
done

echo ""
echo "📋 Installation Summary:"
if [ -f "$PACKAGE_DIR/success.log" ]; then
  echo "✅ Successfully installed:"
  cat "$PACKAGE_DIR/success.log"
fi

if [ -f "$PACKAGE_DIR/failure.log" ]; then
  echo "❌ Failed to install:"
  cat "$PACKAGE_DIR/failure.log"
fi

echo ""
echo "✅ All installations completed."
