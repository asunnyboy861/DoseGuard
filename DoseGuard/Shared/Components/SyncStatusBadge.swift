import SwiftUI

struct SyncStatusBadge: View {
    let status: SyncStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemImage)
                .font(.caption2)
            Text(status.displayText)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundStyle(foregroundColor)
        .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch status {
        case .disabled: return Color(.secondarySystemGroupedBackground)
        case .syncing: return Color.blue.opacity(0.15)
        case .synced: return Color.green.opacity(0.15)
        case .error: return Color.red.opacity(0.15)
        }
    }
    
    private var foregroundColor: Color {
        switch status {
        case .disabled: return .secondary
        case .syncing: return .blue
        case .synced: return .green
        case .error: return .red
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        SyncStatusBadge(status: .disabled)
        SyncStatusBadge(status: .syncing)
        SyncStatusBadge(status: .synced)
        SyncStatusBadge(status: .error("Network error"))
    }
    .padding()
}