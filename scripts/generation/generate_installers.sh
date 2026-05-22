#!/bin/bash

# Input CSV file
CSV_FILE="installLinks.csv"

# Output directory for all packages (order preserved via numeric prefix)
DIR_PACKAGES="src/packages"

mkdir -p "$DIR_PACKAGES"
echo "Clearing files in $DIR_PACKAGES..."
rm -f "$DIR_PACKAGES"/*

echo "Generating new files based on $CSV_FILE..."

INDEX=0

tail -n +2 "$CSV_FILE" | while IFS=',' read -r NAME PACKAGE_GEN PASSWORD VERSION_ID NAMESPACE VERSION_NUMBER; do
  NAME=$(echo "$NAME" | tr -d '\r\n')
  PACKAGE_GEN=$(echo "$PACKAGE_GEN" | tr -d '\r\n')
  PASSWORD=$(echo "$PASSWORD" | tr -d '\r\n')
  VERSION_ID=$(echo "$VERSION_ID" | tr -d '\r\n')
  NAMESPACE=$(echo "$NAMESPACE" | tr -d '\r\n')
  VERSION_NUMBER=$(echo "$VERSION_NUMBER" | tr -d '\r\n')

  if [[ "$PACKAGE_GEN" == "1GP" || "$PACKAGE_GEN" == "2GP" ]]; then
    FILE_NAME="$DIR_PACKAGES/$(printf '%03d' $INDEX)_${NAME}.txt"
    cat <<EOL > "$FILE_NAME"
$NAME
$PACKAGE_GEN
$VERSION_NUMBER
$VERSION_ID
$PASSWORD
EOL
    echo "Generated $PACKAGE_GEN file: $FILE_NAME"
  else
    echo "Unknown Package Generation type for entry: $NAME. Skipping."
  fi

  INDEX=$((INDEX + 1))
done

echo "File generation completed."
