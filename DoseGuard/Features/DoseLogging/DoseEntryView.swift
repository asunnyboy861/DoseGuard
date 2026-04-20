import SwiftUI
import CoreData

struct DoseEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let medication: Medication
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Caregiver.name, ascending: true)])
    private var caregivers: FetchedResults<Caregiver>
    
    @State private var selectedStatus: DoseStatus = .administered
    @State private var selectedCaregiver: Caregiver?
    @State private var notes = ""
    @State private var timestamp = Date()
    @State private var showingDuplicateAlert = false
    @State private var duplicateMessage = ""
    
    private var activeCaregivers: [Caregiver] {
        Array(caregivers)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medication")) {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: medication.wrappedColorHex).opacity(0.15))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Image(systemName: "pills.fill")
                                    .foregroundStyle(Color(hex: medication.wrappedColorHex))
                            }
                        VStack(alignment: .leading) {
                            Text(medication.wrappedName)
                                .font(.headline)
                            Text(medication.dosageDisplay)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Dose Details")) {
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(DoseStatus.allCases, id: \.self) { status in
                            HStack {
                                Image(systemName: status.systemImage)
                                Text(status.displayName)
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                    
                    if !activeCaregivers.isEmpty {
                        Picker("Caregiver", selection: $selectedCaregiver) {
                            Text("Select caregiver").tag(nil as Caregiver?)
                            ForEach(activeCaregivers) { cg in
                                Text(cg.wrappedName).tag(cg as Caregiver?)
                            }
                        }
                    }
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextField("Add notes about this dose", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Dose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { checkAndSaveDose() }
                }
            }
            .alert("Duplicate Dose Warning", isPresented: $showingDuplicateAlert) {
                Button("Log Anyway") { saveDoseLog() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(duplicateMessage)
            }
            .onAppear {
                if selectedCaregiver == nil, let first = activeCaregivers.first {
                    selectedCaregiver = first
                }
            }
        }
    }
    
    private func checkAndSaveDose() {
        guard selectedStatus == .administered else {
            saveDoseLog()
            return
        }
        
        let interval = medication.intervalHours > 0 ? medication.intervalHours : 4.0
        let cutoff = timestamp.addingTimeInterval(-interval * 3600)
        
        let request: NSFetchRequest<DoseLog> = DoseLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "medication == %@ AND status == 'administered' AND timestamp >= %@",
            medication, cutoff as NSDate
        )
        
        do {
            let recentLogs = try viewContext.fetch(request)
            if let lastLog = recentLogs.first {
                let timeSince = timestamp.timeIntervalSince(lastLog.wrappedTimestamp) / 3600
                duplicateMessage = "A dose of \(medication.wrappedName) was logged \(String(format: "%.1f", timeSince)) hours ago by \(lastLog.caregiverName). The recommended interval is \(Int(interval)) hours. Do you still want to log this dose?"
                showingDuplicateAlert = true
                return
            }
        } catch {
            print("Duplicate check error: \(error)")
        }
        
        saveDoseLog()
    }
    
    private func saveDoseLog() {
        withAnimation {
            let doseLog = DoseLog(context: viewContext)
            doseLog.id = UUID()
            doseLog.timestamp = timestamp
            doseLog.scheduledTime = timestamp
            doseLog.status = selectedStatus.rawValue
            doseLog.notes = notes.isEmpty ? nil : notes
            doseLog.medication = medication
            doseLog.caregiver = selectedCaregiver
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Save dose log error: \(error)")
            }
        }
    }
}
