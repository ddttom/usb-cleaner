# CLAUDE.md - AI Assistant Context for USBCleaner

## 1. Project Overview

**USBCleaner** is a lightweight macOS utility application that helps users maintain clean USB drives and external storage devices by identifying and removing hidden system files and macOS artifacts.

### Purpose
- Scans USB drives and folders for hidden files (`.DS_Store`, `._*`, and other dot files)
- Provides one-click deletion of clutter that accumulates on non-Mac file systems
- Helps users share USB drives cleanly across multiple operating systems

### Technology Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Reactive Framework**: Combine (@Published properties)
- **System APIs**: Foundation (FileManager, URL, DispatchQueue), AppKit (NSOpenPanel)
- **Build System**: Swift Package Manager
- **Testing**: XCTest
- **Platform**: macOS 11.0 (Big Sur) or later
- **Architectures**: Universal binary (ARM64 + x86_64)

### Key Characteristics
- Privacy-first (no telemetry, no analytics, no network calls)
- Lightweight (< 100 lines per file)
- User-initiated operations only
- No elevated privileges required

---

## 2. Architecture & Design Patterns

### MVVM Pattern
The application follows the Model-View-ViewModel pattern with clear separation of concerns:

```
┌─────────────────┐
│  USBCleanerApp  │  Entry point, window configuration
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  ContentView    │  View Layer - UI and user interactions
│  (View)         │  - State: @StateObject, @State
└────────┬────────┘  - Presents UI based on scanner state
         │
         │ observes
         ▼
┌─────────────────┐
│  FileScanner    │  ViewModel - Business logic
│  (ViewModel)    │  - @Published properties notify view
└────────┬────────┘  - Async operations, file management
         │
         │ contains
         ▼
┌─────────────────┐
│  ScannedFile    │  Model - Data representation
│  (Model)        │  - Identifiable, Hashable
└─────────────────┘
```

### Data Flow
1. **User Action** → ContentView receives interaction
2. **View calls ViewModel** → `scanner.scan(directory:)` or `scanner.cleanFiles()`
3. **ViewModel processes** → Background thread for I/O operations
4. **ViewModel updates @Published properties** → On main thread
5. **View automatically re-renders** → SwiftUI observes changes

### Threading Model
- **Main Thread**: All UI updates, @Published property mutations
- **Background Thread**: File scanning (`.userInitiated` QoS), file enumeration
- **Pattern**: Global queue → do work → main queue → update UI

