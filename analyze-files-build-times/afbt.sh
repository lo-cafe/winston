#!/bin/bash

# Verify there's an input argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_file.txt>"
    exit 1
fi

# Assure the provided file exists
input_file="$1"
if [ ! -f "$input_file" ]; then
    echo "File does not exist: $input_file"
    exit 1
fi

# Determine the directory of the input file
dir_name=$(dirname "$input_file")

# Define the output file path
output_file="${dir_name}/analyzed.txt"

# Process the input file and save to output file
awk '
{
    # Extract build time, removing "ms" and convert to float
    time = substr($1, 1, length($1)-2) + 0.0;
    # Normalize file path by removing line and column numbers
    filepath = $2;
    gsub(/:[0-9]+:[0-9]+$/, "", filepath);
    # Aggregate times per file
    times[filepath] += time;
}
END {
    # Print aggregated times, formatted as floating points
    for (file in times) {
        printf "%.2fms %s\n", times[file], file;
    }
}' "$input_file" | sort -k1,1nr > "$output_file"

echo "Analysis completed. Results are saved in ${output_file}"
