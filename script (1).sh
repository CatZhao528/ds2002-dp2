#!/bin/bash

successful_imports=0
failed_imports=0
error_files=0

for file in data/*.json
do
  echo "Importing $file into MongoDB"
  
  # Run mongoimport and capture the output
  output=$(mongoimport --uri $MONGODB --collection datacollect --file "$file" --jsonArray 2>&1)
  echo "$output"
  
  # Check for successful imports by matching the expected output string
  if [[ "$output" == *"(s) imported successfully"* ]]; then
    # Extract the number of successfully imported documents
    imported=$(echo $output | grep -o '[0-9]* document(s) imported successfully' | awk '{print $1}')
    successful_imports=$((successful_imports + imported))
  else
    # If import failed, increase the failed imports count
    echo "Failed to import $file"
    failed_imports=$((failed_imports + 1))
    
    # Check for specific errors related to document processing
    if [[ "$output" == *"error processing document"* ]]; then
      echo "Corruption error in $file"
      error_files=$((error_files + 1))
    fi
  fi
done

# Write the final counts to the count.txt file, check for errors in file writing
echo "Successful imports: $successful_imports" > count.txt || echo "Failed to write successful imports"
echo "Failed imports: $failed_imports" >> count.txt || echo "Failed to write failed imports"
echo "Files with corrupted documents: $error_files" >> count.txt || echo "Failed to write file corruption count"
