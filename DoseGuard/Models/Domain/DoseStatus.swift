import Foundation

enum DoseStatus: String, CaseIterable, Codable {
    case scheduled
    case administered
    case skipped
    case missed
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .administered: return "Administered"
        case .skipped: return "Skipped"
        case .missed: return "Missed"
        }
    }
    
    var systemImage: String {
        switch self {
        case .scheduled: return "clock"
        case .administered: return "checkmark.circle.fill"
        case .skipped: return "forward.circle"
        case .missed: return "exclamationmark.circle.fill"
        }
    }
    
    var colorHex: String {
        switch self {
        case .scheduled: return "#007AFF"
        case .administered: return "#34C759"
        case .skipped: return "#FF9500"
        case .missed: return "#FF3B30"
        }
    }
}
