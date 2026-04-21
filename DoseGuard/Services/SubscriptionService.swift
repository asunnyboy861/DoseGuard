import Foundation
import Combine

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var currentTier: SubscriptionTier = .free
    
    private let storeKitManager: StoreKitManager
    private var cancellables = Set<AnyCancellable>()
    
    nonisolated private init(storeKitManager: StoreKitManager = .shared) {
        self.storeKitManager = storeKitManager
        
        Task { @MainActor in
            storeKitManager.$purchasedProductIDs
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.updateTier()
                }
                .store(in: &self.cancellables)
            
            self.updateTier()
        }
    }
    
    private func updateTier() {
        currentTier = storeKitManager.isProUnlocked ? .pro : .free
    }
    
    func canAddChild(currentCount: Int) -> Bool {
        currentCount < currentTier.maxChildren
    }
    
    func canAddMedication(currentCount: Int) -> Bool {
        currentCount < currentTier.maxMedications
    }
    
    func canAddCaregiver(currentCount: Int) -> Bool {
        currentCount < currentTier.maxCaregivers
    }
    
    var isDuplicateDoseProtectionEnabled: Bool {
        currentTier.hasDuplicateDoseProtection
    }
    
    var isPDFReportsEnabled: Bool {
        currentTier.hasPDFReports
    }
    
    var isWidgetEnabled: Bool {
        currentTier.hasWidget
    }
    
    var isAppleWatchEnabled: Bool {
        currentTier.hasAppleWatch
    }
    
    var isMedicationInventoryEnabled: Bool {
        currentTier.hasMedicationInventory
    }
}