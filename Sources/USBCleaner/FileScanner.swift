import Foundation

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

class FileScanner: ObservableObject {
    @Published var foundFiles: [ScannedFile] = []
    @Published var isScanning = false
    @Published var statusMessage = "Ready to scan"
    
    func scan(directory: URL) {
        isScanning = true
        statusMessage = "Scanning \(directory.lastPathComponent)..."
        foundFiles = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            var files: [ScannedFile] = []
            
            // Re-create enumerator without skipping hidden files
            if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey], options: [], errorHandler: nil) {
                
                for case let fileURL as URL in enumerator {
                    let filename = fileURL.lastPathComponent
                    
                    // Check if it starts with '.' and is not just "." or ".." (though enumerator usually handles . and ..)
                    // Also ignore .Trash or system folders if we are scanning a root
                    if filename.hasPrefix(".") && filename != "." && filename != ".." {
                        
                        // Optional: Filter out specific system directories if needed, but for USB cleaner, we usually want to clean .DS_Store, ._*, etc.
                        
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
                            if let isRegularFile = resourceValues.isRegularFile, isRegularFile {
                                let size = resourceValues.fileSize ?? 0
                                let scannedFile = ScannedFile(url: fileURL, size: Int64(size))
                                files.append(scannedFile)
                            }
                        } catch {
                            print("Error reading attributes for \(fileURL): \(error)")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.foundFiles = files
                self.isScanning = false
                self.statusMessage = "Found \(files.count) files."
            }
        }
    }
    
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
}
