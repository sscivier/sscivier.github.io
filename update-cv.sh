#!/bin/bash

# Script to compile LaTeX CV to PDF and update website
# Usage: ./update-cv.sh

echo "Compiling LaTeX CV to PDF..."

# Navigate to CV directory
cd "$(dirname "$0")/assets/cv"

# Compile the LaTeX CV to PDF
pdflatex cv.tex

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "✅ LaTeX compilation successful"
    
    # Copy PDF to website root
    cp cv.pdf ../../cv.pdf
    
    if [ $? -eq 0 ]; then
        echo "✅ PDF copied to website root"
        echo "✅ CV is now available at /cv.pdf"
    else
        echo "❌ Failed to copy PDF to website root"
        exit 1
    fi
else
    echo "❌ LaTeX compilation failed"
    exit 1
fi

# Clean up auxiliary files (optional)
echo "Cleaning up auxiliary files..."
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz

echo "✅ CV update complete!"
