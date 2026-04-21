import SwiftUI

struct FeatureGate: ViewModifier {
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    let feature: () -> Bool
    let paywall: () -> PaywallView
    
    init(
        isAllowed: @escaping () -> Bool,
        paywall: @escaping () -> PaywallView
    ) {
        self.feature = isAllowed
        self.paywall = paywall
    }
    
    func body(content: Content) -> some View {
        Group {
            if feature() {
                content
            } else {
                NavigationLink(destination: paywall()) {
                    content
                }
            }
        }
    }
}

extension View {
    func gated(
        isAllowed: @escaping () -> Bool,
        paywall: @escaping () -> PaywallView = { PaywallView() }
    ) -> some View {
        modifier(FeatureGate(isAllowed: isAllowed, paywall: paywall))
    }
}