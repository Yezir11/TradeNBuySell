#!/usr/bin/env python3
"""
Convert HTML test reports to PDF using multiple methods.
This script tries different PDF conversion methods in order of preference.
"""

import os
import sys
import subprocess
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).parent
BACKEND_DIR = SCRIPT_DIR.parent
TARGET_DIR = BACKEND_DIR / "target"
SITE_DIR = TARGET_DIR / "site"
PDF_DIR = TARGET_DIR / "pdf-reports"

# Create PDF directory
PDF_DIR.mkdir(parents=True, exist_ok=True)

def check_command(cmd):
    """Check if a command is available."""
    try:
        subprocess.run([cmd, "--version"], 
                      stdout=subprocess.PIPE, 
                      stderr=subprocess.PIPE, 
                      check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def convert_with_wkhtmltopdf(html_file, pdf_file):
    """Convert HTML to PDF using wkhtmltopdf."""
    cmd = [
        "wkhtmltopdf",
        "--page-size", "A4",
        "--orientation", "Portrait",
        "--margin-top", "10mm",
        "--margin-bottom", "10mm",
        "--margin-left", "10mm",
        "--margin-right", "10mm",
        "--enable-local-file-access",
        str(html_file),
        str(pdf_file)
    ]
    subprocess.run(cmd, check=True)
    print(f"✅ Generated: {pdf_file}")

def convert_with_weasyprint(html_file, pdf_file):
    """Convert HTML to PDF using WeasyPrint."""
    try:
        from weasyprint import HTML
        HTML(str(html_file)).write_pdf(str(pdf_file))
        print(f"✅ Generated: {pdf_file}")
        return True
    except ImportError:
        return False

def convert_with_pdfkit(html_file, pdf_file):
    """Convert HTML to PDF using pdfkit (requires wkhtmltopdf)."""
    try:
        import pdfkit
        pdfkit.from_file(str(html_file), str(pdf_file), {
            'page-size': 'A4',
            'orientation': 'Portrait',
            'margin-top': '10mm',
            'margin-bottom': '10mm',
            'margin-left': '10mm',
            'margin-right': '10mm',
            'enable-local-file-access': None
        })
        print(f"✅ Generated: {pdf_file}")
        return True
    except ImportError:
        return False

def main():
    print("📄 Generating PDF reports from HTML test reports...")
    print("")
    
    # Check if HTML reports exist
    surefire_html = SITE_DIR / "surefire-report.html"
    jacoco_html = SITE_DIR / "jacoco" / "index.html"
    
    if not surefire_html.exists():
        print("❌ Surefire report not found. Generating reports first...")
        print("   Run: mvn clean test jacoco:report surefire-report:report")
        sys.exit(1)
    
    # Determine conversion method
    conversion_method = None
    
    if check_command("wkhtmltopdf"):
        conversion_method = "wkhtmltopdf"
        print("✅ Found wkhtmltopdf - using it for PDF conversion")
    elif convert_with_pdfkit(None, None):  # Just check if available
        conversion_method = "pdfkit"
        print("✅ Found pdfkit - using it for PDF conversion")
    elif convert_with_weasyprint(None, None):  # Just check if available
        conversion_method = "weasyprint"
        print("✅ Found WeasyPrint - using it for PDF conversion")
    else:
        print("❌ No PDF conversion tool found.")
        print("")
        print("Please install one of these tools:")
        print("")
        print("Option 1: wkhtmltopdf (Recommended)")
        print("  macOS:  brew install wkhtmltopdf")
        print("  Ubuntu: sudo apt-get install wkhtmltopdf")
        print("  Windows: Download from https://wkhtmltopdf.org/")
        print("")
        print("Option 2: Python libraries")
        print("  pip install pdfkit weasyprint")
        print("  Note: pdfkit requires wkhtmltopdf to be installed")
        print("")
        print("Option 3: Manual conversion")
        print("  Open the HTML files in a browser and use Print > Save as PDF")
        print(f"  - {surefire_html}")
        print(f"  - {jacoco_html}")
        sys.exit(1)
    
    print("")
    
    # Convert Surefire report
    surefire_pdf = PDF_DIR / "surefire-report.pdf"
    if conversion_method == "wkhtmltopdf":
        convert_with_wkhtmltopdf(surefire_html, surefire_pdf)
    elif conversion_method == "pdfkit":
        convert_with_pdfkit(surefire_html, surefire_pdf)
    elif conversion_method == "weasyprint":
        convert_with_weasyprint(surefire_html, surefire_pdf)
    
    # Convert JaCoCo report
    jacoco_pdf = PDF_DIR / "jacoco-coverage-report.pdf"
    if jacoco_html.exists():
        if conversion_method == "wkhtmltopdf":
            convert_with_wkhtmltopdf(jacoco_html, jacoco_pdf)
        elif conversion_method == "pdfkit":
            convert_with_pdfkit(jacoco_html, jacoco_pdf)
        elif conversion_method == "weasyprint":
            convert_with_weasyprint(jacoco_html, jacoco_pdf)
    else:
        print(f"⚠️  JaCoCo report not found: {jacoco_html}")
    
    print("")
    print(f"✅ PDF reports saved to: {PDF_DIR}")
    print(f"   - {surefire_pdf.name}")
    if jacoco_html.exists():
        print(f"   - {jacoco_pdf.name}")

if __name__ == "__main__":
    main()

