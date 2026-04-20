import SwiftUI
import CoreData

struct MedicationDetailView: View {
    @ObservedObject var medication: Medication
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingLogDose = false
    @State private var showingEditMedication = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: medication.wrappedColorHex).opacity(0.15))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "pills.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hex: medication.wrappedColorHex))
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(medication.wrappedName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(medication.dosageDisplay)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let childName = medication.child?.wrappedName {
                            Text("For: \(childName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Dosage & Schedule")) {
                LabeledContent("Dosage", value: medication.dosageDisplay)
                LabeledContent("Frequency", value: medication.wrappedFrequency)
                if medication.intervalHours > 0 {
                    LabeledContent("Interval", value: "Every \(Int(medication.intervalHours)) hours")
                }
                LabeledContent("Started", value: (medication.startDate ?? Date()).formattedDate)
                if let endDate = medication.endDate {
                    LabeledContent("Ends", value: endDate.formattedDate)
                }
            }
            
            if let instructions = medication.instructions, !instructions.isEmpty {
                Section(header: Text("Instructions")) {
                    Text(instructions)
                        .font(.body)
                }
            }
            
            Section(header: Text("Recent Doses")) {
                let logs = medication.doseLogsArray
                if logs.isEmpty {
                    Text("No doses logged yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(logs.prefix(10)) { log in
                        DoseLogRowView(doseLog: log)
                    }
                }
            }
        }
        .navigationTitle("Medication")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { showingLogDose = true }) {
                    Label("Log Dose", systemImage: "plus.circle.fill")
                }
                Button(action: { showingEditMedication = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingLogDose) {
            DoseEntryView(medication: medication)
        }
        .sheet(isPresented: $showingEditMedication) {
            MedicationEditorView(medication: medication, child: medication.child)
        }
    }
}
