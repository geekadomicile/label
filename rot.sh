#!/bin/bash
find ./ -name "proof.png" | while IFS= read -r file; do
    mogrify "$file" -rotate 90 "$file"
done
