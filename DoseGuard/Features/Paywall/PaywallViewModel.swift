import SwiftUI
import StoreKit

struct PaywallPlan: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let product: Product
    let displayPrice: String
    let duration: String
    var badge: String?
    
    var buttonTitle: String {
        "Subscribe — \(displayPrice)"
    }
}

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var selectedPlan: PaywallPlan?
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    
    let storeKitManager = StoreKitManager.shared
    
    static let proFeatures = [
        "Unlimited children profiles",
        "Unlimited medications & schedules",
        "Unlimited caregiver sharing",
        "Duplicate dose protection alerts",
        "PDF reports for doctor visits",
        "Home screen widgets",
        "Apple Watch quick logging",
        "Medication inventory tracking"
    ]
    
    var availablePlans: [PaywallPlan] {
        let monthly = storeKitManager.products.first { $0.id == StoreKitManager.ProductID.monthly }
        let yearly = storeKitManager.products.first { $0.id == StoreKitManager.ProductID.yearly }
        let lifetime = storeKitManager.products.first { $0.id == StoreKitManager.ProductID.lifetime }
        
        var plans: [PaywallPlan] = []
        
        if let yearly {
            plans.append(PaywallPlan(
                id: "yearly",
                title: "Yearly",
                subtitle: "Save 58%",
                product: yearly,
                displayPrice: yearly.displayPrice,
                duration: "1 year",
                badge: "Best Value"
            ))
        }
        
        if let monthly {
            plans.append(PaywallPlan(
                id: "monthly",
                title: "Monthly",
                subtitle: nil,
                product: monthly,
                displayPrice: monthly.displayPrice,
                duration: "1 month"
            ))
        }
        
        if let lifetime {
            plans.append(PaywallPlan(
                id: "lifetime",
                title: "Lifetime",
                subtitle: "One-time purchase",
                product: lifetime,
                displayPrice: lifetime.displayPrice,
                duration: "Forever"
            ))
        }
        
        return plans
    }
    
    func purchaseSelectedPlan() {
        guard let plan = selectedPlan else { return }
        
        Task {
            isPurchasing = true
            defer { isPurchasing = false }
            
            do {
                try await storeKitManager.purchase(plan.product)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func restorePurchases() async {
        await storeKitManager.restorePurchases()
    }
}