import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultWeightUnit") private var defaultWeightUnit = "kg"
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("duplicateDoseAlert") private var duplicateDoseAlert = true
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    @ObservedObject private var syncService = SyncService.shared
    
    var body: some View {
        NavigationStack {
            List {
                subscriptionSection
                iCloudSection
                preferencesSection
                notificationsSection
                safetySection
                aboutSection
                supportSection
            }
            .navigationTitle("Settings")
        }
    }
    
    private var subscriptionSection: some View {
        Section {
            NavigationLink(destination: SubscriptionSettingsView()) {
                HStack {
                    Label("Subscription", systemImage: "crown.fill")
                        .foregroundStyle(.orange)
                    Spacer()
                    if subscriptionService.currentTier.isPro {
                        ProBadge()
                    } else {
                        Text("Free")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private var iCloudSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { syncService.iCloudEnabled },
                set: { _ in syncService.toggleiCloud() }
            )) {
                HStack {
                    Label("iCloud Sync", systemImage: "icloud")
                        .foregroundStyle(.blue)
                    Spacer()
                    if syncService.iCloudEnabled {
                        SyncStatusBadge(status: syncService.syncStatus)
                    }
                }
            }
            
            if syncService.iCloudEnabled {
                HStack {
                    Text("Sync Status")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(syncService.syncStatus.displayText)
                        .font(.subheadline)
                }
            }
        } header: {
            Text("Data Sync")
        } footer: {
            Text("Enable iCloud to sync medication data across devices and share with other caregivers.")
        }
    }
    
    private var preferencesSection: some View {
        Section(header: Text("Preferences")) {
            Picker("Default Weight Unit", selection: $defaultWeightUnit) {
                Text("Kilograms (kg)").tag("kg")
                Text("Pounds (lb)").tag("lb")
            }
        }
    }
    
    private var notificationsSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Enable Reminders", isOn: $enableNotifications)
        }
    }
    
    private var safetySection: some View {
        Section(header: Text("Safety")) {
            Toggle("Duplicate Dose Alert", isOn: $duplicateDoseAlert)
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
            LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
        }
    }
    
    private var supportSection: some View {
        Section(header: Text("Support")) {
            NavigationLink(destination: ContactSupportView()) {
                Label("Contact Support", systemImage: "envelope.fill")
            }
            
            Link(destination: URL(string: "https://asunnyboy861.github.io/DoseGuard-support/")!) {
                Label("Support Page", systemImage: "questionmark.circle")
            }
            .tint(.primary)
            
            Link(destination: URL(string: "https://asunnyboy861.github.io/DoseGuard-pravicy/")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            .tint(.primary)
            
            Link(destination: URL(string: "https://asunnyboy861.github.io/DoseGuard-terms/")!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
            .tint(.primary)
        }
    }
}