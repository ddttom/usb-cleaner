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
                    
                    Group {
                        Text("Frequently Asked Questions")
                            .font(.title3)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What files does USBCleaner delete?")
                                .font(.headline)
                            Text("USBCleaner targets hidden system files created by macOS, such as .DS_Store, ._* resource fork files, and .Trashes. It does not touch your personal documents, photos, or videos.")
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
                    }
                    
                    Divider()
                    
                    Group {
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
