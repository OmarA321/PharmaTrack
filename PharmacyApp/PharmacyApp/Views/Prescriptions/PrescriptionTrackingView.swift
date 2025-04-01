import SwiftUI


struct PrescriptionTrackingView: View {
    let prescription: Prescription
    
    // Date formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Prescription Status")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            // New progress tracker
            ProgressTracker(currentStatus: prescription.status)
            
            // Estimated completion (if in progress)
            if prescription.status != .completed && prescription.status != .readyForPickup {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimated Completion")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        
                        Text(estimatedCompletion)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.top, 16)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // Estimated completion text based on current status
    private var estimatedCompletion: String {
        switch prescription.status {
        case .requestReceived:
            return "Your prescription should be ready in approximately 1-2 hours."
        case .entered:
            return "Your prescription should be ready in approximately 45-60 minutes."
        case .pharmacistCheck:
            return "Your prescription should be ready in approximately 30-45 minutes."
        case .prepPackaging:
            return "Your prescription should be ready in approximately 15-20 minutes."
        case .billing:
            return "Your prescription should be ready in approximately 5-10 minutes."
        case .readyForPickup, .completed:
            return "Your prescription is ready for pickup now."
        }
    }
}

struct PrescriptionTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionTrackingView(prescription: Prescription.example)
    }
}
