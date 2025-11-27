import XCTest
@testable import USBCleaner

final class FileScannerTests: XCTestCase {
    var tempDir: URL!
    
    override func setUpWithError() throws {
        // Create a temporary directory for testing
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }
    
    override func tearDownWithError() throws {
        // Clean up
        try FileManager.default.removeItem(at: tempDir)
    }
    
    func testScanFindsDotFiles() throws {
        // Create some files
        let normalFile = tempDir.appendingPathComponent("normal.txt")
        try "content".write(to: normalFile, atomically: true, encoding: .utf8)
        
        let dotFile = tempDir.appendingPathComponent(".hidden")
        try "content".write(to: dotFile, atomically: true, encoding: .utf8)
        
        let dsStore = tempDir.appendingPathComponent(".DS_Store")
        try "content".write(to: dsStore, atomically: true, encoding: .utf8)
        
        let scanner = FileScanner()
        
        // Use expectation because scan is async
        let expectation = XCTestExpectation(description: "Scan completes")
        
        // We need to observe the published property, but for a simple test we can just wait a bit or hook into it.
        // Since FileScanner uses DispatchQueue.main.async, we need to run the run loop or use a slightly different approach for testing.
        // For simplicity in this environment, let's modify FileScanner to have a completion handler or just wait.
        // Actually, let's just wait a bit.
        
        scanner.scan(directory: tempDir)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(scanner.foundFiles.count, 2) // .hidden and .DS_Store
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
