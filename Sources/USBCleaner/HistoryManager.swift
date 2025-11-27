import Foundation

class HistoryManager: ObservableObject {
    @Published var totalFilesCleaned: Int = 0
    @Published var totalBytesCleaned: Int64 = 0
    
    static let shared = HistoryManager()
    
    private init() {
        totalFilesCleaned = UserDefaults.standard.integer(forKey: "totalFilesCleaned")
        totalBytesCleaned = Int64(UserDefaults.standard.integer(forKey: "totalBytesCleaned"))
    }
    
    func addCleaned(files: Int, bytes: Int64) {
        totalFilesCleaned += files
        totalBytesCleaned += bytes
        
        UserDefaults.standard.set(totalFilesCleaned, forKey: "totalFilesCleaned")
        UserDefaults.standard.set(Int(totalBytesCleaned), forKey: "totalBytesCleaned")
    }
}
