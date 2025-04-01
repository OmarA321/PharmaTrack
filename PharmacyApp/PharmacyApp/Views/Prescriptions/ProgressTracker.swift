//
//  ProgressTracker.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-06.
//

import Foundation
import SwiftUI

struct ProgressTracker: View {
    var currentStatus: PrescriptionStatus
    
    private let statuses: [PrescriptionStatus] = [
        .requestReceived, .entered, .pharmacistCheck, .prepPackaging, .billing, .readyForPickup, .completed
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress Tracker")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(statuses, id: \.self) { status in
                HStack(spacing: 15) {
                    Image(systemName: isCompleted(status) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted(status) ? .green : .gray)
                    
                    Text(status.rawValue)
                        .fontWeight(isCurrent(status) ? .bold : .regular)
                        .foregroundColor(isCurrent(status) ? .primary : .secondary)
                    
                    if isNotification(status) && !isCompleted(status) {
                        Text("(Will notify)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if status != .completed {
                    Rectangle()
                        .fill(isCompletedLink(status) ? Color.green : Color.gray)
                        .frame(width: 2, height: 15)
                        .padding(.leading, 10)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func isCompleted(_ status: PrescriptionStatus) -> Bool {
        let currentIndex = statuses.firstIndex(of: currentStatus) ?? 0
        let statusIndex = statuses.firstIndex(of: status) ?? 0
        return statusIndex <= currentIndex
    }
    
    private func isCompletedLink(_ status: PrescriptionStatus) -> Bool {
        let currentIndex = statuses.firstIndex(of: currentStatus) ?? 0
        let statusIndex = statuses.firstIndex(of: status) ?? 0
        return statusIndex < currentIndex
    }
    
    private func isCurrent(_ status: PrescriptionStatus) -> Bool {
        return status == currentStatus
    }
    
    private func isNotification(_ status: PrescriptionStatus) -> Bool {
        return status == .requestReceived || status == .prepPackaging || status == .readyForPickup
    }
}
