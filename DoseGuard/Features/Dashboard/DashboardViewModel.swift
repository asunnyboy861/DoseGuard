import Foundation
import CoreData

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var recentDoseLogs: [DoseLog] = []
    @Published var nextScheduledDose: DoseLog?
    @Published var todayDoseCount: Int = 0
    @Published var todayCompletedCount: Int = 0
    
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    var todayProgress: Double {
        guard todayDoseCount > 0 else { return 0 }
        return Double(todayCompletedCount) / Double(todayDoseCount)
    }
    
    func loadData() {
        fetchChildren()
        fetchRecentDoseLogs()
        fetchTodayStats()
    }
    
    private func fetchChildren() {
        let request: NSFetchRequest<Child> = Child.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Child.name, ascending: true)]
        do {
            children = try context.fetch(request)
        } catch {
            print("Fetch children error: \(error)")
        }
    }
    
    private func fetchRecentDoseLogs() {
        let request: NSFetchRequest<DoseLog> = DoseLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DoseLog.timestamp, ascending: false)]
        request.fetchLimit = 10
        do {
            recentDoseLogs = try context.fetch(request)
        } catch {
            print("Fetch dose logs error: \(error)")
        }
    }
    
    private func fetchTodayStats() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        
        let request: NSFetchRequest<DoseLog> = DoseLog.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let logs = try context.fetch(request)
            todayDoseCount = logs.count
            todayCompletedCount = logs.filter { $0.doseStatus == .administered }.count
        } catch {
            print("Fetch today stats error: \(error)")
        }
    }
}
