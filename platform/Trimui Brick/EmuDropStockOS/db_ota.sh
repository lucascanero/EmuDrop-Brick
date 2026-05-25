#!/bin/bash

# Repository name in the format "owner/repo"
REPO="ahmadteeb/EmuDrop"

# Local version file
VERSION_FILE="version.txt"

# GitHub API URL for tags
API_URL="https://api.github.com/repos/$REPO/tags"

# Expected db file name in the release
DB_FILE_NAME="catalog.db"

# Function to get the local version
get_local_version() {
    if [[ -f "$VERSION_FILE" && -f "assets/$DB_FILE_NAME" ]]; then
        sed -n '2p' "$VERSION_FILE" | tr -d '[:space:]'
    else
        echo "v0.0.0" # Default version if the file does not exist
    fi
}

# Function to get the latest version from GitHub
get_latest_version() {
    local latest_version=$(curl -s -k "$API_URL" | grep -o '"name": "[^"]*' | grep '\-db' | head -n 1 | cut -d '"' -f 4)
    # If the version does not start with 'v', add the 'v'
    if [[ ! $latest_version =~ ^v ]]; then
        latest_version="v$latest_version"
    fi
    echo "${latest_version%-db}"
}

# Function to download the latest release
download_latest_release() {
    local version="$1"
    local url="https://github.com/$REPO/releases/download/$version-db/catalog-$version.db"

    echo "Downloading the latest release from: $url"
    if ! curl -L -k -o $DB_FILE_NAME "$url"; then
        echo "Error downloading the release. The file was not deleted."
        exit 1
    fi
}

# Function to clean local db file
clean_local_files() {
    echo "Cleaning local db file if exits"
    rm -f "assets/$DB_FILE_NAME"
}


move_db_file() {
    echo "Moving db file to assets"
    mv $DB_FILE_NAME "assets/$DB_FILE_NAME"
}


update_version_file() {
    touch $VERSION_FILE
    # Add empty lines until at least 2 exist
    while [ $(wc -l < $VERSION_FILE) -lt 2 ]; do
        echo "" >> $VERSION_FILE
    done
    
    sed -i "2s/.*/$latest_version/" "$VERSION_FILE"

}

# Main flow
echo "Checking for update for database"
echo -e "{ \"type\":\"info\", \"size\":2, \"duration\":3000, \"x\":400, \"y\":0,  \"message\":\"Checking for update for database...\",  \"icon\":\"\" }" >/tmp/trimui_osd/osd_toast_msg

local_version=$(get_local_version)
latest_version=$(get_latest_version)

echo "Local version: $local_version"
echo "Latest version: $latest_version"

if [[ "$local_version" == "$latest_version" ]]; then
    echo "You are already on the latest version: $latest_version"
    echo -e "{ \"type\":\"info\", \"size\":3, \"duration\":3000, \"x\":200, \"y\":0,  \"message\":\"You are already on the latest version: $latest_version\",  \"icon\":\"\" }" >/tmp/trimui_osd/osd_toast_msg
else
    echo "New update available: $latest_version"
    echo -e "{ \"type\":\"info\", \"size\":3, \"duration\":3000, \"x\":300, \"y\":0,  \"message\":\"New update available: $latest_version\",  \"icon\":\"\" }" >/tmp/trimui_osd/osd_toast_msg
    echo "Please wait, this may take a few moments..."
    echo -e "{ \"type\":\"info\", \"size\":3, \"duration\":3000, \"x\":200, \"y\":0,  \"message\":\"Please wait, this may take a few moments...\",  \"icon\":\"\" }" >/tmp/trimui_osd/osd_toast_msg
    download_latest_release "$latest_version"
    clean_local_files
    move_db_file
    update_version_file
    echo "Database update complete."
    echo -e "{ \"type\":\"info\", \"size\":3, \"duration\":3000, \"x\":400, \"y\":0,  \"message\":\"Database update complete.\",  \"icon\":\"\" }" >/tmp/trimui_osd/osd_toast_msg
fi