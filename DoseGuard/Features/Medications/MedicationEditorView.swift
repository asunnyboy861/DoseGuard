import SwiftUI
import CoreData

struct MedicationEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var medication: Medication?
    let child: Child?
    
    @State private var name = ""
    @State private var dosageAmount = ""
    @State private var dosageUnit = DosageUnit.ml
    @State private var frequency = ""
    @State private var intervalHours = ""
    @State private var instructions = ""
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var selectedColorHex = "#007AFF"
    
    private let colorOptions = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#5AC8FA", "#FF2D55", "#FFD60A"]
    
    var isEditing: Bool { medication != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Name", text: $name)
                    
                    HStack {
                        TextField("Amount", text: $dosageAmount)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $dosageUnit) {
                            ForEach(DosageUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    }
                    
                    TextField("Frequency (e.g., Every 8 hours)", text: $frequency)
                    
                    TextField("Interval (hours)", text: $intervalHours)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Instructions")) {
                    TextField("Instructions (e.g., Take with food)", text: $instructions, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Color")) {
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if selectedColorHex == hex {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .onTapGesture {
                                    selectedColorHex = hex
                                }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Medication" : "Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveMedication() }
                        .disabled(name.isEmpty || dosageAmount.isEmpty)
                }
            }
            .onAppear {
                if let medication {
                    name = medication.wrappedName
                    dosageAmount = String(medication.dosageAmount)
                    dosageUnit = DosageUnit(rawValue: medication.wrappedDosageUnit) ?? .ml
                    frequency = medication.wrappedFrequency
                    intervalHours = String(medication.intervalHours)
                    instructions = medication.instructions ?? ""
                    startDate = medication.startDate ?? Date()
                    hasEndDate = medication.endDate != nil
                    if let end = medication.endDate { endDate = end }
                    selectedColorHex = medication.wrappedColorHex
                }
            }
        }
    }
    
    private func saveMedication() {
        withAnimation {
            let target = medication ?? Medication(context: viewContext)
            target.name = name
            target.dosageAmount = Double(dosageAmount) ?? 0
            target.dosageUnit = dosageUnit.rawValue
            target.frequency = frequency
            target.intervalHours = Double(intervalHours) ?? 0
            target.instructions = instructions.isEmpty ? nil : instructions
            target.startDate = startDate
            target.endDate = hasEndDate ? endDate : nil
            target.colorHex = selectedColorHex
            target.isActive = true
            if target.id == nil {
                target.id = UUID()
            }
            if let child, target.child == nil {
                target.child = child
            }
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}