Example from [FileScanner.swift:27-62](Sources/USBCleaner/FileScanner.swift#L27-L62):
```swift
func scan(directory: URL) {
    isScanning = true  // Main thread
    statusMessage = "Scanning..."

    DispatchQueue.global(qos: .userInitiated).async {
        // Heavy I/O work on background thread
        let files = /* scan files */

        DispatchQueue.main.async {
            // Update UI on main thread
            self.foundFiles = files
            self.isScanning = false
        }
    }
}
```

---

## 3. Codebase Structure

```
usb-cleaner/
├── Sources/USBCleaner/           # Main application code
│   ├── USBCleanerApp.swift       # App entry point (12 lines)
│   ├── ContentView.swift         # Main UI (160 lines)
│   └── FileScanner.swift         # Business logic (82 lines)
├── Tests/USBCleanerTests/        # Unit tests
│   └── FileScannerTests.swift    # Scanner tests (49 lines)
├── Package.swift                 # SPM manifest
├── build.sh                      # Universal build script
├── package_app.sh                # App bundle creator
├── docs/                         # Website (HTML/CSS)
├── AppStore/                     # App Store metadata
├── .github/                      # CI/CD, templates, guidelines
└── .vscode/                      # VS Code configuration
```

### File Responsibilities

| File | Responsibility | Key Elements |
|------|----------------|--------------|
| `USBCleanerApp.swift` | App entry point | `@main`, WindowGroup, window styling |
| `ContentView.swift` | UI/UX, user interactions | View states, folder selection, UI rendering |
| `FileScanner.swift` | File scanning, deletion | `@Published` state, async operations |
| `FileScannerTests.swift` | Unit tests | Test setup, async testing patterns |

---

## 4. Key Components

### 4.1 USBCleanerApp - Entry Point

**Location**: [Sources/USBCleaner/USBCleanerApp.swift](Sources/USBCleaner/USBCleanerApp.swift)

The main entry point configures the app window and presents the root view.

```swift
import SwiftUI

@main
struct USBCleanerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
```

**Key Points**:
- `@main` attribute marks the entry point
- `WindowGroup` creates a standard macOS window
- `HiddenTitleBarWindowStyle()` provides a modern, frameless look
- No configuration, state management, or business logic here

---

### 4.2 ContentView - View Layer

**Location**: [Sources/USBCleaner/ContentView.swift](Sources/USBCleaner/ContentView.swift)

The main view implements a state machine with multiple UI states.

#### State Management
```swift
@StateObject private var scanner = FileScanner()
@State private var selectedFolder: URL?
```

- `@StateObject`: Owns the FileScanner lifecycle, survives view updates
- `@State`: Tracks UI-specific state (selected folder)

#### UI State Machine

The view renders different UIs based on state:

| State | Condition | UI Shown |
|-------|-----------|----------|
| **Initial** | `selectedFolder == nil` | "Select a USB Drive" screen |
| **Selected** | `selectedFolder != nil && !scanning && files.isEmpty` | Folder info + "Scan Disk" button |
| **Scanning** | `scanner.isScanning == true` | Progress indicator |
| **Results** | `!scanner.foundFiles.isEmpty` | File list + "Clean N Files" button |
| **Completed** | `statusMessage.contains("Cleaned")` | Success checkmark |

#### Folder Selection Pattern

**Location**: [ContentView.swift:148-159](Sources/USBCleaner/ContentView.swift#L148-L159)

```swift
func selectFolder() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.prompt = "Select USB Drive"

    if panel.runModal() == .OK {
        selectedFolder = panel.url
        scanner.statusMessage = "Selected \(panel.url?.lastPathComponent ?? "")"
    }
}
```

**Key Points**:
- Uses AppKit's `NSOpenPanel` for native folder picker
- Directories only (`canChooseFiles = false`)
- Modal presentation blocks until user selects or cancels
- Updates `@State` variable, triggering view re-render

#### File List Display

**Location**: [ContentView.swift:55-68](Sources/USBCleaner/ContentView.swift#L55-L68)

```swift
List(scanner.foundFiles) { file in
    HStack {
        Image(systemName: "doc.fill")
            .foregroundColor(.secondary)
        Text(file.name)
        Spacer()
        Text(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
```

**Key Points**:
- `List` automatically iterates `Identifiable` items
- `ByteCountFormatter` converts bytes to human-readable format (e.g., "24 KB")
- SF Symbols (`doc.fill`) provide consistent iconography

---

### 4.3 FileScanner - Business Logic

**Location**: [Sources/USBCleaner/FileScanner.swift](Sources/USBCleaner/FileScanner.swift)

#### ScannedFile Model

**Location**: [FileScanner.swift:3-15](Sources/USBCleaner/FileScanner.swift#L3-L15)

```swift
struct ScannedFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let size: Int64

    var path: String {
        url.path
    }

    var name: String {
        url.lastPathComponent
    }
}
```

**Key Points**:
- `Identifiable`: Required for SwiftUI `List`
- `Hashable`: Enables set operations, equality checks
- Computed properties avoid storing redundant data
- `UUID()` provides stable identity across updates

#### FileScanner Class

**Location**: [FileScanner.swift:17-81](Sources/USBCleaner/FileScanner.swift#L17-L81)

```swift
class FileScanner: ObservableObject {
    @Published var foundFiles: [ScannedFile] = []
    @Published var isScanning = false
    @Published var statusMessage = "Ready to scan"

    // ... methods
}
```

**Key Points**:
- `ObservableObject`: Protocol for Combine integration
- `@Published`: Automatically notifies SwiftUI of changes
- All properties mutable (var), updated during operations

#### Scanning Implementation

**Location**: [FileScanner.swift:22-63](Sources/USBCleaner/FileScanner.swift#L22-L63)

```swift
func scan(directory: URL) {
    isScanning = true
    statusMessage = "Scanning \(directory.lastPathComponent)..."
    foundFiles = []

    DispatchQueue.global(qos: .userInitiated).async {
        let fileManager = FileManager.default
        var files: [ScannedFile] = []

        // Create enumerator WITHOUT skipping hidden files
        if let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [],  // Empty options = include hidden files
            errorHandler: nil
        ) {
            for case let fileURL as URL in enumerator {
                let filename = fileURL.lastPathComponent

                // Filter: starts with "." but not "." or ".."
                if filename.hasPrefix(".") && filename != "." && filename != ".." {
                    do {
                        let resourceValues = try fileURL.resourceValues(
                            forKeys: [.fileSizeKey, .isRegularFileKey]
                        )

                        // Only include regular files (not directories)
                        if let isRegularFile = resourceValues.isRegularFile,
                           isRegularFile {
                            let size = resourceValues.fileSize ?? 0
                            let scannedFile = ScannedFile(
                                url: fileURL,
                                size: Int64(size)
                            )
                            files.append(scannedFile)
                        }
                    } catch {
                        print("Error reading attributes for \(fileURL): \(error)")
                    }
                }
            }
        }

        // Update UI on main thread
        DispatchQueue.main.async {
            self.foundFiles = files
            self.isScanning = false
            self.statusMessage = "Found \(files.count) files."
        }
    }
}
```

**Critical Details**:
1. **Empty options array**: `options: []` ensures hidden files are included
2. **Prefix check**: `filename.hasPrefix(".")` catches `.DS_Store`, `._file`, etc.
3. **Regular files only**: `isRegularFile` excludes directories like `.Trash/`
4. **Resource values**: Efficient way to get metadata without separate syscalls
5. **Error handling**: Prints errors but continues scanning
6. **Thread safety**: Builds array on background, updates @Published on main

#### Deletion Implementation

**Location**: [FileScanner.swift:65-80](Sources/USBCleaner/FileScanner.swift#L65-L80)

```swift
func cleanFiles() {
    let fileManager = FileManager.default
    var deletedCount = 0

    for file in foundFiles {
        do {
            try fileManager.removeItem(at: file.url)
            deletedCount += 1
        } catch {
            print("Failed to delete \(file.url): \(error)")
        }
    }

    foundFiles = []
    statusMessage = "Cleaned \(deletedCount) files."
}
```

**Key Points**:
- Runs synchronously (fast enough for typical USB cleaning)
- Counts successes separately from attempts
- Clears `foundFiles` immediately after deletion
- Non-fatal errors: prints and continues

---

### 4.4 Testing Approach

**Location**: [Tests/USBCleanerTests/FileScannerTests.swift](Tests/USBCleanerTests/FileScannerTests.swift)

#### Test Structure
```swift
final class FileScannerTests: XCTestCase {
    var tempDir: URL!

    override func setUpWithError() throws {
        // Create temporary directory
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        // Clean up
        try FileManager.default.removeItem(at: tempDir)
    }
}
```

#### Async Testing Pattern

**Location**: [FileScannerTests.swift:18-47](Tests/USBCleanerTests/FileScannerTests.swift#L18-L47)

```swift
func testScanFindsDotFiles() throws {
    // Arrange: Create test files
    let normalFile = tempDir.appendingPathComponent("normal.txt")
    try "content".write(to: normalFile, atomically: true, encoding: .utf8)

    let dotFile = tempDir.appendingPathComponent(".hidden")
    try "content".write(to: dotFile, atomically: true, encoding: .utf8)

    let dsStore = tempDir.appendingPathComponent(".DS_Store")
    try "content".write(to: dsStore, atomically: true, encoding: .utf8)

    let scanner = FileScanner()

    // Act: Perform scan
    let expectation = XCTestExpectation(description: "Scan completes")
    scanner.scan(directory: tempDir)

    // Assert: Check results after async operation
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        XCTAssertEqual(scanner.foundFiles.count, 2) // .hidden and .DS_Store
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 2.0)
}
```

**Key Testing Patterns**:
1. **Arrange-Act-Assert**: Clear test structure
2. **XCTestExpectation**: Handle async operations
3. **Temporary directories**: Isolated, no side effects
4. **Setup/Teardown**: Consistent test environment
5. **Timeout**: Fail-safe for hanging operations

---

## 5. Development Workflow

### Building the Project

**Script**: [build.sh](build.sh)

```bash
swift build -c release --arch arm64 --arch x86_64
```

- **Universal binary**: Single executable runs on both Apple Silicon and Intel
- **Release configuration**: Optimized, stripped debug symbols
- **Output**: `.build/release/USBCleaner`

### Packaging the App

**Script**: [package_app.sh](package_app.sh)

Creates a macOS `.app` bundle:
1. Creates directory structure: `USBCleaner.app/Contents/MacOS/`
2. Copies executable
3. Generates `Info.plist` with:
   - Bundle identifier: `com.example.USBCleaner`
   - Minimum macOS version: 11.0
   - High-resolution support enabled

### Running Tests

```bash
swift test
```

Or use VS Code launch configurations:
- **Debug Build**: Fast iteration, includes symbols
- **Release Build**: Production-like testing

### VS Code Integration

**Configuration**: [.vscode/settings.json](.vscode/settings.json), [.vscode/launch.json](.vscode/launch.json)

- Swift extension support
- Debugging configurations
- Integrated test runner

---

## 6. Code Conventions & Best Practices

### Swift Style
- **Naming**: Clear, descriptive names (`selectedFolder`, not `folder`)
- **Access control**: Implicitly internal (no explicit modifiers needed)
- **Force unwrapping**: Avoided; use optional binding or `??`
- **Error handling**: Do-catch for expected errors, print for non-fatal issues

### SwiftUI Patterns
- **State ownership**: `@StateObject` for owned objects, `@State` for value types
- **View decomposition**: Keep views under 200 lines; extract complex logic
- **Spacing**: Explicit spacing parameters (`VStack(spacing: 20)`)
- **Button styles**: `.buttonStyle(.plain)` for custom-styled buttons

### Threading Rules
```swift
// ✅ CORRECT
DispatchQueue.global(qos: .userInitiated).async {
    let result = heavyWork()
    DispatchQueue.main.async {
        self.publishedProperty = result
    }
}

// ❌ INCORRECT - updating @Published off main thread
DispatchQueue.global(qos: .userInitiated).async {
    self.publishedProperty = heavyWork()  // Crash or unpredictable behavior
}
```

### Error Handling Philosophy
- **Print and continue**: For non-critical errors (single file deletion fails)
- **Silent failures**: Acceptable for user-initiated, non-critical operations
- **No alerts**: Keep UI simple; status message provides feedback

### File Organization
- **One type per file**: `ScannedFile` exception (small, related to FileScanner)
- **Imports**: Only what's needed (avoid `import Cocoa` when `AppKit` suffices)
- **Extension groups**: Not used (small files don't need grouping)

---

## 7. Common Tasks & How to Implement Them

### 7.1 Adding a New File Type to Scan

**Goal**: Also scan for `Thumbs.db` (Windows thumbnail cache)

**Location to modify**: [FileScanner.swift:39](Sources/USBCleaner/FileScanner.swift#L39)

```swift
// BEFORE
if filename.hasPrefix(".") && filename != "." && filename != ".." {
    // scan logic
}

// AFTER
if (filename.hasPrefix(".") && filename != "." && filename != "..") ||
   filename == "Thumbs.db" {
    // scan logic
}
```

**Alternative approach** (multiple unwanted files):
```swift
let unwantedFiles: Set<String> = [
    "Thumbs.db",
    "desktop.ini",
    ".DS_Store"
]

if filename.hasPrefix(".") || unwantedFiles.contains(filename) {
    // scan logic
}
```

---

### 7.2 Adding New UI States

**Goal**: Add a "Preview Mode" that shows files without allowing deletion

**Step 1**: Add state variable to ContentView
```swift
@State private var isPreviewMode = false
```

**Step 2**: Add toggle in UI
```swift
Toggle("Preview Mode", isOn: $isPreviewMode)
    .padding()
```

**Step 3**: Conditionally show clean button

**Location**: [ContentView.swift:70-81](Sources/USBCleaner/ContentView.swift#L70-L81)

```swift
if !isPreviewMode {
    Button(action: {
        scanner.cleanFiles()
    }) {
        Text("Clean \(scanner.foundFiles.count) Files")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    .buttonStyle(.plain)
}
```

---

### 7.3 Enhancing the File Display

**Goal**: Show file modification date alongside size

**Step 1**: Add property to ScannedFile

**Location**: [FileScanner.swift:3-15](Sources/USBCleaner/FileScanner.swift#L3-L15)

```swift
struct ScannedFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let size: Int64
    let modificationDate: Date  // NEW

    // ... rest of struct
}
```

**Step 2**: Fetch modification date during scan

**Location**: [FileScanner.swift:44](Sources/USBCleaner/FileScanner.swift#L44)

```swift
// BEFORE
let resourceValues = try fileURL.resourceValues(
    forKeys: [.fileSizeKey, .isRegularFileKey]
)

// AFTER
let resourceValues = try fileURL.resourceValues(
    forKeys: [.fileSizeKey, .isRegularFileKey, .contentModificationDateKey]
)

// Later, when creating ScannedFile:
let modDate = resourceValues.contentModificationDate ?? Date()
let scannedFile = ScannedFile(
    url: fileURL,
    size: Int64(size),
    modificationDate: modDate
)
```

**Step 3**: Update UI to display date

**Location**: [ContentView.swift:56-66](Sources/USBCleaner/ContentView.swift#L56-L66)

```swift
List(scanner.foundFiles) { file in
    HStack {
        Image(systemName: "doc.fill")
            .foregroundColor(.secondary)
        VStack(alignment: .leading) {
            Text(file.name)
            Text(file.modificationDate, style: .date)  // NEW
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        Spacer()
        Text(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
```

---

### 7.4 Adding New Tests

**Template for new test**:

```swift
func testNewFeature() throws {
    // Arrange: Set up test data
    let testFile = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: testFile, atomically: true, encoding: .utf8)

    let scanner = FileScanner()

    // Act: Perform operation
    let expectation = XCTestExpectation(description: "Operation completes")
    scanner.someAsyncOperation(testFile)

    // Assert: Verify results
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        XCTAssertEqual(scanner.someProperty, expectedValue)
        XCTAssertTrue(scanner.someCondition)
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
}
```

**Testing synchronous operations**:
```swift
func testCleanFiles() throws {
    // Arrange
    let file = tempDir.appendingPathComponent(".hidden")
    try "content".write(to: file, atomically: true, encoding: .utf8)

    let scanner = FileScanner()
    scanner.foundFiles = [ScannedFile(url: file, size: 100)]

    // Act
    scanner.cleanFiles()

    // Assert
    XCTAssertEqual(scanner.foundFiles.count, 0)
    XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
    XCTAssertTrue(scanner.statusMessage.contains("Cleaned"))
}
```

---

## 8. Important Considerations for AI Assistants

### Privacy & Security
- **NO network calls**: App is 100% local
- **NO telemetry**: No analytics, crash reporting, or usage tracking
- **NO data collection**: App never sends data anywhere
- **User consent**: All operations require explicit user action
- **Sandboxed permissions**: Only accesses user-selected directories

### macOS-Specific APIs
- **NSOpenPanel**: AppKit component for folder selection (not UIKit)
- **FileManager**: Foundation's cross-platform file API
- **SwiftUI**: Modern UI framework (not AppKit views)
- **SF Symbols**: Apple's icon system (`Image(systemName:)`)

### File Safety Constraints
```swift
// ✅ SAFE: Only deletes files starting with "."
if filename.hasPrefix(".") { /* delete */ }

// ❌ DANGEROUS: Don't add patterns that could match user files
if filename.contains(".") { /* TOO BROAD */ }

// ❌ DANGEROUS: Don't delete directories
if isDirectory { /* delete */ }  // Could wipe .git/, etc.
```

### Threading Gotchas
```swift
// ❌ INCORRECT: Race condition
DispatchQueue.global().async {
    self.foundFiles.append(file)  // Multiple threads writing
}

// ✅ CORRECT: Collect then update once
DispatchQueue.global().async {
    var localFiles: [ScannedFile] = []
    // ... build array
    DispatchQueue.main.async {
        self.foundFiles = localFiles  // Single write on main thread
    }
}
```

### State Management Rules
1. **@StateObject**: Use for `ObservableObject` instances the view creates
2. **@ObservedObject**: Use for objects passed in from parent
3. **@State**: Use for simple value types (Bool, String, Int, etc.)
4. **@Published**: Must be mutated on main thread if observed by UI

### When to Use Background Threads
- **File enumeration**: Can take seconds for large drives
- **File deletion**: Usually fast, but batch operations benefit
- **Resource value fetching**: I/O-bound operations

### When to Stay on Main Thread
- **UI updates**: Always
- **@Published mutations**: When observed by SwiftUI
- **User interactions**: Button actions start on main thread
- **Quick operations**: Sub-millisecond tasks (array manipulation, etc.)

---

## 9. Build & Distribution

### Universal Binary Approach

**Why**: Support both Apple Silicon (M1/M2/M3) and Intel Macs with one executable

**How**: Swift's `--arch` flag compiles for multiple architectures
```bash
swift build --arch arm64 --arch x86_64
```

**Result**: "Universal 2" binary that macOS automatically runs natively

### Swift Package Manager Configuration

**File**: [Package.swift](Package.swift)

```swift
let package = Package(
    name: "USBCleaner",
    platforms: [
        .macOS(.v11)  // Minimum Big Sur
    ],
    products: [
        .executable(
            name: "USBCleaner",
            targets: ["USBCleaner"]
        ),
    ],
    targets: [
        .executableTarget(name: "USBCleaner"),
        .testTarget(
            name: "USBCleanerTests",
            dependencies: ["USBCleaner"]
        ),
    ]
)
```

**Key elements**:
- `platforms`: Enforces minimum macOS version
- `executable` product: Creates runnable app (not library)
- Test target dependency: Links against main target for testing

### Info.plist Requirements

**Generated by**: [package_app.sh](package_app.sh)

```xml
<key>CFBundleExecutable</key>
<string>USBCleaner</string>

<key>CFBundleIdentifier</key>
<string>com.example.USBCleaner</string>

<key>LSMinimumSystemVersion</key>
<string>11.0</string>

<key>NSHighResolutionCapable</key>
<true/>
```

**Important keys**:
- `CFBundleExecutable`: Must match binary name
- `CFBundleIdentifier`: Reverse DNS, unique identifier
- `LSMinimumSystemVersion`: Blocks launch on older macOS
- `NSHighResolutionCapable`: Enables Retina rendering

### Code Signing Considerations

**Current state**: Unsigned app

**User experience**:
1. First launch: "App can't be opened" error
2. User must right-click → Open → confirm

**To properly sign**:
1. Enroll in Apple Developer Program ($99/year)
2. Create Developer ID Application certificate
3. Sign: `codesign --sign "Developer ID" USBCleaner.app`
4. Notarize: `xcrun notarytool submit USBCleaner.zip`

**AI Assistants**: Don't add signing steps unless user explicitly requests

---

## 10. Quick Reference

### File Locations
```
Sources/USBCleaner/
├── USBCleanerApp.swift    # Entry point, window config
├── ContentView.swift      # Main UI, state machine
└── FileScanner.swift      # Scanning/deletion logic

Tests/USBCleanerTests/
└── FileScannerTests.swift # Unit tests

Build:
├── build.sh               # Compile universal binary
├── package_app.sh         # Create .app bundle
└── Package.swift          # SPM manifest
```

### Key Files & Line Numbers

| Task | File & Lines |
|------|--------------|
| File filtering logic | [FileScanner.swift:39-54](Sources/USBCleaner/FileScanner.swift#L39-L54) |
| UI state machine | [ContentView.swift:23-108](Sources/USBCleaner/ContentView.swift#L23-L108) |
| Folder selection | [ContentView.swift:148-159](Sources/USBCleaner/ContentView.swift#L148-L159) |
| Async scanning pattern | [FileScanner.swift:27-62](Sources/USBCleaner/FileScanner.swift#L27-L62) |
| File deletion | [FileScanner.swift:65-80](Sources/USBCleaner/FileScanner.swift#L65-L80) |
| Test setup/teardown | [FileScannerTests.swift:7-16](Tests/USBCleanerTests/FileScannerTests.swift#L7-L16) |
| Async test pattern | [FileScannerTests.swift:32-46](Tests/USBCleanerTests/FileScannerTests.swift#L32-L46) |

### Common Patterns

#### Threading Pattern
```swift
DispatchQueue.global(qos: .userInitiated).async {
    // Heavy I/O work
    let result = performWork()

    DispatchQueue.main.async {
        // Update UI
        self.publishedProperty = result
    }
}
```

#### State Management
```swift
// In view
@StateObject private var scanner = FileScanner()
@State private var selectedFolder: URL?

// In view model
class FileScanner: ObservableObject {
    @Published var foundFiles: [ScannedFile] = []
    @Published var isScanning = false
}
```

#### File Enumeration
```swift
let enumerator = fileManager.enumerator(
    at: directory,
    includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
    options: [],
    errorHandler: nil
)

for case let fileURL as URL in enumerator {
    // Process each file
}
```

#### Resource Values (Efficient Metadata)
```swift
let resourceValues = try fileURL.resourceValues(
    forKeys: [.fileSizeKey, .isRegularFileKey, .contentModificationDateKey]
)

let size = resourceValues.fileSize ?? 0
let isFile = resourceValues.isRegularFile ?? false
let modDate = resourceValues.contentModificationDate ?? Date()
```

#### Async Testing
```swift
let expectation = XCTestExpectation(description: "Operation completes")

performAsyncOperation()

DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    XCTAssertEqual(result, expected)
    expectation.fulfill()
}

wait(for: [expectation], timeout: 2.0)
```

### Quick Commands

```bash
# Build
./build.sh

# Package
./package_app.sh

# Run
./.build/release/USBCleaner

# Test
swift test

# Clean build
rm -rf .build
```

### Debugging Tips

1. **UI not updating**: Check if @Published mutation is on main thread
2. **Files not found**: Verify `options: []` in enumerator (includes hidden)
3. **Test fails intermittently**: Increase timeout or check async timing
4. **App won't launch**: Verify Info.plist `CFBundleExecutable` matches binary name
5. **Memory issues**: Check for retain cycles in closures (use `[weak self]`)

---

## Summary

USBCleaner is a well-architected, lightweight macOS utility demonstrating:
- Clean MVVM separation
- Proper threading patterns
- SwiftUI best practices
- Privacy-first design
- Universal binary support

When modifying this codebase:
1. Maintain the threading discipline (background I/O, main thread UI updates)
2. Keep files small and focused
3. Test async operations properly
4. Preserve the privacy-first philosophy (no network, no tracking)
5. Use explicit state management (@Published, @State, @StateObject)

For questions or contributions, see [CONTRIBUTING.md](.github/CONTRIBUTING.md).
