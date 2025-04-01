
import Foundation
import Combine

class PrescriptionViewModel: ObservableObject {
    @Published var prescriptions: [Prescription] = []
    @Published var selectedPrescription: Prescription?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load mock data for prototype
        loadMockData()
    }
    
    private func loadMockData() {
        // In a real app, this would fetch from a server
        let examplePrescription = Prescription.example
        
        // Create a few more examples with different statuses
        let now = Date()
        
        var prescription2 = examplePrescription
        prescription2.id = UUID().uuidString
        prescription2.rxNumber = "RX789012"
        prescription2.medicationName = "Lisinopril"
        prescription2.status = .readyForPickup
        prescription2.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 5)),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 4)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-86400 * 3)),
            StatusUpdate(status: .prepPackaging, timestamp: now.addingTimeInterval(-86400 * 2)),
            StatusUpdate(status: .billing, timestamp: now.addingTimeInterval(-86400 * 1)),
            StatusUpdate(status: .readyForPickup, timestamp: now)
        ]
        
        var prescription3 = examplePrescription
        prescription3.id = UUID().uuidString
        prescription3.rxNumber = "RX456789"
        prescription3.medicationName = "Atorvastatin"
        prescription3.status = .requestReceived
        prescription3.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-3600 * 2))
        ]
        
        var prescription4 = examplePrescription
        prescription4.id = UUID().uuidString
        prescription4.rxNumber = "RX123890"
        prescription4.medicationName = "Amoxicillin"
        prescription4.status = .pharmacistCheck
        prescription4.pharmacistMessage = "We've identified a potential interaction with your current medications. We're contacting your doctor to confirm this prescription."
        prescription4.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 1.5)),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 1)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-3600 * 5))
        ]
        
        // Add family member prescription
        var prescription5 = examplePrescription
        prescription5.id = UUID().uuidString
        prescription5.rxNumber = "RX567123"
        prescription5.medicationName = "Albuterol Inhaler"
        prescription5.status = .completed
        prescription5.forUser = "family001"
        prescription5.forUserName = "Emma Doe"
        prescription5.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 10)),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 9)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-86400 * 9)),
            StatusUpdate(status: .prepPackaging, timestamp: now.addingTimeInterval(-86400 * 8)),
            StatusUpdate(status: .billing, timestamp: now.addingTimeInterval(-86400 * 8)),
            StatusUpdate(status: .readyForPickup, timestamp: now.addingTimeInterval(-86400 * 7)),
            StatusUpdate(status: .completed, timestamp: now.addingTimeInterval(-86400 * 6))
        ]
        
        self.prescriptions = [examplePrescription, prescription2, prescription3, prescription4, prescription5]
    }
    
    func selectPrescription(_ prescription: Prescription) {
        self.selectedPrescription = prescription
    }
    
    func updatePrescriptionStatus(id: String, newStatus: PrescriptionStatus, message: String? = nil) {
        guard let index = prescriptions.firstIndex(where: { $0.id == id }) else { return }
        
        var prescription = prescriptions[index]
        prescription.status = newStatus
        
        // Add to status history
        let statusUpdate = StatusUpdate(status: newStatus, timestamp: Date(), message: message)
        prescription.statusHistory.append(statusUpdate)
        
        // For prototype, mark statuses that should trigger notifications
        if newStatus == .requestReceived || newStatus == .prepPackaging || newStatus == .readyForPickup {
            prescription.notifiedOnStatusChange = true
        }
        
        prescriptions[index] = prescription
        
        // If this is the selected prescription, update it
        if selectedPrescription?.id == id {
            selectedPrescription = prescription
        }
    }
    
    func updateAdherence(prescriptionId: String, adherencePercentage: Double) {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescriptionId }) else { return }
        
        var prescription = prescriptions[index]
        prescription.adherencePercentage = adherencePercentage
        prescription.lastTaken = Date()
        
        // Calculate next due date based on instructions (simplified for prototype)
        prescription.nextDueDate = Date().addingTimeInterval(86400) // Just add one day for demo
        
        prescriptions[index] = prescription
        
        // If this is the selected prescription, update it
        if selectedPrescription?.id == prescriptionId {
            selectedPrescription = prescription
        }
    }
    
    func addPharmacistMessage(prescriptionId: String, message: String) {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescriptionId }) else { return }
        
        var prescription = prescriptions[index]
        
        // For backward compatibility, update both message fields
        prescription.pharmacistMessage = message
        
        // Add to chat messages
        let chatMessage = ChatMessage(
            id: UUID().uuidString,
            content: message,
            timestamp: Date(),
            isFromUser: false
        )
        
        if prescription.pharmacistMessages == nil {
            prescription.pharmacistMessages = [chatMessage]
        } else {
            prescription.pharmacistMessages?.append(chatMessage)
        }
        
        prescriptions[index] = prescription
        
        // If this is the selected prescription, update it
        if selectedPrescription?.id == prescriptionId {
            selectedPrescription = prescription
        }
    }
    
    func addUserReply(prescriptionId: String, message: String) -> Bool {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescriptionId }) else { return false }
        
        var prescription = prescriptions[index]
        
        // Check if pharmacist has initiated conversation
        let success = prescription.addUserReply(message)
        
        if success {
            prescriptions[index] = prescription
            
            // If this is the selected prescription, update it
            if selectedPrescription?.id == prescriptionId {
                selectedPrescription = prescription
            }
        }
        
        return success
    }
    
    // Methods for handling prescription refills
    func requestRefill(for prescriptionId: String) {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescriptionId }) else { return }
        
        var prescription = prescriptions[index]
        
        // Only allow refill if completed and has refills remaining
        if prescription.status == .completed && prescription.refillsRemaining > 0 {
            // Create a new prescription based on the refilled one
            var refillPrescription = prescription
            refillPrescription.id = UUID().uuidString
            refillPrescription.rxNumber = "RX\(Int.random(in: 100000...999999))"
            refillPrescription.status = .requestReceived
            refillPrescription.type = .refill
            refillPrescription.prescribedDate = Date()
            refillPrescription.refillsRemaining -= 1
            refillPrescription.statusHistory = [
                StatusUpdate(status: .requestReceived, timestamp: Date(), message: "Refill request received")
            ]
            refillPrescription.notifiedOnStatusChange = true
            refillPrescription.pharmacistMessage = nil
            refillPrescription.pharmacistMessages = nil
            
            // Add to prescriptions list
            self.prescriptions.append(refillPrescription)
        }
    }
    
    // Method to confirm pickup of a prescription
    func confirmPickup(for prescriptionId: String) {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescriptionId }) else { return }
        
        var prescription = prescriptions[index]
        
        // Only allow confirmation if ready for pickup
        if prescription.status == .readyForPickup {
            updatePrescriptionStatus(id: prescriptionId, newStatus: .completed, message: "Prescription picked up by patient")
        }
    }
    
    // Method to get prescriptions for a specific family member
    func getPrescriptionsForFamilyMember(id: String) -> [Prescription] {
        return prescriptions.filter { $0.forUser == id }
    }
    
    // Method to get prescriptions by status
    func getPrescriptionsByStatus(status: PrescriptionStatus) -> [Prescription] {
        return prescriptions.filter { $0.status == status }
    }
    
    // Method to get active prescriptions (not completed)
    func getActivePrescriptions() -> [Prescription] {
        return prescriptions.filter { $0.status != .completed }
    }
    
    // Method to get prescriptions with pharmacist messages
    func getPrescriptionsWithPharmacistMessages() -> [Prescription] {
        return prescriptions.filter {
            ($0.pharmacistMessage != nil && !$0.pharmacistMessage!.isEmpty) ||
            ($0.pharmacistMessages != nil && !$0.pharmacistMessages!.isEmpty)
        }
    }
    
    // Method to check if a prescription has unread pharmacist messages
    func hasUnreadPharmacistMessages(_ prescriptionId: String) -> Bool {
        guard let prescription = prescriptions.first(where: { $0.id == prescriptionId }) else { return false }
        
        if let messages = prescription.pharmacistMessages {
            // Check if there are pharmacist messages without user replies
            let pharmacistMessages = messages.filter { !$0.isFromUser }
            let userMessages = messages.filter { $0.isFromUser }
            
            // If there are more pharmacist messages than user messages, there are unread messages
            return pharmacistMessages.count > userMessages.count
        }
        
        // Legacy check for old pharmacistMessage field
        return prescription.pharmacistMessage != nil && !prescription.pharmacistMessage!.isEmpty
    }
    
    // Method to mark all pharmacist messages as read for a prescription
    func markPharmacistMessagesAsRead(_ prescriptionId: String) {
        // In a real app, this would update a 'read' status for messages
        // For this prototype, we'll just print a debug message
        print("Marked pharmacist messages as read for prescription \(prescriptionId)")
    }
}
