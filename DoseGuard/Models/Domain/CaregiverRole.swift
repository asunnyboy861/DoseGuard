import Foundation

enum CaregiverRole: String, CaseIterable, Codable {
    case parent
    case grandparent
    case babysitter
    case other
    
    var displayName: String {
        switch self {
        case .parent: return "Parent"
        case .grandparent: return "Grandparent"
        case .babysitter: return "Babysitter"
        case .other: return "Other"
        }
    }
    
    var systemImage: String {
        switch self {
        case .parent: return "figure.and.child"
        case .grandparent: return "figure.stand"
        case .babysitter: return "person.fill"
        case .other: return "person.crop.circle"
        }
    }
}
