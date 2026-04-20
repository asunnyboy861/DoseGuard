import SwiftUI
import CoreData

struct ChildListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Child.name, ascending: true)],
        animation: .default
    ) private var children: FetchedResults<Child>
    
    @State private var showingAddChild = false
    
    var body: some View {
        NavigationStack {
            Group {
                if children.isEmpty {
                    EmptyStateView(
                        icon: "person.crop.circle.badge.plus",
                        title: "No Children Yet",
                        subtitle: "Add your first child to start tracking their medications",
                        actionTitle: "Add Child",
                        action: { showingAddChild = true }
                    )
                } else {
                    List {
                        ForEach(children) { child in
                            NavigationLink(destination: ChildDetailView(child: child)) {
                                ChildRowView(child: child)
                            }
                        }
                        .onDelete(perform: deleteChildren)
                    }
                }
            }
            .navigationTitle("Children")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddChild = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                ChildEditorView()
            }
        }
    }
    
    private func deleteChildren(offsets: IndexSet) {
        withAnimation {
            offsets.map { children[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}

struct ChildRowView: View {
    let child: Child
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.accentColor)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(child.wrappedName)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text("\(child.weight, specifier: "%.1f") \(child.wrappedWeightUnit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(child.medicationsArray.count) medication\(child.medicationsArray.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
