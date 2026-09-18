import SwiftUI

@main
struct PaperMadeApp: App {
    @StateObject private var store = PaperMadeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
