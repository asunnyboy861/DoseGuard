import Foundation
import Combine

enum SyncStatus {
    case disabled
    case syncing
    case synced
    case error(String)
    
    var displayText: String {
        switch self {
        case .disabled: return "iCloud Sync Off"
        case .syncing: return "Syncing..."
        case .synced: return "Synced"
        case .error(let msg): return "Error: \(msg)"
        }
    }
    
    var systemImage: String {
        switch self {
        case .disabled: return "icloud.slash"
        case .syncing: return "icloud.and.arrow.up"
        case .synced: return "checkmark.icloud"
        case .error: return "exclamationmark.icloud"
        }
    }
}

enum SyncPromptReason {
    case addCaregiver
    case shareWithFamily
    case viewSharedData
    
    var title: String {
        switch self {
        case .addCaregiver: return "Enable iCloud Sync?"
        case .shareWithFamily: return "Share with Family?"
        case .viewSharedData: return "Access Shared Data?"
        }
    }
    
    var message: String {
        switch self {
        case .addCaregiver:
            return "To share medication logs with other caregivers, you need to enable iCloud sync. Your data will be securely stored in your iCloud account."
        case .shareWithFamily:
            return "Family sharing requires iCloud sync to be enabled. This allows everyone to see the same medication records."
        case .viewSharedData:
            return "To view shared medication data, please enable iCloud sync."
        }
    }
}

@MainActor
final class SyncService: ObservableObject {
    static let shared = SyncService()
    static let iCloudEnabledDidChange = Notification.Name("iCloudEnabledDidChange")
    
    @Published var iCloudEnabled: Bool {
        didSet {
            UserDefaults.standard.set(iCloudEnabled, forKey: Keys.iCloudEnabled)
            NotificationCenter.default.post(name: Self.iCloudEnabledDidChange, object: nil)
        }
    }
    
    @Published var syncStatus: SyncStatus = .disabled
    
    private init() {
        self.iCloudEnabled = UserDefaults.standard.bool(forKey: Keys.iCloudEnabled)
        updateSyncStatus()
    }
    
    func enableiCloud() {
        iCloudEnabled = true
        PersistenceController.shared.switchToCloudKit()
        updateSyncStatus()
    }
    
    func disableiCloud() {
        iCloudEnabled = false
        PersistenceController.shared.switchToLocal()
        syncStatus = .disabled
    }
    
    func toggleiCloud() {
        if iCloudEnabled {
            disableiCloud()
        } else {
            enableiCloud()
        }
    }
    
    private func updateSyncStatus() {
        guard iCloudEnabled else {
            syncStatus = .disabled
            return
        }
        syncStatus = .synced
    }
    
    func showSyncPrompt(for reason: SyncPromptReason) -> Bool {
        return !iCloudEnabled
    }
}

private enum Keys {
    static let iCloudEnabled = "iCloudEnabled"
}