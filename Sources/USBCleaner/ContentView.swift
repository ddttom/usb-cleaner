import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = FileScanner()
    @State private var selectedFolder: URL?
    @State private var showHelp = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("USB Cleaner")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                
                Button(action: {
                    showHelp = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Help & Support")
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .sheet(isPresented: $showHelp) {
                HelpView()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Main Content
            VStack(spacing: 20) {
                if let folder = selectedFolder {
                    HStack {
                        Image(systemName: "externaldrive.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(folder.lastPathComponent)
                                .font(.headline)
                            Text(folder.path)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                        
                        Button(action: {
                            selectedFolder = nil
                            scanner.foundFiles = []
                            scanner.statusMessage = "Ready to scan"
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(NSColor.controlBackgroundColor)))
                    
                    if scanner.isScanning {
                        ProgressView("Scanning...")
                            .padding()
                    } else if !scanner.foundFiles.isEmpty {
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
                        .listStyle(.inset)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                        
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
                        
                    } else {
                        if scanner.statusMessage.contains("Cleaned") {
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                    .padding()
                                Text(scanner.statusMessage)
                                    .font(.headline)
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            Button(action: {
                                scanner.scan(directory: folder)
                            }) {
                                Text("Scan Disk")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "externaldrive.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Select a USB Drive to Clean")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Button(action: selectFolder) {
                            Text("Select Disk")
                                .font(.headline)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .padding()
            
            // Footer
            HStack {
                Text(scanner.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(10)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
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
}
