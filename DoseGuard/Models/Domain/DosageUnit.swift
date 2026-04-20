import Foundation

enum DosageUnit: String, CaseIterable, Codable {
    case ml
    case mg
    case tablets
    case drops
    case puffs
    case g
    
    var displayName: String {
        switch self {
        case .ml: return "ml"
        case .mg: return "mg"
        case .tablets: return "tablets"
        case .drops: return "drops"
        case .puffs: return "puffs"
        case .g: return "g"
        }
    }
}
