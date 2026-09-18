import Foundation

enum SharedPaperMadeBridge {
    static let suiteName = "group.xyz.papermade.shared"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func paperStateData() -> Data? {
        defaults?.data(forKey: "paperStateJSON")
    }

    static func syncStatusData() -> Data? {
        defaults?.data(forKey: "syncStatusJSON")
    }

    static func socialSnapshotData() -> Data? {
        defaults?.data(forKey: "socialSnapshotJSON")
    }

    static func paperStateUpdatedAt() -> Date? {
        date(forKey: "paperStateUpdatedAt")
    }

    static func socialUpdatedAt() -> Date? {
        date(forKey: "socialUpdatedAt")
    }

    private static func date(forKey key: String) -> Date? {
        let raw = defaults?.double(forKey: key) ?? 0
        return raw > 0 ? Date(timeIntervalSince1970: raw) : nil
    }
}
