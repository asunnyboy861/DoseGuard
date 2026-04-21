import CoreData
import SwiftUI

final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    private var _container: NSPersistentContainer?
    private var cloudKitContainer: NSPersistentCloudKitContainer?
    private var localContainer: NSPersistentContainer?
    
    var container: NSPersistentContainer {
        if let existing = _container {
            return existing
        }
        return createContainer()
    }
    
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
    
    private let inMemory: Bool
    
    init(inMemory: Bool = false) {
        self.inMemory = inMemory
        _ = createContainer()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleiCloudEnabledChange),
            name: SyncService.iCloudEnabledDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func createContainer() -> NSPersistentContainer {
        let iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudEnabled")
        
        if iCloudEnabled && !inMemory {
            let cloudContainer = NSPersistentCloudKitContainer(name: "DoseGuard")
            cloudContainer.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            cloudContainer.viewContext.automaticallyMergesChangesFromParent = true
            cloudContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            cloudKitContainer = cloudContainer
            _container = cloudContainer
            return cloudContainer
        } else {
            let local = NSPersistentContainer(name: "DoseGuard")
            if inMemory {
                local.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            }
            local.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            local.viewContext.automaticallyMergesChangesFromParent = true
            local.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            localContainer = local
            _container = local
            return local
        }
    }
    
    @objc private func handleiCloudEnabledChange() {
        let iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudEnabled")
        
        if iCloudEnabled {
            switchToCloudKit()
        } else {
            switchToLocal()
        }
    }
    
    func switchToCloudKit() {
        guard cloudKitContainer == nil else {
            _container = cloudKitContainer
            objectWillChange.send()
            return
        }
        
        let cloudContainer = NSPersistentCloudKitContainer(name: "DoseGuard")
        cloudContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("CloudKit container error: \(error)")
                return
            }
        }
        cloudContainer.viewContext.automaticallyMergesChangesFromParent = true
        cloudContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        cloudKitContainer = cloudContainer
        _container = cloudContainer
        objectWillChange.send()
    }
    
    func switchToLocal() {
        guard let local = localContainer else {
            _container = createContainer()
            objectWillChange.send()
            return
        }
        _container = local
        objectWillChange.send()
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