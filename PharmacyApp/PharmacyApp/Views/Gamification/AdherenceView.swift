//
//  AdherenceView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct AdherenceView: View {
    @EnvironmentObject private var prescriptionViewModel: PrescriptionViewModel
    @EnvironmentObject private var gamificationViewModel: GamificationViewModel
    
    // Mock data for the weekly chart
    private let pastWeekValues = [85, 100, 75, 90, 100, 80, 95]
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall adherence summary
                VStack(spacing: 16) {
                    Text("Medication Adherence")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))
                    
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(Color("PrimaryBlue"))
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(gamificationViewModel.adherenceScore) / 100)
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(adherenceColor)
                            .rotationEffect(Angle(degrees: 270.0))
                        
                        VStack(spacing: 8) {
                            Text("\(gamificationViewModel.adherenceScore)%")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(adherenceColor)
                            
                            Text(gamificationViewModel.getAdherenceLevel())
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                    .frame(width: 200, height: 200)
                    .padding(.vertical, 10)
                    
                    if gamificationViewModel.adherenceScore >= 90 {
                        Text("Excellent! Keep up the good work.")
                            .font(.headline)
                            .foregroundColor(.green)
                    } else if gamificationViewModel.adherenceScore >= 75 {
                        Text("You're doing well! A little more consistency will help.")
                            .font(.headline)
                            .foregroundColor(.orange)
                    } else {
                        Text("Let's work on improving your medication routine.")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Recent adherence stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Past 7 Days")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    // Weekly chart
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(0..<7, id: \.self) { day in
                            let value = pastWeekValues[day]
                            
                            VStack {
                                // Bar
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: 20, height: CGFloat(value) * 1.5)
                                    .foregroundColor(barColor(for: value))
                                
                                // Day label
                                Text(days[day])
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(height: 170)
                    .padding(.vertical, 10)
                    
                    // Weekly summary
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Average")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("\(averageAdherence)%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TextColor"))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Perfect Days")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("\(perfectDays)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Tips to improve adherence
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tips to Improve Adherence")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    ForEach(adherenceTips, id: \.self) { tip in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("PrimaryBlue"))
                                .padding(.top, 2)
                            
                            Text(tip)
                                .font(.body)
                                .foregroundColor(Color("TextColor"))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Medication list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Medications")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    ForEach(prescriptionViewModel.prescriptions) { prescription in
                        if prescription.status == .readyForPickup || prescription.status == .completed {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(prescription.medicationName)
                                        .font(.headline)
                                        .foregroundColor(Color("TextColor"))
                                    
                                    Text(prescription.dosage)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Adherence indicator for this medication
                                Text("\(Int(prescription.adherencePercentage))%")
                                    .font(.headline)
                                    .foregroundColor(barColor(for: Int(prescription.adherencePercentage)))
                            }
                            .padding()
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(Color("BackgroundColor"))
        .navigationTitle("Adherence")
    }
    
    // Helper computed properties
    private var adherenceColor: Color {
        if gamificationViewModel.adherenceScore >= 90 {
            return .green
        } else if gamificationViewModel.adherenceScore >= 75 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func barColor(for value: Int) -> Color {
        if value >= 90 {
            return .green
        } else if value >= 75 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var averageAdherence: Int {
        Int(pastWeekValues.reduce(0, +) / pastWeekValues.count)
    }
    
    private var perfectDays: Int {
        pastWeekValues.filter { $0 == 100 }.count
    }
    
    // Sample adherence tips
    private let adherenceTips = [
        "Set alarms on your phone for medication times",
        "Use a pill organizer to track your doses",
        "Link medication taking to daily routines like brushing teeth",
        "Keep a medication journal or use this app to track adherence",
        "Ask family members to help remind you"
    ]
}

struct AdherenceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdherenceView()
                .environmentObject(PrescriptionViewModel())
                .environmentObject(GamificationViewModel())
        }
    }
}
