import Foundation
import AppKit

struct ClipboardItem: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
}

class ClipboardManager: ObservableObject {
    @Published var history: [ClipboardItem] = []
    @Published var isRecording = false
    private var lastChangeCount: Int
    private var timer: Timer?
    
    init() {
        lastChangeCount = NSPasteboard.general.changeCount
        startMonitoring()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    private func checkForChanges() {
        guard isRecording else { return }
        
        let currentChangeCount = NSPasteboard.general.changeCount
        guard currentChangeCount != lastChangeCount else { return }
        
        lastChangeCount = currentChangeCount
        
        if let newString = NSPasteboard.general.string(forType: .string) {
            DispatchQueue.main.async {
                let newItem = ClipboardItem(content: newString, timestamp: Date())
                self.history.append(newItem)
                
                if self.history.count > 50 {
                    self.history.removeFirst()
                }
            }
        }
    }
    
    func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            lastChangeCount = NSPasteboard.general.changeCount
        }
    }
    
    func clearHistory() {
        history.removeAll()
    }
    
    deinit {
        timer?.invalidate()
    }
} 