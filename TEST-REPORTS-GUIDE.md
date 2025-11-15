# Test Reports Guide

## 📊 Test Reports Overview

This project generates multiple types of test reports automatically when you run tests. Here's what's available and how to access them.

---

## 📁 Report Locations

### 1. **Maven Surefire Reports** (Basic Text & XML)
**Location:** `backend/target/surefire-reports/`

**Files Generated:**
- `TEST-*.xml` - XML format reports for each test class (for CI/CD integration)
- `*.txt` - Text format summary reports for each test class

**Example:**
```bash
# View text report
cat backend/target/surefire-reports/com.tradenbysell.service.AuthServiceTest.txt

# View XML report (machine-readable)
cat backend/target/surefire-reports/TEST-com.tradenbysell.service.AuthServiceTest.xml
```

**Content:**
- Test execution summary (tests run, failures, errors, skipped)
- Execution time per test
- Test status (passed/failed/error)

---

### 2. **Maven Surefire HTML Report** (Comprehensive HTML)
**Location:** `backend/target/site/surefire-report.html`

**How to Generate:**
```bash
cd backend
mvn test surefire-report:report
```

**How to View:**
```bash
# From project root:
open backend/target/site/surefire-report.html

# Or if you're already in backend/ directory:
cd backend
open target/site/surefire-report.html

# Or on Linux (from backend/)
xdg-open target/site/surefire-report.html

# Or on Windows (from backend/)
start target/site/surefire-report.html
```

**Content:**
- Complete test summary
- Test class breakdown
- Pass/fail statistics
- Execution times
- Links to individual test results

---

### 3. **JaCoCo Code Coverage Report** (HTML, XML, CSV)
**Location:** `backend/target/site/jacoco/`

**Files Generated:**
- `index.html` - **Interactive HTML coverage report** (main report)
- `jacoco.xml` - XML format (for CI/CD integration)
- `jacoco.csv` - CSV format (for spreadsheets)

**How to Generate:**
```bash
cd backend
mvn test jacoco:report
```

**How to View:**
```bash
# From project root:
open backend/target/site/jacoco/index.html

# Or if you're already in backend/ directory:
cd backend
open target/site/jacoco/index.html

# Or on Linux (from backend/)
xdg-open target/site/jacoco/index.html

# Or on Windows (from backend/)
start target/site/jacoco/index.html
```

**Content:**
- Code coverage metrics (line, branch, instruction, method coverage)
- Package-level coverage breakdown
- Class-level coverage details
- **Line-by-line coverage highlighting** (green = covered, red = not covered, yellow = partially covered)
- Coverage trends

**Coverage Metrics Explained:**
- **Line Coverage**: % of executable lines covered
- **Branch Coverage**: % of branches (if/else, switch) covered
- **Instruction Coverage**: % of bytecode instructions covered
- **Method Coverage**: % of methods executed

---

## 🚀 Quick Commands

### Generate All Reports
```bash
cd backend
mvn clean test jacoco:report surefire-report:report
```

This single command:
1. Cleans previous builds
2. Runs all tests
3. Generates JaCoCo coverage reports
4. Generates Surefire HTML reports

### View Reports
```bash
# From project root:
open backend/target/site/surefire-report.html
open backend/target/site/jacoco/index.html

# Or if you're already in backend/ directory:
open target/site/surefire-report.html
open target/site/jacoco/index.html
```

---

## 📈 Understanding the Reports

### Surefire Report Features:
- ✅ **Test Summary**: Overview of all test results
- ✅ **Test Classes**: Individual test class results
- ✅ **Failures & Errors**: Detailed failure messages
- ✅ **Timing**: Execution time per test

### JaCoCo Report Features:
- ✅ **Package Coverage**: See which packages have good coverage
- ✅ **Class Coverage**: Identify classes needing more tests
- ✅ **Line Coverage**: Click on any class to see line-by-line coverage
- ✅ **Missing Coverage**: Red highlighting shows untested code
- ✅ **Coverage Trends**: Track coverage over time

---

## 🎯 Coverage Goals

The project is configured with a minimum coverage threshold:
- **Line Coverage**: 50% minimum (configurable in `pom.xml`)

You can adjust the coverage threshold in `backend/pom.xml`:
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <executions>
        <execution>
            <id>check</id>
            <configuration>
                <rules>
                    <rule>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <minimum>0.50</minimum> <!-- 50% minimum -->
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

---

## 🔄 CI/CD Integration

### XML Reports for CI/CD:
- **Surefire XML**: `target/surefire-reports/TEST-*.xml`
- **JaCoCo XML**: `target/site/jacoco/jacoco.xml`

