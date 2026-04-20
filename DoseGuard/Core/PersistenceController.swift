import CoreData
import SwiftUI

final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        let child = Child(context: context)
        child.id = UUID()
        child.name = "Emma"
        child.dateOfBirth = Calendar.current.date(byAdding: .year, value: -3, to: Date())
        child.weight = 15.5
        child.weightUnit = "kg"
        
        let caregiver = Caregiver(context: context)
        caregiver.id = UUID()
        caregiver.name = "Mom"
        caregiver.role = "Parent"
        caregiver.colorHex = "#007AFF"
        caregiver.isOwner = true
        
        let medication = Medication(context: context)
        medication.id = UUID()
        medication.name = "Amoxicillin"
        medication.dosageAmount = 5.0
        medication.dosageUnit = "ml"
        medication.frequency = "Every 8 hours"
        medication.intervalHours = 8.0
        medication.startDate = Date()
        medication.instructions = "Take with food"
        medication.colorHex = "#007AFF"
        medication.isActive = true
        medication.child = child
        
        let doseLog = DoseLog(context: context)
        doseLog.id = UUID()
        doseLog.timestamp = Date()
        doseLog.status = "administered"
        doseLog.medication = medication
        doseLog.caregiver = caregiver
        
        do {
            try context.save()
        } catch {
            fatalError("Preview data creation failed: \(error.localizedDescription)")
        }
        
        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DoseGuard")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
        save()
    }
}
