//
//  PrescriptionFirestoreService.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-31.
//

import Foundation
import Firebase
import FirebaseFirestore

class PrescriptionFirestoreService {
    // Singleton instance
    static let shared = PrescriptionFirestoreService()
    private init() {}
    
    private let db = Firestore.firestore()
    private let prescriptionsCollection = "prescriptions"
    
    // MARK: - Create
    
    func createPrescription(_ prescription: Prescription, completion: @escaping (Result<Prescription, Error>) -> Void) {
        var prescriptionToSave = prescription
        
        // Generate ID if not available
        if prescriptionToSave.id.isEmpty {
            prescriptionToSave.id = UUID().uuidString
        }
        
        // Convert prescription to dictionary
        guard let prescriptionData = self.prescriptionToDictionary(prescriptionToSave) else {
            completion(.failure(NSError(domain: "PrescriptionFirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert prescription to dictionary"])))
            return
        }
        
        // Save to Firestore
        db.collection(prescriptionsCollection).document(prescriptionToSave.id).setData(prescriptionData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(prescriptionToSave))
            }
        }
    }
    
    // MARK: - Read
    
    func fetchPrescriptionsForUser(userId: String, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        // Get prescriptions where user is the primary user or a family member
        db.collection(prescriptionsCollection)
            .whereField("forUser", isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var prescriptions: [Prescription] = []
                
                for document in snapshot?.documents ?? [] {
                    if let prescription = self.prescriptionFromDictionary(document.data(), id: document.documentID) {
                        prescriptions.append(prescription)
                    }
                }
                
                completion(.success(prescriptions))
            }
    }
    
    func fetchPrescription(id: String, completion: @escaping (Result<Prescription, Error>) -> Void) {
        db.collection(prescriptionsCollection).document(id).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "PrescriptionFirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Prescription not found"])))
                return
            }
            
            if let prescription = self.prescriptionFromDictionary(document.data() ?? [:], id: document.documentID) {
                completion(.success(prescription))
            } else {
                completion(.failure(NSError(domain: "PrescriptionFirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode prescription"])))
            }
        }
    }
    
    // MARK: - Update
    
    func updatePrescription(_ prescription: Prescription, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let prescriptionData = self.prescriptionToDictionary(prescription) else {
            completion(.failure(NSError(domain: "PrescriptionFirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert prescription to dictionary"])))
            return
        }
        
        db.collection(prescriptionsCollection).document(prescription.id).setData(prescriptionData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updatePrescriptionStatus(id: String, newStatus: PrescriptionStatus, message: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        // First get the current prescription
        fetchPrescription(id: id) { result in
            switch result {
            case .success(var prescription):
                // Update the status
                prescription.status = newStatus
                
                // Add to status history
                let statusUpdate = StatusUpdate(status: newStatus, timestamp: Date(), message: message)
                prescription.statusHistory.append(statusUpdate)
                
                // Set notification flag for statuses that should trigger notifications
                if newStatus == .requestReceived || newStatus == .prepPackaging || newStatus == .readyForPickup {
                    prescription.notifiedOnStatusChange = true
                }
                
                // Save the updated prescription
                self.updatePrescription(prescription) { updateResult in
                    completion(updateResult)
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addPharmacistMessage(prescriptionId: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchPrescription(id: prescriptionId) { result in
            switch result {
            case .success(var prescription):
                // Create chat message
                let chatMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: message,
                    timestamp: Date(),
                    isFromUser: false
                )
                
                // For backward compatibility, update both message fields
                prescription.pharmacistMessage = message
                
                if prescription.pharmacistMessages == nil {
                    prescription.pharmacistMessages = [chatMessage]
                } else {
                    prescription.pharmacistMessages?.append(chatMessage)
                }
                
                // Save the updated prescription
                self.updatePrescription(prescription) { updateResult in
                    completion(updateResult)
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addUserReply(prescriptionId: String, message: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        fetchPrescription(id: prescriptionId) { result in
            switch result {
            case .success(var prescription):
                // Try to add the user reply
                let success = prescription.addUserReply(message)
                
                if success {
                    // Save the updated prescription
                    self.updatePrescription(prescription) { updateResult in
                        switch updateResult {
                        case .success:
                            completion(.success(true))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.success(false)) // Could not add user message (pharmacist has not initiated)
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Delete
    
    func deletePrescription(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(prescriptionsCollection).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Refill Methods
    
    func requestRefill(for prescriptionId: String, completion: @escaping (Result<Prescription, Error>) -> Void) {
        fetchPrescription(id: prescriptionId) { result in
            switch result {
            case .success(let prescription):
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
                    
                    // Create the new refill prescription
                    self.createPrescription(refillPrescription) { createResult in
                        completion(createResult)
                    }
                } else {
                    let error = NSError(domain: "PrescriptionFirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot refill: either prescription is not completed or no refills remaining"])
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func confirmPickup(for prescriptionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchPrescription(id: prescriptionId) { result in
            switch result {
            case .success(let prescription):
                // Only allow confirmation if ready for pickup
                if prescription.status == .readyForPickup {
                    self.updatePrescriptionStatus(id: prescriptionId, newStatus: .completed, message: "Prescription picked up by patient", completion: completion)
                } else {
                    let error = NSError(domain: "PrescriptionFirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot confirm pickup: prescription is not ready for pickup"])
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Adherence Tracking
    
    func updateAdherence(prescriptionId: String, adherencePercentage: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchPrescription(id: prescriptionId) { result in
            switch result {
            case .success(var prescription):
                prescription.adherencePercentage = adherencePercentage
                prescription.lastTaken = Date()
                
                // Calculate next due date based on instructions (simplified)
                prescription.nextDueDate = Date().addingTimeInterval(86400) // Just add one day for demo
                
                // Save the updated prescription
                self.updatePrescription(prescription) { updateResult in
                    completion(updateResult)
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Listen for Changes
    
    // This method sets up a listener for prescription changes
    func listenForPrescriptionChanges(userId: String, completion: @escaping (Result<[Prescription], Error>) -> Void) -> ListenerRegistration {
        return db.collection(prescriptionsCollection)
            .whereField("forUser", isEqualTo: userId)
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var prescriptions: [Prescription] = []
                
                for document in snapshot?.documents ?? [] {
                    if let prescription = self.prescriptionFromDictionary(document.data(), id: document.documentID) {
                        prescriptions.append(prescription)
                    }
                }
                
                completion(.success(prescriptions))
            }
    }
    
    // MARK: - Conversion Methods
    
    private func prescriptionToDictionary(_ prescription: Prescription) -> [String: Any]? {
        // Convert Prescription object to dictionary
        var dict: [String: Any] = [
            "id": prescription.id,
            "rxNumber": prescription.rxNumber,
            "medicationName": prescription.medicationName,
            "dosage": prescription.dosage,
            "instructions": prescription.instructions,
            "prescribedDate": prescription.prescribedDate,
            "expiryDate": prescription.expiryDate,
            "refillsRemaining": prescription.refillsRemaining,
            "status": prescription.status.rawValue,
            "type": prescription.type.rawValue,
            "forUser": prescription.forUser,
            "forUserName": prescription.forUserName,
            "statusHistory": prescription.statusHistory.map { statusUpdateToDictionary($0) },
            "notifiedOnStatusChange": prescription.notifiedOnStatusChange,
            "adherencePercentage": prescription.adherencePercentage
        ]
        
        // Add optional fields if they exist
        if let notes = prescription.notes {
            dict["notes"] = notes
        }
        
        if let pharmacistMessage = prescription.pharmacistMessage {
            dict["pharmacistMessage"] = pharmacistMessage
        }
        
        if let pharmacistMessages = prescription.pharmacistMessages {
            dict["pharmacistMessages"] = pharmacistMessages.map { chatMessageToDictionary($0) }
        }
        
        if let totalCost = prescription.totalCost {
            dict["totalCost"] = totalCost
        }
        
        if let insuranceCoverage = prescription.insuranceCoverage {
            dict["insuranceCoverage"] = insuranceCoverage
        }
        
        if let copayAmount = prescription.copayAmount {
            dict["copayAmount"] = copayAmount
        }
        
        if let dispensingFee = prescription.dispensingFee {
            dict["dispensingFee"] = dispensingFee
        }
        
        if let lastTaken = prescription.lastTaken {
            dict["lastTaken"] = lastTaken
        }
        
        if let nextDueDate = prescription.nextDueDate {
            dict["nextDueDate"] = nextDueDate
        }
        
        if let imageUrl = prescription.imageUrl {
            dict["imageUrl"] = imageUrl
        }
        
        return dict
    }
    
    private func statusUpdateToDictionary(_ statusUpdate: StatusUpdate) -> [String: Any] {
        var dict: [String: Any] = [
            "status": statusUpdate.status.rawValue,
            "timestamp": statusUpdate.timestamp
        ]
        
        if let message = statusUpdate.message {
            dict["message"] = message
        }
        
        return dict
    }
    
    private func chatMessageToDictionary(_ chatMessage: ChatMessage) -> [String: Any] {
        return [
            "id": chatMessage.id,
            "content": chatMessage.content,
            "timestamp": chatMessage.timestamp,
            "isFromUser": chatMessage.isFromUser
        ]
    }
    
    private func prescriptionFromDictionary(_ dictionary: [String: Any], id: String) -> Prescription? {
        guard let rxNumber = dictionary["rxNumber"] as? String,
              let medicationName = dictionary["medicationName"] as? String,
              let dosage = dictionary["dosage"] as? String,
              let instructions = dictionary["instructions"] as? String,
              let prescribedDate = (dictionary["prescribedDate"] as? Timestamp)?.dateValue(),
              let expiryDate = (dictionary["expiryDate"] as? Timestamp)?.dateValue(),
              let refillsRemaining = dictionary["refillsRemaining"] as? Int,
              let statusString = dictionary["status"] as? String,
              let status = PrescriptionStatus(rawValue: statusString),
              let typeString = dictionary["type"] as? String,
              let type = PrescriptionType(rawValue: typeString),
              let forUser = dictionary["forUser"] as? String,
              let forUserName = dictionary["forUserName"] as? String
        else {
            return nil
        }
        
        // Create the base prescription
        var prescription = Prescription(
            id: id,
            rxNumber: rxNumber,
            medicationName: medicationName,
            dosage: dosage,
            instructions: instructions,
            prescribedDate: prescribedDate,
            expiryDate: expiryDate,
            refillsRemaining: refillsRemaining,
            status: status,
            type: type,
            forUser: forUser,
            forUserName: forUserName
        )
        
        // Add status history
        if let statusHistoryArray = dictionary["statusHistory"] as? [[String: Any]] {
            prescription.statusHistory = statusHistoryArray.compactMap { self.statusUpdateFromDictionary($0) }
        }
        
        // Add optional fields
        prescription.notes = dictionary["notes"] as? String
        prescription.pharmacistMessage = dictionary["pharmacistMessage"] as? String
        
        if let pharmacistMessagesArray = dictionary["pharmacistMessages"] as? [[String: Any]] {
            prescription.pharmacistMessages = pharmacistMessagesArray.compactMap { self.chatMessageFromDictionary($0) }
        }
        
        prescription.totalCost = dictionary["totalCost"] as? Double
        prescription.insuranceCoverage = dictionary["insuranceCoverage"] as? Double
        prescription.copayAmount = dictionary["copayAmount"] as? Double
        prescription.dispensingFee = dictionary["dispensingFee"] as? Double
        
        prescription.notifiedOnStatusChange = dictionary["notifiedOnStatusChange"] as? Bool ?? false
        
        prescription.adherencePercentage = dictionary["adherencePercentage"] as? Double ?? 100.0
        
        if let lastTakenTimestamp = dictionary["lastTaken"] as? Timestamp {
            prescription.lastTaken = lastTakenTimestamp.dateValue()
        }
        
        if let nextDueDateTimestamp = dictionary["nextDueDate"] as? Timestamp {
            prescription.nextDueDate = nextDueDateTimestamp.dateValue()
        }
        
        prescription.imageUrl = dictionary["imageUrl"] as? String
        
        return prescription
    }
    
    private func statusUpdateFromDictionary(_ dictionary: [String: Any]) -> StatusUpdate? {
        guard let statusString = dictionary["status"] as? String,
              let status = PrescriptionStatus(rawValue: statusString),
              let timestamp = (dictionary["timestamp"] as? Timestamp)?.dateValue()
        else {
            return nil
        }
        
        let message = dictionary["message"] as? String
        
        return StatusUpdate(status: status, timestamp: timestamp, message: message)
    }
    
    private func chatMessageFromDictionary(_ dictionary: [String: Any]) -> ChatMessage? {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let timestamp = (dictionary["timestamp"] as? Timestamp)?.dateValue(),
              let isFromUser = dictionary["isFromUser"] as? Bool
        else {
            return nil
        }
        
        return ChatMessage(id: id, content: content, timestamp: timestamp, isFromUser: isFromUser)
    }
}
