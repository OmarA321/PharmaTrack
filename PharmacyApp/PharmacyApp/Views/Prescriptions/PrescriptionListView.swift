//
//  PrescriptionListView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct PrescriptionListView: View {
    @EnvironmentObject private var prescriptionViewModel: PrescriptionViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var showingFilter = false
    @State private var filteredStatus: PrescriptionStatus?
    @State private var showingNewPrescription = false
    @State private var isRefreshing = false
    
    var filteredPrescriptions: [Prescription] {
        if let status = filteredStatus {
            return prescriptionViewModel.prescriptions.filter { $0.status == status }
        } else {
            return prescriptionViewModel.prescriptions
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack {
                // Filter and refresh bar
                HStack {
                    Text("Filter by:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Add refresh button
                    Button(action: refreshPrescriptions) {
                        Label {
                            Text("Refresh")
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: isRefreshing ? "arrow.triangle.2.circlepath.circle.fill" : "arrow.triangle.2.circlepath")
                                .rotationEffect(isRefreshing ? .degrees(360) : .degrees(0))
                                .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                        }
                        .foregroundColor(.blue)
                        .padding(.trailing, 8)
                    }
                    
                    Menu {
                        Button(action: {
                            filteredStatus = nil
                        }) {
                            Text("All Prescriptions")
                        }
                        
                        Button(action: {
                            filteredStatus = .requestReceived
                        }) {
                            Text("Request Received")
                        }
                        
                        Button(action: {
                            filteredStatus = .prepPackaging
                        }) {
                            Text("In Preparation")
                        }
                        
                        Button(action: {
                            filteredStatus = .readyForPickup
                        }) {
                            Text("Ready for Pickup")
                        }
                        
                        Button(action: {
                            filteredStatus = .completed
                        }) {
                            Text("Completed")
                        }
                    } label: {
                        HStack {
                            Text(filteredStatus?.rawValue ?? "All Prescriptions")
                                .font(.subheadline)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if filteredPrescriptions.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "pills.circle")
                            .font(.system(size: 70))
                            .foregroundColor(Color.blue.opacity(0.5))
                        
                        Text("No prescriptions found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("When you receive prescriptions, they will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                } else {
                    // Prescription list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPrescriptions) { prescription in
                                NavigationLink(destination: PrescriptionDetailView(prescription: prescription)) {
                                    PrescriptionCard(prescription: prescription)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarItems(trailing:
            Button(action: {
                showingNewPrescription = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .padding(6)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            }
        )
        .sheet(isPresented: $showingNewPrescription) {
            NewPrescriptionView()
                .environmentObject(prescriptionViewModel)
                .environmentObject(userViewModel)
        }
        .onAppear {
            // Force reload prescriptions when view appears
            if let userId = userViewModel.currentUser?.id {
                refreshPrescriptions()
            }
        }
    }
    
    // Function to manually refresh prescriptions
    private func refreshPrescriptions() {
        guard let userId = userViewModel.currentUser?.id else { return }
        
        isRefreshing = true
        
        // The loadUserPrescriptions method already removes the existing listener
        prescriptionViewModel.loadUserPrescriptions(userId: userId)
        
        // Show the refresh animation for a short time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isRefreshing = false
        }
    }
}

struct PrescriptionCard: View {
    let prescription: Prescription
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Medication name and status
                VStack(alignment: .leading, spacing: 4) {
                    Text(prescription.medicationName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(prescription.dosage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status indicator
                StatusBadge(status: prescription.status)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Patient info
            HStack {
                Label {
                    Text(prescription.forUserName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } icon: {
                    Image(systemName: "person.circle")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Prescription type
                Label {
                    Text(prescription.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                } icon: {
                    Image(systemName: prescription.type == .new ? "doc.fill" : "arrow.clockwise.circle")
                        .foregroundColor(.gray)
                }
            }
            
            if prescription.status == .prepPackaging || prescription.status == .readyForPickup {
                HStack {
                    Spacer()
                    
                    // Estimated time indicator
                    Text(prescription.status == .prepPackaging ? "Ready in ~30 mins" : "Ready for pickup")
                        .font(.caption)
                        .foregroundColor(prescription.status == .readyForPickup ? .green : .blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(prescription.status == .readyForPickup ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                        )
                }
                .padding(.top, 4)
            }
            
            if prescription.pharmacistMessage != nil {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text("Message from pharmacist")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.leading, 2)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: PrescriptionStatus
    
    var color: Color {
        switch status {
        case .requestReceived:
            return .blue
        case .entered, .pharmacistCheck:
            return .orange
        case .prepPackaging:
            return .purple
        case .billing:
            return .gray
        case .readyForPickup:
            return .green
        case .completed:
            return .gray
        }
    }
    
    var icon: String {
        switch status {
        case .requestReceived:
            return "arrow.down.doc.fill"
        case .entered:
            return "keyboard"
        case .pharmacistCheck:
            return "checkmark.circle"
        case .prepPackaging:
            return "shippingbox"
        case .billing:
            return "dollarsign.circle"
        case .readyForPickup:
            return "bag.fill"
        case .completed:
            return "checkmark.seal.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(status.rawValue)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(color)
        .cornerRadius(8)
    }
}

struct PrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrescriptionListView()
                .environmentObject(PrescriptionViewModel())
                .environmentObject(UserViewModel())
        }
    }
}
