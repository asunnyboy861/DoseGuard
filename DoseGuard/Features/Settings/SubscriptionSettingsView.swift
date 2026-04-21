import SwiftUI

struct SubscriptionSettingsView: View {
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall = false
    
    var body: some View {
        List {
            currentPlanSection
            if !subscriptionService.currentTier.isPro {
                upgradeSection
            }
            manageSection
        }
        .navigationTitle("Subscription")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private var currentPlanSection: some View {
        Section(header: Text("Current Plan")) {
            HStack {
                Image(systemName: subscriptionService.currentTier.isPro ? "checkmark.seal.fill" : "star")
                    .foregroundStyle(subscriptionService.currentTier.isPro ? .green : .secondary)
                
                VStack(alignment: .leading) {
                    Text(subscriptionService.currentTier.isPro ? "DoseGuard Pro" : "Free Plan")
                        .font(.headline)
                    Text(subscriptionService.currentTier.isPro ? "All features unlocked" : "Limited features")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if subscriptionService.currentTier.isPro {
                    ProBadge()
                }
            }
        }
    }
    
    private var upgradeSection: some View {
        Section {
            Button(action: { showPaywall = true }) {
                HStack {
                    Spacer()
                    Label("Upgrade to Pro", systemImage: "sparkles")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .listRowBackground(Color.accentColor)
            .tint(.white)
        }
    }
    
    private var manageSection: some View {
        Section(header: Text("Manage")) {
            Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                Label("Manage Subscription", systemImage: "gearshape")
            }
            .tint(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionSettingsView()
    }
}