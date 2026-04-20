import Foundation

enum WeightUnit: String, CaseIterable, Codable {
    case kg
    case lb
    
    var displayName: String {
        switch self {
        case .kg: return "kg"
        case .lb: return "lb"
        }
    }
}
