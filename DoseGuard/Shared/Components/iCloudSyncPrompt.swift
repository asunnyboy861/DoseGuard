import SwiftUI

struct iCloudSyncPrompt: View {
    let reason: SyncPromptReason
    let onEnable: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "icloud")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            
            Text(reason.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(reason.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button(action: onEnable) {
                    Text("Enable iCloud Sync")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: onDismiss) {
                    Text("Not Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .padding(40)
    }
}

#Preview {
    iCloudSyncPrompt(
        reason: .addCaregiver,
        onEnable: {},
        onDismiss: {}
    )
}