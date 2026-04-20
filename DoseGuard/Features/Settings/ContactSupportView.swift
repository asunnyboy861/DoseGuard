import SwiftUI

struct ContactSupportView: View {
    @State private var selectedSubject: FeedbackSubject = .general
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    private let feedbackURL = URL(string: "https://feedback-board.iocompile67692.workers.dev/api/feedback")!
    
    var body: some View {
        Form {
            subjectSection
            contactSection
            messageSection
            submitSection
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") {
                name = ""
                email = ""
                message = ""
                selectedSubject = .general
            }
        } message: {
            Text("Your feedback has been submitted. We'll get back to you soon.")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private var subjectSection: some View {
        Section(header: Text("Subject")) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(FeedbackSubject.allCases, id: \.self) { subject in
                    SubjectChip(
                        subject: subject,
                        isSelected: selectedSubject == subject,
                        action: { selectedSubject = subject }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var contactSection: some View {
        Section(header: Text("Contact Information")) {
            TextField("Your Name", text: $name)
            TextField("Email Address", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
        }
    }
    
    private var messageSection: some View {
        Section(header: Text("Message")) {
            TextField("Describe your issue or feedback", text: $message, axis: .vertical)
                .lineLimit(5...10)
        }
    }
    
    private var submitSection: some View {
        Section {
            Button(action: submitFeedback) {
                HStack {
                    Spacer()
                    if isSubmitting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Submit Feedback")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .disabled(isSubmitting || message.isEmpty)
            .listRowBackground(Color.accentColor)
            .tint(.white)
        }
    }
    
    private func submitFeedback() {
        guard !message.isEmpty else { return }
        isSubmitting = true
        errorMessage = nil
        
        var request = URLRequest(url: feedbackURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "name": name,
            "email": email,
            "subject": selectedSubject.rawValue,
            "message": message,
            "app_name": "DoseGuard"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            errorMessage = "Failed to prepare request"
            isSubmitting = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    showSuccess = true
                } else {
                    errorMessage = "Server error. Please try again later."
                }
            }
        }.resume()
    }
}

enum FeedbackSubject: String, CaseIterable {
    case general = "General Feedback"
    case bug = "Bug Report"
    case feature = "Feature Request"
    case medication = "Medication Tracking Issue"
    case sharing = "Sharing & Sync Issue"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .general: return "message.fill"
        case .bug: return "ladybug.fill"
        case .feature: return "lightbulb.fill"
        case .medication: return "pills.fill"
        case .sharing: return "person.2.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct SubjectChip: View {
    let subject: FeedbackSubject
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: subject.icon)
                    .font(.subheadline)
                Text(subject.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
