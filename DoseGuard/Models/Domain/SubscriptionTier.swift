import Foundation

enum SubscriptionTier: Int, CaseIterable {
    case free = 0
    case pro = 1
    
    var isPro: Bool { self == .pro }
    
    var maxChildren: Int {
        switch self {
        case .free: return 1
        case .pro: return Int.max
        }
    }
    
    var maxMedications: Int {
        switch self {
        case .free: return 2
        case .pro: return Int.max
        }
    }
    
    var maxCaregivers: Int {
        switch self {
        case .free: return 1
        case .pro: return Int.max
        }
    }
    
    var hasDuplicateDoseProtection: Bool { isPro }
    var hasPDFReports: Bool { isPro }
    var hasWidget: Bool { isPro }
    var hasAppleWatch: Bool { isPro }
    var hasMedicationInventory: Bool { isPro }
}
