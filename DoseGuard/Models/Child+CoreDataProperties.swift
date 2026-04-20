import Foundation
import CoreData

extension Child {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Child> {
        return NSFetchRequest<Child>(entityName: "Child")
    }
    
    @NSManaged public var allergies: [String]?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var photoData: Data?
    @NSManaged public var weight: Double
    @NSManaged public var weightUnit: String?
    @NSManaged public var medications: NSSet?
    
    var wrappedName: String { name ?? "Unknown" }
    var wrappedWeightUnit: String { weightUnit ?? "kg" }
    var wrappedDateOfBirth: Date { dateOfBirth ?? Date() }
    var medicationsArray: [Medication] {
        let set = medications as? Set<Medication> ?? []
        return set.sorted { $0.wrappedName < $1.wrappedName }
    }
}

