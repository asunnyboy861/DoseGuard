import SwiftUI
import CoreData

struct ChildDetailView: View {
    @ObservedObject var child: Child
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddMedication = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(child.weight, specifier: "%.1f") \(child.wrappedWeightUnit)")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    if let dob = child.dateOfBirth {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Date of Birth")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(dob.formattedDate)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            Section {
                if child.medicationsArray.isEmpty {
                    ContentUnavailableView(
                        "No Medications",
                        systemImage: "pills",
                        description: Text("Add a medication for \(child.wrappedName)")
                    )
                } else {
                    ForEach(child.medicationsArray) { medication in
                        NavigationLink(destination: MedicationDetailView(medication: medication)) {
                            MedicationRowView(medication: medication)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Medications")
                    Spacer()
                    Button(action: { showingAddMedication = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .navigationTitle(child.wrappedName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddMedication) {
            MedicationEditorView(child: child)
        }
    }
}
