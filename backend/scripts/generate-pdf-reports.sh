#!/bin/bash

# Script to generate PDF reports from HTML test reports
# This script uses macOS's built-in print-to-PDF functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$BACKEND_DIR/target"
SITE_DIR="$TARGET_DIR/site"
PDF_DIR="$TARGET_DIR/pdf-reports"

# Create PDF directory
mkdir -p "$PDF_DIR"

echo "📄 Generating PDF reports..."
echo ""

# Check if reports exist
if [ ! -f "$SITE_DIR/surefire-report.html" ]; then
    echo "❌ Surefire report not found. Generating reports first..."
    cd "$BACKEND_DIR"
    mvn clean test jacoco:report surefire-report:report
fi

# Method 1: Use wkhtmltopdf if available
if command -v wkhtmltopdf &> /dev/null; then
    echo "✅ Using wkhtmltopdf to generate PDFs..."
    
    wkhtmltopdf --page-size A4 --orientation Portrait \
        --margin-top 10mm --margin-bottom 10mm \
        --margin-left 10mm --margin-right 10mm \
        "$SITE_DIR/surefire-report.html" "$PDF_DIR/surefire-report.pdf"
    
    wkhtmltopdf --page-size A4 --orientation Portrait \
        --margin-top 10mm --margin-bottom 10mm \
        --margin-left 10mm --margin-right 10mm \
        "$SITE_DIR/jacoco/index.html" "$PDF_DIR/jacoco-coverage-report.pdf"
    
    echo "✅ PDF reports generated in: $PDF_DIR"
    echo "   - surefire-report.pdf"
    echo "   - jacoco-coverage-report.pdf"
    exit 0
fi

# Method 2: Use macOS's built-in print-to-PDF (osascript)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ Using macOS print-to-PDF..."
    
    # Generate Surefire PDF
    osascript <<EOF
tell application "Safari"
    activate
    open POSIX file "file://$SITE_DIR/surefire-report.html"
    delay 2
    tell application "System Events"
        keystroke "p" using {command down}
        delay 1
        keystroke "s" using {command down}
        delay 1
        keystroke "G" using {command down, shift down}
        delay 1
        keystroke "$PDF_DIR/surefire-report.pdf"
        delay 1
        keystroke return
        delay 1
        keystroke return
    end tell
    delay 1
    quit
end tell
EOF
    
    # Note: Safari automation is complex. Using alternative method below.
    echo "⚠️  Safari automation can be unreliable. Using manual method instead."
fi

# Method 3: Manual instructions with browser
echo ""
echo "📋 Manual PDF Generation Instructions:"
echo ""
echo "Since automated PDF conversion requires additional tools, please use one of these methods:"
echo ""
echo "Option 1: Browser Print-to-PDF (Recommended for macOS)"
echo "  1. Open the HTML report in your browser:"
echo "     open $SITE_DIR/surefire-report.html"
echo "     open $SITE_DIR/jacoco/index.html"
echo ""
echo "  2. Press Cmd+P (Print)"
echo "  3. Click 'Save as PDF' in the print dialog"
echo "  4. Save to: $PDF_DIR"
echo ""
echo "Option 2: Install wkhtmltopdf (Command-line conversion)"
echo "  macOS:"
echo "    brew install wkhtmltopdf"
echo ""
echo "  Then run this script again, or manually:"
echo "    wkhtmltopdf $SITE_DIR/surefire-report.html $PDF_DIR/surefire-report.pdf"
echo "    wkhtmltopdf $SITE_DIR/jacoco/index.html $PDF_DIR/jacoco-coverage-report.pdf"
echo ""
echo "Option 3: Use Python with pdfkit (if wkhtmltopdf is installed)"
echo "    pip install pdfkit"
echo "    python scripts/convert-to-pdf.py"
echo ""

exit 0

