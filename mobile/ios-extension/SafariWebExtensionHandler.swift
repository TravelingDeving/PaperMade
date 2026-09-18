import SafariServices
import Foundation

final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    private let suiteName = "group.xyz.papermade.shared"

    func beginRequest(with context: NSExtensionContext) {
        guard
            let item = context.inputItems.first as? NSExtensionItem,
            let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any]
        else {
            reply(context: context, payload: ["ok": false])
            return
        }

        let defaults = UserDefaults(suiteName: suiteName)
        let type = message["type"] as? String ?? ""

        switch type {
        case "PM_NATIVE_PAPER_STATE":
            if let state = message["state"] {
                writeJSON(state, key: "paperStateJSON", defaults: defaults)
            }
            if let sync = message["syncStatus"] {
                writeJSON(sync, key: "syncStatusJSON", defaults: defaults)
            }
            defaults?.set(Date().timeIntervalSince1970, forKey: "paperStateUpdatedAt")
            reply(context: context, payload: ["ok": true])

        case "PM_NATIVE_SYNC_STATUS":
            if let sync = message["syncStatus"] {
                writeJSON(sync, key: "syncStatusJSON", defaults: defaults)
            }
            defaults?.set(Date().timeIntervalSince1970, forKey: "syncStatusUpdatedAt")
            reply(context: context, payload: ["ok": true])

        case "PM_NATIVE_SOCIAL_SNAPSHOT":
            if let snapshot = message["snapshot"] {
                writeJSON(snapshot, key: "socialSnapshotJSON", defaults: defaults)
            }
            defaults?.set(Date().timeIntervalSince1970, forKey: "socialUpdatedAt")
            reply(context: context, payload: ["ok": true])

        case "PM_NATIVE_PULL_STATE":
            let dirty = defaults?.bool(forKey: "nativePaperStateDirty") ?? false
            if dirty,
               let data = defaults?.data(forKey: "paperStateJSON"),
               let object = try? JSONSerialization.jsonObject(with: data) {
                reply(context: context, payload: [
                    "ok": true,
                    "dirty": true,
                    "state": object
                ])
            } else {
                reply(context: context, payload: [
                    "ok": true,
                    "dirty": false
                ])
            }

        case "PM_NATIVE_MARK_SYNCED":
            defaults?.set(false, forKey: "nativePaperStateDirty")
            defaults?.synchronize()
            reply(context: context, payload: ["ok": true])

        default:
            reply(context: context, payload: ["ok": true, "ignored": true])
        }
    }

    private func writeJSON(_ object: Any, key: String, defaults: UserDefaults?) {
        guard JSONSerialization.isValidJSONObject(object) else { return }
        guard let data = try? JSONSerialization.data(withJSONObject: object) else { return }
        defaults?.set(data, forKey: key)
        defaults?.synchronize()
    }

    private func reply(context: NSExtensionContext, payload: [String: Any]) {
        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: payload]
        context.completeRequest(returningItems: [response])
    }
}
