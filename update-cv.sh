#!/bin/bash

# Script to compile LaTeX CV to PDF and update website
# Usage: ./update-cv.sh

echo "Compiling LaTeX CV to PDF..."

# Function to check if a LaTeX package is installed
check_package() {
    tlmgr info --list --only-installed | grep -q "^i $1:"
    return $?
}

# Function to install missing packages
install_missing_packages() {
    local packages_to_install=""
    local required_packages=("geometry" "enumitem" "hyperref" "titlesec" "parskip" "fontawesome5" "etaremune")
    
    echo "Checking required LaTeX packages..."
    
    for package in "${required_packages[@]}"; do
        if ! check_package "$package"; then
            echo "  ❌ Package $package not found"
            packages_to_install="$packages_to_install $package"
        else
            echo "  ✅ Package $package is installed"
        fi
    done
    
    if [ -n "$packages_to_install" ]; then
        echo "Installing missing packages:$packages_to_install"
        sudo tlmgr install $packages_to_install
        if [ $? -ne 0 ]; then
            echo "❌ Failed to install packages. Please install manually with:"
            echo "sudo tlmgr install$packages_to_install"
            exit 1
        fi
        echo "✅ Missing packages installed successfully"
    else
        echo "✅ All required packages are installed"
    fi
}

# Check and install missing packages
install_missing_packages

# Navigate to CV directory
cd "$(dirname "$0")/assets/cv"

# Compile the LaTeX CV to PDF
pdflatex cv.tex

# Check if first compilation was successful
if [ $? -eq 0 ]; then
    echo "✅ First LaTeX compilation successful"
    
    # Run pdflatex again to resolve cross-references (like page numbers)
    pdflatex cv.tex
    
    if [ $? -eq 0 ]; then
        echo "✅ Second LaTeX compilation successful"
    else
        echo "❌ Second LaTeX compilation failed"
        exit 1
    fi
else
    echo "❌ First LaTeX compilation failed"
    exit 1
fi

# Check if final compilation was successful
if [ -f "cv.pdf" ]; then
    echo "✅ LaTeX compilation complete"
    
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
    echo "❌ LaTeX compilation failed - no PDF generated"
    exit 1
fi

# Clean up auxiliary files (optional)
echo "Cleaning up auxiliary files..."
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz

echo "✅ CV update complete!"
