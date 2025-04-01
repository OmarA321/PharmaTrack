import SwiftUI
import PhotosUI

struct NewPrescriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var prescriptionViewModel: PrescriptionViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    // Form fields
    @State private var medicationName: String = ""
    @State private var dosage: String = ""
    @State private var instructions: String = ""
    @State private var prescriptionType: PrescriptionType = .new
    @State private var forUserIndex: Int = 0
    @State private var doctorName: String = ""
    @State private var showingSuccess = false
    
    // Photo upload states
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var prescriptionImage: UIImage?
    @State private var isUsingPhotoMethod = false
    
    // Get user options for picker
    var userOptions: [(id: String, name: String)] {
        var options = [(id: userViewModel.currentUser?.id ?? "", name: "\(userViewModel.currentUser?.firstName ?? "") \(userViewModel.currentUser?.lastName ?? "") (Self)")]
        
        // Add family members
        for member in userViewModel.familyMembers {
            options.append((id: member.id, name: "\(member.firstName) \(member.lastName) (\(member.relationship))"))
        }
        
        return options
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Method selection tabs
                        Picker("Submission Method", selection: $isUsingPhotoMethod) {
                            Text("Manual Entry").tag(false)
                            Text("Upload Photo").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.top)
                        
                        if isUsingPhotoMethod {
                            // Photo upload method
                            VStack(spacing: 20) {
                                // Image preview/placeholder
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(height: 220)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    
                                    if let image = prescriptionImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(8)
                                    } else {
                                        VStack(spacing: 12) {
                                            Image(systemName: "doc.text.viewfinder")
                                                .font(.system(size: 60))
                                                .foregroundColor(.blue.opacity(0.8))
                                            
                                            Text("No prescription photo selected")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Photo action buttons
                                HStack(spacing: 20) {
                                    Button(action: {
                                        showingCamera = true
                                    }) {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                            Text("Take Photo")
                                        }
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                    }
                                    
                                    Button(action: {
                                        showingImagePicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "photo.on.rectangle")
                                            Text("Choose Photo")
                                        }
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Basic prescription info
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Basic Information")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    VStack(spacing: 12) {
                                        Picker("For", selection: $forUserIndex) {
                                            ForEach(0..<userOptions.count, id: \.self) { index in
                                                Text(userOptions[index].name).tag(index)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        
                                        TextField("Doctor's Name (Optional)", text: $doctorName)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Text("We'll review your prescription photo and process it accordingly. You'll receive notifications about the status.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                        } else {
                            // Manual entry method
                            VStack(spacing: 16) {
                                Group {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Medication Name")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        TextField("Medication Name", text: $medicationName)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Dosage")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        TextField("Dosage (e.g., 10mg tablet)", text: $dosage)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Request Type")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Picker("Request Type", selection: $prescriptionType) {
                                            Text("New Prescription").tag(PrescriptionType.new)
                                            Text("Refill Request").tag(PrescriptionType.refill)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("For")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Picker("For", selection: $forUserIndex) {
                                            ForEach(0..<userOptions.count, id: \.self) { index in
                                                Text(userOptions[index].name).tag(index)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                }
                                
                                Group {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Instructions & Details")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        TextEditor(text: $instructions)
                                            .frame(minHeight: 100)
                                            .padding(4)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                            .overlay(
                                                Group {
                                                    if instructions.isEmpty {
                                                        Text("Enter any special instructions or details about your prescription...")
                                                            .foregroundColor(.gray)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 12)
                                                    }
                                                },
                                                alignment: .topLeading
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Doctor's Name")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        TextField("Doctor's Name", text: $doctorName)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Submit button
                        Button(action: submitRequest) {
                            Text("Submit Prescription Request")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.blue : Color.gray)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        .disabled(!isFormValid)
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(prescriptionType == .new ? "New Prescription" : "Refill Request")
            .navigationBarItems(leading:
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $prescriptionImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $prescriptionImage, sourceType: .camera)
            }
            .alert(isPresented: $showingSuccess) {
                Alert(
                    title: Text("Request Submitted"),
                    message: Text("Your prescription request has been sent. You will receive a notification when it's processed."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    private var isFormValid: Bool {
        if isUsingPhotoMethod {
            return prescriptionImage != nil
        } else {
            return !medicationName.isEmpty && !dosage.isEmpty
        }
    }
    
    private func submitRequest() {
        let selectedOption = userOptions[forUserIndex]
        
        // Generate a new prescription with status .requestReceived
        let newRx = "RX\(Int.random(in: 100000...999999))"
        
        // Create the basic prescription object
        var newPrescription = Prescription(
            id: UUID().uuidString,
            rxNumber: newRx,
            medicationName: isUsingPhotoMethod ? "Prescription from Photo" : medicationName,
            dosage: isUsingPhotoMethod ? "To be determined" : dosage,
            instructions: isUsingPhotoMethod ? "See uploaded prescription image" : instructions,
            prescribedDate: Date(),
            expiryDate: Date().addingTimeInterval(86400 * 180), // 180 days from now
            refillsRemaining: prescriptionType == .new ? 3 : 0,
            status: .requestReceived,
            type: prescriptionType,
            forUser: selectedOption.id,
            forUserName: selectedOption.name,
            statusHistory: [
                StatusUpdate(status: .requestReceived, timestamp: Date(), message: "Prescription request received")
            ],
            totalCost: prescriptionType == .new ? 45.99 : 35.99,
            insuranceCoverage: prescriptionType == .new ? 35.00 : 25.00,
            copayAmount: 10.99,
            dispensingFee: 12.99,
            notifiedOnStatusChange: true
        )
        
        // Add details about the image if using photo method
        if isUsingPhotoMethod {
            newPrescription.notes = "Prescription submitted via photo. Doctor: \(doctorName)"
            // In a real app, we would save the image to storage and associate it with the prescription
        }
        
        // Add the prescription to the view model
        prescriptionViewModel.prescriptions.append(newPrescription)
        
        // Show success message
        showingSuccess = true
    }
}

// Image Picker for camera and photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct NewPrescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        NewPrescriptionView()
            .environmentObject(PrescriptionViewModel())
            .environmentObject(UserViewModel())
    }
}