These XML reports can be parsed by CI/CD tools like:
- Jenkins
- GitHub Actions
- GitLab CI
- Azure DevOps
- CircleCI

---

## 📝 Report Examples

### Current Test Results:
```
Tests run: 25, Failures: 0, Errors: 0, Skipped: 0
✅ AuthServiceTest: 6/6 tests passed
✅ WalletServiceTest: 7/7 tests passed
✅ BidServiceTest: 6/6 tests passed
✅ TradeServiceTest: 6/6 tests passed
```

### Coverage Example:
After running tests, JaCoCo will show:
- Package: `com.tradenbysell.service` - XX% line coverage
- Package: `com.tradenbysell.controller` - XX% line coverage
- Package: `com.tradenbysell.repository` - XX% line coverage

---

## 🛠️ Troubleshooting

### Reports Not Generated?
```bash
# Make sure tests run successfully first
mvn clean test

# Then generate reports
mvn jacoco:report surefire-report:report
```

### HTML Reports Not Opening?
```bash
# Check if files exist
ls -la backend/target/site/surefire-report.html
ls -la backend/target/site/jacoco/index.html

# If missing, regenerate
mvn clean test jacoco:report surefire-report:report
```

### Coverage Report Shows 0%?
- Make sure tests are actually running (check console output)
- Verify tests are executing actual code (not just mocked)
- Check that JaCoCo agent is attached (should happen automatically)

---

## 📚 Additional Resources

- [Maven Surefire Plugin Documentation](https://maven.apache.org/surefire/maven-surefire-plugin/)
- [JaCoCo Documentation](https://www.jacoco.org/jacoco/trunk/doc/)
- [Maven Surefire Report Plugin](https://maven.apache.org/surefire/maven-surefire-report-plugin/)

---

## 📄 PDF Export

You can export test reports to PDF format for easy sharing and archiving.

### Method 1: Browser Print-to-PDF (Easiest, No Installation)

**Step 1:** Open the HTML reports in your browser:
```bash
# From backend/ directory:
open target/site/surefire-report.html
open target/site/jacoco/index.html
```

**Step 2:** Generate PDF:
- Press `Cmd+P` (macOS) or `Ctrl+P` (Windows/Linux)
- In the print dialog, select "Save as PDF"
- Choose location (recommended: `backend/target/pdf-reports/`)
- Click "Save"

**Advantages:**
- ✅ No installation required
- ✅ Works on all platforms
- ✅ Full control over output
- ✅ Preserves formatting

---

### Method 2: Automated Script (Requires Tool Installation)

**Option A: Using wkhtmltopdf (Recommended)**

**Install wkhtmltopdf:**
```bash
# macOS
brew install wkhtmltopdf

# Ubuntu/Debian
sudo apt-get install wkhtmltopdf

# Windows
# Download from: https://wkhtmltopdf.org/downloads.html
```

**Run the conversion script:**
```bash
cd backend
./scripts/generate-pdf-reports.sh
```

Or manually:
```bash
wkhtmltopdf target/site/surefire-report.html target/pdf-reports/surefire-report.pdf
wkhtmltopdf target/site/jacoco/index.html target/pdf-reports/jacoco-coverage-report.pdf
```

**Option B: Using Python Script**

**Install dependencies:**
```bash
pip install pdfkit weasyprint
# Note: pdfkit requires wkhtmltopdf to be installed
```

**Run the script:**
```bash
cd backend
python3 scripts/convert-to-pdf.py
```

---

### Method 3: Maven Goal (Future Enhancement)

You can also add this to your workflow:
```bash
cd backend
mvn clean test jacoco:report surefire-report:report
# Then use one of the methods above to convert to PDF
```

---

### PDF Report Locations

Generated PDFs are saved to:
```
backend/target/pdf-reports/
├── surefire-report.pdf          # Test execution summary
└── jacoco-coverage-report.pdf   # Code coverage report
```

---

### Quick Reference: Generate All Reports + PDFs

```bash
cd backend

# 1. Generate HTML reports
mvn clean test jacoco:report surefire-report:report

# 2. Convert to PDF (choose one):
# Option A: Browser print-to-PDF (see Method 1 above)
# Option B: Automated script
./scripts/generate-pdf-reports.sh
# Option C: Python script
python3 scripts/convert-to-pdf.py
```

---

**Last Updated:** After test implementation
**Report Location:** `backend/target/site/` (HTML) | `backend/target/pdf-reports/` (PDF)

