import SwiftUI

struct NotificationListView: View {
    @EnvironmentObject private var notificationViewModel: NotificationViewModel
    @EnvironmentObject private var prescriptionViewModel: PrescriptionViewModel
    @State private var showingFilter = false
    @State private var filteredType: NotificationType?
    
    var filteredNotifications: [AppNotification] {
        if let type = filteredType {
            return notificationViewModel.notifications.filter { $0.type == type }
        } else {
            return notificationViewModel.notifications
        }
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            
            VStack {
                // Filter bar
                HStack {
                    Text("Filter by:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            filteredType = nil
                        }) {
                            Text("All Notifications")
                        }
                        
                        Button(action: {
                            filteredType = .requestReceived
                        }) {
                            Text("Request Received")
                        }
                        
                        Button(action: {
                            filteredType = .prepPackaging
                        }) {
                            Text("Prep & Packaging")
                        }
                        
                        Button(action: {
                            filteredType = .readyForPickup
                        }) {
                            Text("Ready for Pickup")
                        }
                        
                        Button(action: {
                            filteredType = .pharmacistMessage
                        }) {
                            Text("Pharmacist Messages")
                        }
                        
                        Button(action: {
                            filteredType = .badge
                        }) {
                            Text("Badges")
                        }
                        
                        Button(action: {
                            filteredType = .healthInfo
                        }) {
                            Text("Health Info")
                        }
                    } label: {
                        HStack {
                            Text(filteredType?.rawValue ?? "All Notifications")
                                .font(.subheadline)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(Color("PrimaryBlue"))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Notification counter
                HStack {
                    Text("\(filteredNotifications.count) Notification\(filteredNotifications.count != 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if !filteredNotifications.isEmpty {
                        Button(action: {
                            notificationViewModel.markAllAsRead()
                        }) {
                            Text("Mark All as Read")
                                .font(.subheadline)
                                .foregroundColor(Color("PrimaryBlue"))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if filteredNotifications.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "bell.badge.slash")
                            .font(.system(size: 70))
                            .foregroundColor(Color("PrimaryBlue").opacity(0.5))
                        
                        Text("No notifications")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("When you receive notifications, they will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                } else {
                    // Notifications list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredNotifications) { notification in
                                NotificationCard(notification: notification)
                                    .onTapGesture {
                                        notificationViewModel.markAsRead(notification.id)
                                        
                                        // If it's a prescription notification, navigate to the prescription detail
                                        if let prescriptionId = notification.prescriptionId,
                                           let prescription = prescriptionViewModel.prescriptions.first(where: { $0.id == prescriptionId }) {
                                            prescriptionViewModel.selectPrescription(prescription)
                                            // In a real app, we would navigate to the detail view here
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarItems(trailing: Button(action: {
            // Action for settings or preferences
        }) {
            Image(systemName: "gear")
                .foregroundColor(Color("PrimaryBlue"))
        })
    }
}

struct NotificationCard: View {
    let notification: AppNotification
    
    // Date formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var iconName: String {
        switch notification.type {
        case .requestReceived:
            return "arrow.down.doc.fill"
        case .prepPackaging:
            return "shippingbox"
        case .readyForPickup:
            return "bag.fill"
        case .pharmacistMessage:
            return "exclamationmark.bubble"
        case .adherenceReminder:
            return "clock"
        case .healthInfo:
            return "heart.text.square"
        case .badge:
            return "medal"
        case .info:
            return "info.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch notification.type {
        case .requestReceived:
            return .blue
        case .prepPackaging:
            return .purple
        case .readyForPickup:
            return .green
        case .pharmacistMessage:
            return .orange
        case .adherenceReminder:
            return .red
        case .healthInfo:
            return .pink
        case .badge:
            return .yellow
        case .info:
            return .gray
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(notification.isRead ? Color("TextColor").opacity(0.6) : Color("TextColor"))
                    
                    Spacer()
                    
                    // Unread indicator
                    if !notification.isRead {
                        Circle()
                            .fill(Color("PrimaryBlue"))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(notification.isRead ? .gray : Color("TextColor"))
                    .lineLimit(2)
                
                Text(dateFormatter.string(from: notification.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(notification.isRead ? Color.white.opacity(0.7) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationListView()
                .environmentObject(NotificationViewModel())
                .environmentObject(PrescriptionViewModel())
        }
    }
}
