import SwiftUI
import CoreData

struct ChildEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var child: Child?
    
    @State private var name = ""
    @State private var weight = ""
    @State private var weightUnit = WeightUnit.kg
    @State private var dateOfBirth = Date()
    
    var isEditing: Bool { child != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Child Information")) {
                    TextField("Name", text: $name)
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                }
                
                Section(header: Text("Weight")) {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Child" : "Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChild() }
                        .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let child {
                    name = child.wrappedName
                    weight = String(format: "%.1f", child.weight)
                    weightUnit = WeightUnit(rawValue: child.wrappedWeightUnit) ?? .kg
                    dateOfBirth = child.wrappedDateOfBirth
                }
            }
        }
    }
    
    private func saveChild() {
        withAnimation {
            let targetChild = child ?? Child(context: viewContext)
            targetChild.name = name
            targetChild.weight = Double(weight) ?? 0
            targetChild.weightUnit = weightUnit.rawValue
            targetChild.dateOfBirth = dateOfBirth
            if targetChild.id == nil {
                targetChild.id = UUID()
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
