#!/bin/bash

VULN_LIST="vulnerable.txt"
LOCK_DIR="./package-locks"

if [[ ! -f "$VULN_LIST" ]]; then
  echo "File $VULN_LIST not found."
  exit 1
fi

if [[ ! -d "$LOCK_DIR" ]]; then
  echo "Directory $LOCK_DIR not found."
  exit 1
fi

echo "🔍 Scanning all package-lock.json files in $LOCK_DIR ..."

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  full="$line"
  pkg_ver="${full##*@}"             # after last @
  pkg_name="${full%@$pkg_ver}"      # before last @
  publisher="${pkg_name%%/*}"       # before first /


  for lockfile in "$LOCK_DIR"/*package-lock*.json; do
    [ -e "$lockfile" ] || continue

    if [[ "$pkg_name" == */* ]]; then
        publisher="${pkg_name%%/*}"
    else
        publisher=""
    fi

    # Look for the impacted publisher
    if [ -n "$publisher" ] && grep -q "$publisher" "$lockfile"; then
      echo "$publisher publisher found in $lockfile"
    fi

    # Look for the impacted package
    if [ -n "$pkg_name" ] && grep -q "$pkg_name" "$lockfile"; then
      echo "$pkg_name package found in $lockfile"
    fi
  done

done < "$VULN_LIST"
