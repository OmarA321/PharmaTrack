//
//  StorageService.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-31.
//

import Foundation
import Firebase
import FirebaseStorage

class StorageService {
    static let shared = StorageService()
    private init() {}
    
    private let storage = Storage.storage()
    
    func uploadPrescriptionImage(image: UIImage, prescriptionId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "StorageService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        // Create a storage reference
        let storageRef = storage.reference().child("prescriptions/\(prescriptionId)/image.jpg")
        
        // Upload the image data
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "StorageService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    func deletePrescriptionImage(prescriptionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storageRef = storage.reference().child("prescriptions/\(prescriptionId)/image.jpg")
        
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
