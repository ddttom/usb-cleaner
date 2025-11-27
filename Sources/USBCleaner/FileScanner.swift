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
    @Published var deepScan = false
    
    private let windowsJunk = ["Thumbs.db", "Desktop.ini", "$RECYCLE.BIN", "System Volume Information"]
    
    func scan(directory: URL) {
        isScanning = true
        statusMessage = "Scanning \(directory.lastPathComponent)..."
        foundFiles = []
        
        let performDeepScan = deepScan
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            var files: [ScannedFile] = []
            
            let options: FileManager.DirectoryEnumerationOptions = performDeepScan ? [] : [.skipsSubdirectoryDescendants]
            
            // Re-create enumerator without skipping hidden files (unless deep scan is off, then we skip subdirs)
            if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey], options: options, errorHandler: nil) {
                
                for case let fileURL as URL in enumerator {
                    let filename = fileURL.lastPathComponent
                    
                    // Check for specific unwanted files
                    let isDSStore = filename == ".DS_Store"
                    let isResourceFork = filename.hasPrefix("._")
                    let isWindowsJunk = self.windowsJunk.contains(where: { filename.caseInsensitiveCompare($0) == .orderedSame })
                    
                    if isDSStore || isResourceFork || isWindowsJunk {
                        
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
                            // We want to delete folders like $RECYCLE.BIN too, so we don't strictly check for isRegularFile if it's a known junk folder
                            // But for simplicity in this version, let's treat everything as a file/item to be removed.
                            // However, FileScanner struct expects size.
                            
                            let size = resourceValues.fileSize ?? 0
                            let scannedFile = ScannedFile(url: fileURL, size: Int64(size))
                            files.append(scannedFile)
                            
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
                // Note: ContentView will need to handle selecting these files, or we can't easily do it here without binding.
                // Alternatively, we can make selectedFiles part of FileScanner or handle it in ContentView's onChange.
            }
        }
    }
    
    func cleanFiles(toDelete: [ScannedFile]) {
        let fileManager = FileManager.default
        var deletedCount = 0
        
        for file in toDelete {
            do {
                try fileManager.removeItem(at: file.url)
                deletedCount += 1
            } catch {
                print("Failed to delete \(file.url): \(error)")
            }
        }
        
        // Remove deleted files from the found list
        foundFiles.removeAll { file in toDelete.contains(file) }
        
        statusMessage = "Cleaned \(deletedCount) files."
    }
}
