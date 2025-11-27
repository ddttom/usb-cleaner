import SwiftUI

struct HelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Help & Support")
                    .font(.headline)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Need help with USBCleaner? We're here to assist you.")
                        .font(.subheadline)
                    
                    // FAQ Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Frequently Asked Questions")
                            .font(.title3)
                            .bold()
                        
                        Text("What files does USBCleaner delete?")
                            .font(.headline)
                        Text("USBCleaner specifically targets:\n• macOS metadata (.DS_Store, ._*)\n• Windows junk (Thumbs.db, Desktop.ini, $RECYCLE.BIN)\n\nIt strictly IGNORES other hidden files like .gitignore, .git, and .vscode to keep your projects safe.")
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Is it safe to delete these files?")
                            .font(.headline)
                        Text("Yes. These files are metadata used by macOS (e.g., to store folder view settings). Deleting them is safe and often necessary when using the drive on non-Apple devices. macOS will simply recreate them if needed when you reconnect the drive.")
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("The app says \"Permission Denied\". What do I do?")
                            .font(.headline)
                        Text("Ensure you have granted USBCleaner permission to access Removable Volumes in your Mac's System Settings > Privacy & Security > Files and Folders.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Divider()
                    
                    // Statistics Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Statistics")
                            .font(.title3)
                            .bold()
                            
                        Text("Lifetime Cleaning Stats:")
                            .font(.headline)
                        
                        HStack {
                            Text("Files Cleaned:")
                            Spacer()
                            Text("\(HistoryManager.shared.totalFilesCleaned)")
                                .bold()
                        }
                        
                        HStack {
                            Text("Space Recovered:")
                            Spacer()
                            Text(ByteCountFormatter.string(fromByteCount: HistoryManager.shared.totalBytesCleaned, countStyle: .file))
                                .bold()
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    
                    Divider()
                    
                    // Contact Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Contact Us")
                            .font(.title3)
                            .bold()
                        
                        Text("If you have other questions or encounter an issue, please reach out to us via email:")
                        
                        Link("support@example.com", destination: URL(string: "mailto:support@example.com")!)
                            .foregroundColor(.blue)
                        
                        Text("We aim to respond to all inquiries within 24-48 hours.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 500)
    }
}
