import SwiftUI

@main
struct PaperMadeApp: App {
    @StateObject private var store = PaperMadeStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        store.reloadSharedSnapshots()
                    }
                }
        }
    }
}
