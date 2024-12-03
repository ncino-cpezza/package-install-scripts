#!/bin/bash

read -p "Enter the Access Token: " ACCESS_TOKEN
read -p "Enter the Instance URL (e.g., https://login.salesforce.com): " INSTANCE_URL

export SF_ACCESS_TOKEN="$ACCESS_TOKEN"
sf org login access-token -r "$INSTANCE_URL" -s -a "$TARGET_ORG" -p

if [ $? -ne 0 ]; then
  echo "❌ Authentication failed. Please check your Access Token and Instance URL."
  exit 1
fi

echo "✅ Successfully authenticated with the target org: $TARGET_ORG"
echo ""

1GP_PACKAGE_DIR="src/1gp"
2GP_PACKAGE_DIR="src/2gp"
TARGET_ORG="packageInstallOrg"

echo "🚀 Starting 1GP package installations 🚀"
echo "----------------------------------------"
echo ""

sf project deploy start -d "$1GP_PACKAGE_DIR" -o "$TARGET_ORG" -w 300

if [ $? -eq 0 ]; then
  echo "✅ Successfully installed the following 1GP packages:"
  for FILE in "$1GP_PACKAGE_DIR/installedPackages/"*.installedPackage-meta.xml; do
    if [ -f "$FILE" ]; then
      PACKAGE_NAME=$(basename "$FILE" .installedPackage-meta.xml)
      VERSION_NUMBER=$(grep -oPm1 "(?<=<versionNumber>)[^<]+" "$FILE")
      echo "   - $PACKAGE_NAME@$VERSION_NUMBER"
    fi
  done
else
  echo "❌ Failed to install the following 1GP packages:"
  for FILE in "$1GP_PACKAGE_DIR/installedPackages/"*.installedPackage-meta.xml; do
    if [ -f "$FILE" ]; then
      PACKAGE_NAME=$(basename "$FILE" .installedPackage-meta.xml)
      VERSION_NUMBER=$(grep -oPm1 "(?<=<versionNumber>)[^<]+" "$FILE")
      echo "   - $PACKAGE_NAME@$VERSION_NUMBER"
    fi
  done
fi

echo "----------------------------------------"
echo ""

echo "🚀 Starting 2GP package installations 🚀"
echo "----------------------------------------"
echo ""

for PACKAGE_FILE in "$2GP_PACKAGE_DIR"/*; do
  [ -f "$PACKAGE_FILE" ] || continue

  PACKAGE_NAME=$(sed -n '1p' "$PACKAGE_FILE")
  PACKAGE_VERSION=$(sed -n '2p' "$PACKAGE_FILE")
  PACKAGE_ID=$(sed -n '3p' "$PACKAGE_FILE")
  PACKAGE_PASSWORD=$(sed -n '4p' "$PACKAGE_FILE")

  echo "➕ Installing Package: $PACKAGE_NAME@$PACKAGE_VERSION"
  echo "Package ID: $PACKAGE_ID"

  sf package install -p "$PACKAGE_ID" -k "$PACKAGE_PASSWORD" -o "$TARGET_ORG" -w 30 -b 10 -r

  if [ $? -eq 0 ]; then
    echo "✅ Package $PACKAGE_NAME@$PACKAGE_VERSION installed successfully."
    echo "$PACKAGE_NAME@$PACKAGE_VERSION" >> "$2GP_PACKAGE_DIR/success.log"
  else
    echo "❌ Failed to install package $PACKAGE_NAME@$PACKAGE_VERSION."
    echo "$PACKAGE_NAME@$PACKAGE_VERSION" >> "$2GP_PACKAGE_DIR/failure.log"
  fi

  echo "----------------------------------------"
  echo ""
done

echo "✅ All 2GP package installations completed."

echo ""
echo "📋 Installation Summary:"
if [ -f "$2GP_PACKAGE_DIR/success.log" ]; then
  echo "✅ Successfully installed the following 2GP packages:"
  cat "$2GP_PACKAGE_DIR/success.log"
fi

if [ -f "$2GP_PACKAGE_DIR/failure.log" ]; then
  echo "❌ Failed to install the following 2GP packages:"
  cat "$2GP_PACKAGE_DIR/failure.log"
fi

echo ""
echo "✅ All installations completed."
