import SwiftUI
import CoreData

struct CaregiverListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Caregiver.isOwner, ascending: false)],
        animation: .default
    ) private var caregivers: FetchedResults<Caregiver>
    
    @State private var showingAddCaregiver = false
    
    var body: some View {
        NavigationStack {
            Group {
                if caregivers.isEmpty {
                    EmptyStateView(
                        icon: "person.2.circle",
                        title: "No Caregivers",
                        subtitle: "Add caregivers who help administer medications",
                        actionTitle: "Add Caregiver",
                        action: { showingAddCaregiver = true }
                    )
                } else {
                    List {
                        ForEach(caregivers) { caregiver in
                            CaregiverRowView(caregiver: caregiver)
                        }
                        .onDelete(perform: deleteCaregivers)
                    }
                }
            }
            .navigationTitle("Caregivers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddCaregiver = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCaregiver) {
                CaregiverEditorView()
            }
        }
    }
    
    private func deleteCaregivers(offsets: IndexSet) {
        withAnimation {
            offsets.map { caregivers[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}

struct CaregiverRowView: View {
    let caregiver: Caregiver
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: caregiver.wrappedColorHex).opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: caregiver.caregiverRole.systemImage)
                        .foregroundStyle(Color(hex: caregiver.wrappedColorHex))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(caregiver.wrappedName)
                        .font(.headline)
                    if caregiver.isOwner {
                        Text("Owner")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
                Text(caregiver.caregiverRole.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
