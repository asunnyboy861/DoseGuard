import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    nextDoseSection
                    todaySummarySection
                    recentActivitySection
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("DoseGuard")
            .onAppear {
                viewModel.loadData()
            }
            .refreshable {
                viewModel.loadData()
            }
        }
    }
    
    private var nextDoseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.blue)
                Text("Next Dose")
                    .font(.headline)
                Spacer()
            }
            
            if viewModel.children.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "person.2.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Add a child to get started")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        NavigationLink(destination: ChildEditorView()) {
                            Text("Add Child")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No upcoming doses")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("All medications are up to date")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.green)
                Text("Today's Summary")
                    .font(.headline)
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.todayCompletedCount)/\(viewModel.todayDoseCount) doses")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("completed today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: viewModel.todayProgress)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(viewModel.todayProgress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .frame(width: 60, height: 60)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.orange)
                Text("Recent Activity")
                    .font(.headline)
            }
            
            if viewModel.recentDoseLogs.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No activity yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
            } else {
                ForEach(viewModel.recentDoseLogs.prefix(5)) { log in
                    HStack(spacing: 12) {
                        Image(systemName: log.doseStatus.systemImage)
                            .foregroundStyle(Color(hex: log.doseStatus.colorHex))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(log.caregiverName) gave \(log.medicationName)")
                                .font(.subheadline)
                            Text(log.wrappedTimestamp.formattedDateTime)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
