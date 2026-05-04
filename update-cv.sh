#!/bin/bash

set -euo pipefail

# Script to compile LaTeX CV to PDF and update website
# Usage: ./update-cv.sh [--install]

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
CV_DIR="$ROOT_DIR/assets/cv"
CV_TEX="sam-scivier-cv.tex"
CV_PDF="sam-scivier-cv.pdf"
INSTALL_MISSING=false

if [[ "${1:-}" == "--install" ]]; then
    INSTALL_MISSING=true
fi

echo "Compiling LaTeX CV to PDF..."

required_packages=(
    geometry
    titlesec
    enumitem
    hyperref
    xcolor
    fontawesome
    microtype
    etaremune
    fancyhdr
)

missing_packages=()

check_package() {
    kpsewhich "$1.sty" >/dev/null 2>&1
}

install_missing_packages() {
    echo "Checking required LaTeX packages..."

    for package in "${required_packages[@]}"; do
        if check_package "$package"; then
            echo "  ✅ Package $package is installed"
        else
            echo "  ❌ Package $package not found"
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        echo "✅ All required packages are installed"
        return 0
    fi

    echo "Missing packages: ${missing_packages[*]}"

    if [[ "$INSTALL_MISSING" == true ]]; then
        echo "Attempting to install missing packages with tlmgr..."
        if tlmgr install "${missing_packages[@]}"; then
            echo "✅ Missing packages installed successfully"
            return 0
        fi

        echo "❌ Automatic installation failed. On macOS system TeX Live installs, update tlmgr and install as an administrator:"
        echo "sudo tlmgr update --self"
        echo "sudo tlmgr install ${missing_packages[*]}"
        exit 1
    fi

    echo "❌ Required LaTeX packages are missing. Install them and rerun:"
    echo "sudo tlmgr update --self"
    echo "sudo tlmgr install ${missing_packages[*]}"
    echo
    echo "If you want the script to try a non-sudo tlmgr install first, run:"
    echo "./update-cv.sh --install"
    exit 1
}

install_missing_packages

cd "$CV_DIR"

pdflatex -interaction=nonstopmode -halt-on-error "$CV_TEX"
echo "✅ First LaTeX compilation successful"

pdflatex -interaction=nonstopmode -halt-on-error "$CV_TEX"
echo "✅ Second LaTeX compilation successful"

if [[ -f "$CV_PDF" ]]; then
    echo "✅ LaTeX compilation complete"

    cp "$CV_PDF" "$ROOT_DIR/$CV_PDF"
    echo "✅ PDF copied to website root"
    echo "✅ CV is now available at /$CV_PDF"
else
    echo "❌ LaTeX compilation failed - no PDF generated"
    exit 1
fi

echo "Cleaning up auxiliary files..."
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz

echo "✅ CV update complete!"
