#!/bin/bash

# Define the input directory and output JSON file
PARTIAL_DIR="./partial"
OUTPUT_FILE="partial.json"

# Initialize output.json as an empty JSON object
echo "{}" > "$OUTPUT_FILE"

# Check if the partial directory exists
if [ ! -d "$PARTIAL_DIR" ]; then
    echo "Error: Directory '$PARTIAL_DIR' not found."
    exit 1
fi

echo "Processing files in '$PARTIAL_DIR'..."

# Find all files in the partial directory
find "$PARTIAL_DIR" -type f | while read -r filepath; do
    # Extract the filename relative to PARTIAL_DIR
    filename="$(basename "$filepath")"

    # Get the content of the file
    content="$(cat "$filepath")"

    # Infer the JSON path from the filename
    # Example: common.header.html -> .common.header
    # Remove the directory prefix and file extension, replace '.' with '.' for jq path
    # This specifically handles the example where common.header.html becomes .common.header
    # For a more general case, you might want to replace the first '.' with a '/' or similar.
    # For this specific request, we'll remove the extension and prepend a dot.
    json_path="$(echo "$filename" | sed -E 's/\.[^.]+$//')" # Remove last extension, prepend dot

    # If the filename was like "file.txt", this would become ".file"
    # If the filename was like "common.header.html", this would become ".common.header"

    echo "  - Processing '$filename' -> JSON path: '$json_path'"

    # Use jq to mount the content into output.json
    # We use a temporary file to store the updated JSON to avoid issues with in-place editing
    # The --argjson option is used to pass the content as a JSON string, ensuring proper escaping.
    # The --arg option is used for the path.
    # jq --arg path "$json_path" --argjson value "\"$content\"" '.[$path] = $value' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    jq --arg path "$json_path" --arg value "$content" '.[$path] = $value' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"


    if [ $? -ne 0 ]; then
        echo "Error: Failed to update '$OUTPUT_FILE' with content from '$filename'."
        # Optionally, you can exit here or continue to the next file
    fi
    echo "Content of '$OUTPUT_FILE':"
    cat "$OUTPUT_FILE"
done

echo "Script finished. Output saved to '$OUTPUT_FILE'."
