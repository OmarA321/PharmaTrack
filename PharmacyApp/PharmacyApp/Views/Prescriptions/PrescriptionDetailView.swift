
import Foundation
import SwiftUI

// First, let's create a reusable AsyncImage component for prescription images
struct PrescriptionImageView: View {
    let imageUrl: String?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prescription Image")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .cornerRadius(12)
                            
                            VStack {
                                ProgressView()
                                    .padding(.bottom, 8)
                                Text("Loading image...")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 200)
                    
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .frame(maxHeight: 300)
                            .onTapGesture {
                                isExpanded = true
                            }
                    
                    case .failure:
                        ZStack {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .cornerRadius(12)
                            
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                
                                Text("Failed to load image")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                            }
                        }
                        .frame(height: 200)
                    
                    @unknown default:
                        EmptyView()
                    }
                }
                .sheet(isPresented: $isExpanded) {
                    FullScreenImageView(imageUrl: urlString)
                }
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .cornerRadius(12)
                    
                    VStack {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No prescription image available")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
                .frame(height: 200)
            }
        }
    }
}

// Full-screen image view with zoom capabilities
struct FullScreenImageView: View {
    let imageUrl: String
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                }
                
                Spacer()
                
                if let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .foregroundColor(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale = min(max(scale * delta, 1.0), 5.0)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                        }
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                                .gesture(
                                    TapGesture(count: 2)
                                        .onEnded {
                                            if scale > 1.0 {
                                                withAnimation {
                                                    scale = 1.0
                                                    offset = .zero
                                                    lastOffset = .zero
                                                }
                                            } else {
                                                withAnimation {
                                                    scale = 3.0
                                                }
                                            }
                                        }
                                )
                        case .failure:
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                                
                                Text("Failed to load image")
                                    .foregroundColor(.white)
                                    .padding(.top, 16)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Spacer()
                
                Text("Double-tap to zoom, pinch to adjust zoom level")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct PrescriptionDetailView: View {
    @EnvironmentObject private var prescriptionViewModel: PrescriptionViewModel
        @State var prescription: Prescription
        @State private var isTrackingExpanded = true
        @State private var messageText = ""
        @State private var showingChatInput = false
    
    @State private var notificationToken: NSObjectProtocol? = nil

    // Date formatter
    private let dateFormatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.dateStyle = .medium
          formatter.timeStyle = .short
          return formatter
      }()
    
    var hasPharmacistMessage: Bool {
        return (prescription.pharmacistMessage != nil && !prescription.pharmacistMessage!.isEmpty) ||
               (prescription.pharmacistMessages != nil && !prescription.pharmacistMessages!.isEmpty)
    }
    
    private func setupNotificationObserver() {
         // Remove any existing observer
         if let token = notificationToken {
             NotificationCenter.default.removeObserver(token)
         }
         
         // Set up a new observer
         notificationToken = NotificationCenter.default.addObserver(
             forName: Notification.Name("PrescriptionUpdated"),
             object: nil,
             queue: .main
         ) { notification in
             if let prescriptionId = notification.userInfo?["prescriptionId"] as? String,
                prescriptionId == prescription.id,
                let updatedPrescription = prescriptionViewModel.prescriptions.first(where: { $0.id == prescriptionId }) {
                 // Update our local state with the new prescription data
                 self.prescription = updatedPrescription
                 print("Detail view updated prescription: \(updatedPrescription.status.rawValue)")
             }
         }
     }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Medication Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prescription.medicationName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(prescription.dosage)
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        StatusBadge(status: prescription.status)
                    }
                    
                    Text(prescription.instructions)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                    
                    // Display prescription image if available
                    if let imageUrl = prescription.imageUrl, !imageUrl.isEmpty {
                        Divider()
                            .padding(.vertical, 8)
                        
                        PrescriptionImageView(imageUrl: imageUrl)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Prescription details
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rx Number")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(prescription.rxNumber)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Refills Remaining")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(prescription.refillsRemaining)")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prescribed Date")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(dateFormatter.string(from: prescription.prescribedDate))
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Expiry Date")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(dateFormatter.string(from: prescription.expiryDate))
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if let lastTaken = prescription.lastTaken, let nextDue = prescription.nextDueDate {
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Adherence Section (Gamification)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medication Adherence")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Last Taken")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(dateFormatter.string(from: lastTaken))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Next Due")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(dateFormatter.string(from: nextDue))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            // Adherence bar (Gamification)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Adherence")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    // Progress bar
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 5)
                                            .frame(height: 10)
                                            .foregroundColor(Color.gray.opacity(0.2))
                                        
                                        RoundedRectangle(cornerRadius: 5)
                                            .frame(width: CGFloat(prescription.adherencePercentage) / 100 * UIScreen.main.bounds.width * 0.7, height: 10)
                                            .foregroundColor(adherenceColor)
                                    }
                                    
                                    Text("\(Int(prescription.adherencePercentage))%")
                                        .font(.body)
                                        .foregroundColor(adherenceColor)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Progress Tracker
                ProgressTracker(currentStatus: prescription.status)
                .padding(.horizontal)
                
                // If there's a pharmacist issue that needs discussion, show the communication section
                if hasPharmacistMessage {
                    // Pharmacist Communication Section
                    if let pharmacistMessages = prescription.pharmacistMessages, !pharmacistMessages.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .foregroundColor(.orange)
                                
                                Text("Pharmacist Communication")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Display an issue message if prescription is in pharmacist check status
                            if prescription.status == .pharmacistCheck {
                                Text("There's an issue with your prescription that needs to be resolved.")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                                    .padding(.bottom, 8)
                            }
                            
                            ForEach(pharmacistMessages) { message in
                                ChatBubble(message: message)
                            }
                            
                            // Reply input field (only shown if pharmacist has initiated)
                            if showingChatInput {
                                HStack {
                                    TextField("Type your reply...", text: $messageText)
                                        .padding(10)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                    
                                    Button(action: sendMessage) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .onAppear {
                            // Enable chat input if there's at least one message from the pharmacist
                            if !pharmacistMessages.filter({ !$0.isFromUser }).isEmpty {
                                showingChatInput = true
                            }
                        }
                    } else if prescription.pharmacistMessage != nil {
                        // Legacy support for old pharmacistMessage field
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text("Message from Pharmacist")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Divider()
                            
                            // Display an issue message if prescription is in pharmacist check status
                            if prescription.status == .pharmacistCheck {
                                Text("There's an issue with your prescription that needs to be resolved.")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                                    .padding(.bottom, 8)
                            }
                            
                            Text(prescription.pharmacistMessage ?? "")
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                            
                            // Display reply button
                            Button(action: {
                                // Convert the old message to new message format and show chat input
                                if let oldMessage = prescription.pharmacistMessage {
                                    let chatMessage = ChatMessage(
                                        id: UUID().uuidString,
                                        content: oldMessage,
                                        timestamp: Date().addingTimeInterval(-3600), // 1 hour ago (approximate)
                                        isFromUser: false
                                    )
                                    
                                    if prescription.pharmacistMessages == nil {
                                        prescription.pharmacistMessages = [chatMessage]
                                    } else {
                                        prescription.pharmacistMessages?.append(chatMessage)
                                    }
                                    
                                    showingChatInput = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrowshape.turn.up.left.fill")
                                    Text("Reply to Pharmacist")
                                }
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                
                // Billing info
                if let totalCost = prescription.totalCost,
                   let insuranceCoverage = prescription.insuranceCoverage,
                   let copayAmount = prescription.copayAmount,
                   let dispensingFee = prescription.dispensingFee {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Billing Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Divider()
                        
                        HStack {
                            Text("Total Cost")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("$\(String(format: "%.2f", totalCost))")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Insurance Coverage")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("$\(String(format: "%.2f", insuranceCoverage))")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Dispensing Fee")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("$\(String(format: "%.2f", dispensingFee))")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Your Copay")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("$\(String(format: "%.2f", copayAmount))")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                if prescription.status == .readyForPickup {
                    // Action button
                    Button(action: {
                        prescriptionViewModel.confirmPickup(for: prescription.id)
                    }) {
                        Text("Confirm Pickup")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                } else if prescription.refillsRemaining > 0 && prescription.status == .completed {
                    // Refill button
                    Button(action: {
                        prescriptionViewModel.requestRefill(for: prescription.id)
                    }) {
                        Text("Request Refill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .navigationTitle("Prescription Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
                    setupNotificationObserver()
                    
                    // Also refresh from the ViewModel when the view appears
                    if let updated = prescriptionViewModel.prescriptions.first(where: { $0.id == prescription.id }) {
                        prescription = updated
                    }
                }
                .onDisappear {
                    // Clean up when the view disappears
                    if let token = notificationToken {
                        NotificationCenter.default.removeObserver(token)
                        notificationToken = nil
                    }
                }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Create a new message
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            timestamp: Date(),
            isFromUser: true
        )
        
        // Add the message to the conversation
        if prescription.pharmacistMessages == nil {
            prescription.pharmacistMessages = [newMessage]
        } else {
            prescription.pharmacistMessages?.append(newMessage)
        }
        
        // Update the prescription in the view model
        if let index = prescriptionViewModel.prescriptions.firstIndex(where: { $0.id == prescription.id }) {
            prescriptionViewModel.prescriptions[index] = prescription
        }
        
        // Clear the input field
        messageText = ""
    }
    
    private var adherenceColor: Color {
        if prescription.adherencePercentage >= 90 {
            return .green
        } else if prescription.adherencePercentage >= 70 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Text(dateFormatter.string(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 60)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(message.content)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    
                    Text(dateFormatter.string(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 60)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct PrescriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrescriptionDetailView(prescription: Prescription.example)
                .environmentObject(PrescriptionViewModel())
        }
    }
}
