import SwiftUI
import CoreData

struct MedicationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Medication.name, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var medications: FetchedResults<Medication>
    
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationStack {
            Group {
                if medications.isEmpty {
                    EmptyStateView(
                        icon: "pills",
                        title: "No Medications",
                        subtitle: "Add a child first, then add their medications",
                        actionTitle: "Add Medication",
                        action: { showingAddMedication = true }
                    )
                } else {
                    List {
                        ForEach(medications) { medication in
                            NavigationLink(destination: MedicationDetailView(medication: medication)) {
                                MedicationRowView(medication: medication)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddMedication = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                MedicationPickerView()
            }
        }
    }
}

struct MedicationRowView: View {
    let medication: Medication
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: medication.wrappedColorHex).opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "pills.fill")
                        .foregroundStyle(Color(hex: medication.wrappedColorHex))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.wrappedName)
                    .font(.headline)
                Text(medication.dosageDisplay + " - " + medication.wrappedFrequency)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let childName = medication.child?.wrappedName {
                    Text("For: \(childName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct MedicationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Child.name, ascending: true)])
    private var children: FetchedResults<Child>
    @State private var selectedChild: Child?
    @State private var showEditor = false
    
    var body: some View {
        NavigationStack {
            Group {
                if children.isEmpty {
                    EmptyStateView(
                        icon: "person.crop.circle.badge.plus",
                        title: "Add a Child First",
                        subtitle: "You need to add a child before adding medications"
                    )
                } else {
                    List {
                        ForEach(children) { child in
                            Button {
                                selectedChild = child
                                showEditor = true
                            } label: {
                                HStack {
                                    Text(child.wrappedName)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showEditor) {
                if let child = selectedChild {
                    MedicationEditorView(child: child)
                }
            }
        }
    }
}
