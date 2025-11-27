import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct USBCleanerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .help) {
                Button("USBCleaner Manual") {
                    openWindow(id: "help")
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
        
        WindowGroup(id: "help") {
            HelpView()
        }
    }
}
