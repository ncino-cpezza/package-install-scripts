#!/bin/bash

# Input CSV file
CSV_FILE="installLinks.csv"

# Base directories for file outputs
DIR_1GP="src/1gp/installedPackages"
DIR_2GP="src/2gp"

# Ensure the directories exist
mkdir -p "$DIR_1GP"
mkdir -p "$DIR_2GP"

# Clear existing files in the directories
echo "Clearing files in $DIR_1GP and $DIR_2GP..."
rm -f "$DIR_1GP"/*
rm -f "$DIR_2GP"/*

echo "Generating new files based on $CSV_FILE..."

# Read the CSV file line by line, skipping the header
tail -n +2 "$CSV_FILE" | while IFS=',' read -r NAME PACKAGE_GEN PASSWORD VERSION_ID NAMESPACE VERSION_NUMBER; do
  # Sanitize inputs to remove trailing newlines and carriage returns
  NAME=$(echo "$NAME" | tr -d '\r\n')
  PACKAGE_GEN=$(echo "$PACKAGE_GEN" | tr -d '\r\n')
  PASSWORD=$(echo "$PASSWORD" | tr -d '\r\n')
  VERSION_ID=$(echo "$VERSION_ID" | tr -d '\r\n')
  NAMESPACE=$(echo "$NAMESPACE" | tr -d '\r\n')
  VERSION_NUMBER=$(echo "$VERSION_NUMBER" | tr -d '\r\n')

  if [[ "$PACKAGE_GEN" == "1GP" ]]; then
    # File for 1GP
    FILE_NAME="$DIR_1GP/$NAMESPACE.installedPackage-meta.xml"
    cat <<EOL > "$FILE_NAME"
<?xml version="1.0" encoding="UTF-8"?>
<InstalledPackage xmlns="http://soap.sforce.com/2006/04/metadata">
  <versionNumber>$VERSION_NUMBER</versionNumber>
  <password>$PASSWORD</password>
  <securityType>AllUsers</securityType>
</InstalledPackage>
EOL
    echo "Generated 1GP file: $FILE_NAME"

  elif [[ "$PACKAGE_GEN" == "2GP" ]]; then
    # File for 2GP
    FILE_NAME="$DIR_2GP/$NAME.txt"
    cat <<EOL > "$FILE_NAME"
$NAME
$VERSION_NUMBER
$VERSION_ID
$PASSWORD
EOL
    echo "Generated 2GP file: $FILE_NAME"
  else
    echo "Unknown Package Generation type for entry: $NAME. Skipping."
  fi
done

echo "File generation completed."
