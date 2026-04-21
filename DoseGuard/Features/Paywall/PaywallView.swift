import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    plansSection
                    termsSection
                    restoreButton
                }
                .padding()
            }
            .navigationTitle("Upgrade to Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if viewModel.isPurchasing {
                    ProgressView()
                        .controlSize(.large)
                        .padding(40)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .alert("Purchase Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            
            Text("Protect Your Child's Health")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Unlock unlimited tracking and safety features")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(PaywallViewModel.proFeatures, id: \.self) { feature in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(feature)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var plansSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.availablePlans, id: \.id) { plan in
                PlanCard(plan: plan, isSelected: viewModel.selectedPlan?.id == plan.id) {
                    viewModel.selectedPlan = plan
                }
            }
            
            Button(action: viewModel.purchaseSelectedPlan) {
                HStack {
                    Spacer()
                    Text(viewModel.selectedPlan?.buttonTitle ?? "Select a Plan")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.selectedPlan == nil || viewModel.isPurchasing)
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 12) {
            Text("Subscription auto-renews unless canceled at least 24 hours before the end of the current period. Cancel anytime in Settings > [Your Name] > Subscriptions.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("Privacy Policy") {
                    openURL(StoreKitManager.PolicyURL.privacyPolicy)
                }
                .font(.caption)
                .foregroundStyle(.blue)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Button("Terms of Use") {
                    openURL(StoreKitManager.PolicyURL.termsOfUse)
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }
        }
        .padding(.top, 8)
    }
    
    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task { await viewModel.restorePurchases() }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.top, 8)
    }
}

#Preview {
    PaywallView()
}