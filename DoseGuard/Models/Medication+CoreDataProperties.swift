import Foundation
import CoreData

extension Medication {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medication> {
        return NSFetchRequest<Medication>(entityName: "Medication")
    }
    
    @NSManaged public var colorHex: String?
    @NSManaged public var dosageAmount: Double
    @NSManaged public var dosageUnit: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var frequency: String?
    @NSManaged public var id: UUID?
    @NSManaged public var instructions: String?
    @NSManaged public var intervalHours: Double
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var child: Child?
    @NSManaged public var doseLogs: NSSet?
    
    var wrappedName: String { name ?? "Unknown Medication" }
    var wrappedDosageUnit: String { dosageUnit ?? "ml" }
    var wrappedFrequency: String { frequency ?? "As needed" }
    var wrappedColorHex: String { colorHex ?? "#007AFF" }
    var dosageDisplay: String { "\(dosageAmount) \(wrappedDosageUnit)" }
    var doseLogsArray: [DoseLog] {
        let set = doseLogs as? Set<DoseLog> ?? []
        return set.sorted { $0.wrappedTimestamp > $1.wrappedTimestamp }
    }
}

