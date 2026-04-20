import Foundation
import CoreData

extension DoseLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DoseLog> {
        return NSFetchRequest<DoseLog>(entityName: "DoseLog")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var notes: String?
    @NSManaged public var scheduledTime: Date?
    @NSManaged public var status: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var caregiver: Caregiver?
    @NSManaged public var medication: Medication?
    
    var wrappedTimestamp: Date { timestamp ?? Date() }
    var wrappedStatus: String { status ?? "scheduled" }
    var doseStatus: DoseStatus {
        DoseStatus(rawValue: wrappedStatus) ?? .scheduled
    }
    var caregiverName: String { caregiver?.name ?? "Unknown" }
    var medicationName: String { medication?.wrappedName ?? "Unknown" }
}

