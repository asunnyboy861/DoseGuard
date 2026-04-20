import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            ChildListView()
                .tabItem {
                    Label("Children", systemImage: "person.2.fill")
                }
                .tag(1)
            
            MedicationListView()
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(2)
            
            DoseLoggingView()
                .tabItem {
                    Label("Dose Log", systemImage: "clock.badge.checkmark")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
