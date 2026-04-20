import Foundation
import CoreData

extension Caregiver {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Caregiver> {
        return NSFetchRequest<Caregiver>(entityName: "Caregiver")
    }
    
    @NSManaged public var avatarData: Data?
    @NSManaged public var colorHex: String?
    @NSManaged public var id: UUID?
    @NSManaged public var iCloudID: String?
    @NSManaged public var isOwner: Bool
    @NSManaged public var name: String?
    @NSManaged public var role: String?
    @NSManaged public var doseLogs: NSSet?
    
    var wrappedName: String { name ?? "Unknown" }
    var wrappedRole: String { role ?? "Parent" }
    var wrappedColorHex: String { colorHex ?? "#007AFF" }
    var caregiverRole: CaregiverRole {
        CaregiverRole(rawValue: wrappedRole) ?? .parent
    }
    var doseLogsArray: [DoseLog] {
        let set = doseLogs as? Set<DoseLog> ?? []
        return set.sorted { $0.wrappedTimestamp > $1.wrappedTimestamp }
    }
}

