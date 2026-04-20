import SwiftUI
import CoreData

struct CaregiverEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var caregiver: Caregiver?
    
    @State private var name = ""
    @State private var role = CaregiverRole.parent
    @State private var selectedColorHex = "#007AFF"
    
    private let colorOptions = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#5AC8FA", "#FF2D55", "#FFD60A"]
    
    var isEditing: Bool { caregiver != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Caregiver Information")) {
                    TextField("Name", text: $name)
                    
                    Picker("Role", selection: $role) {
                        ForEach(CaregiverRole.allCases, id: \.self) { r in
                            HStack {
                                Image(systemName: r.systemImage)
                                Text(r.displayName)
                            }
                            .tag(r)
                        }
                    }
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
            .navigationTitle(isEditing ? "Edit Caregiver" : "Add Caregiver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCaregiver() }
                        .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let cg = caregiver {
                    name = cg.wrappedName
                    role = cg.caregiverRole
                    selectedColorHex = cg.wrappedColorHex
                }
            }
        }
    }
    
    private func saveCaregiver() {
        withAnimation {
            let target = caregiver ?? Caregiver(context: viewContext)
            target.name = name
            target.role = role.rawValue
            target.colorHex = selectedColorHex
            if target.id == nil {
                target.id = UUID()
                target.isOwner = false
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
