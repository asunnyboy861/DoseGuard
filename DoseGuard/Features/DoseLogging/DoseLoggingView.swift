import SwiftUI
import CoreData

struct DoseLoggingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DoseLog.timestamp, ascending: false)],
        animation: .default
    ) private var doseLogs: FetchedResults<DoseLog>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Medication.name, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var medications: FetchedResults<Medication>
    
    @State private var showingDoseEntry = false
    @State private var selectedFilter: DoseStatus?
    
    var filteredLogs: [DoseLog] {
        guard let filter = selectedFilter else {
            return Array(doseLogs)
        }
        return doseLogs.filter { $0.doseStatus == filter }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if doseLogs.isEmpty {
                    EmptyStateView(
                        icon: "clock.badge.checkmark",
                        title: "No Dose Logs",
                        subtitle: "Log your first dose from a medication detail page",
                        actionTitle: "Log Dose",
                        action: { showingDoseEntry = true }
                    )
                } else {
                    List {
                        filterPicker
                        
                        ForEach(filteredLogs) { log in
                            DoseLogRowView(doseLog: log)
                        }
                    }
                }
            }
            .navigationTitle("Dose Log")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingDoseEntry = true }) {
                        Image(systemName: "plus")
                    }
                    .disabled(medications.isEmpty)
                }
            }
            .sheet(isPresented: $showingDoseEntry) {
                if let firstMed = medications.first {
                    DoseEntryView(medication: firstMed)
                }
            }
        }
    }
    
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                ForEach(DoseStatus.allCases, id: \.self) { status in
                    FilterChip(title: status.displayName, isSelected: selectedFilter == status) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct DoseLogRowView: View {
    let doseLog: DoseLog
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: doseLog.doseStatus.systemImage)
                .foregroundStyle(Color(hex: doseLog.doseStatus.colorHex))
                .font(.title3)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(doseLog.medicationName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("by \(doseLog.caregiverName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(doseLog.wrappedTimestamp.formattedTime)
                    .font(.subheadline)
                Text(doseLog.doseStatus.displayName)
                    .font(.caption2)
                    .foregroundStyle(Color(hex: doseLog.doseStatus.colorHex))
            }
        }
        .padding(.vertical, 4)
    }
}
