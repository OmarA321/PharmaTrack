//
//  NotificationBannerView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

enum BannerType {
    case info
    case success
    case warning
    case error
    
    var backgroundColor: Color {
        switch self {
        case .info:
            return Color("PrimaryBlue").opacity(0.2)
        case .success:
            return Color.green.opacity(0.2)
        case .warning:
            return Color.orange.opacity(0.2)
        case .error:
            return Color.red.opacity(0.2)
        }
    }
    
    var iconColor: Color {
        switch self {
        case .info:
            return Color("PrimaryBlue")
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .info:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }
}

struct NotificationBanner: View {
    let title: String
    let message: String
    let type: BannerType
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: type.icon)
                    .foregroundColor(type.iconColor)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(Color("TextColor").opacity(0.8))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: {
                    onDismiss?()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color("TextColor").opacity(0.5))
                        .font(.system(size: 14))
                }
            }
        }
        .padding()
        .background(type.backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct NotificationBannerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let type: BannerType
    let autoDismiss: Bool
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                VStack {
                    NotificationBanner(
                        title: title,
                        message: message,
                        type: type,
                        onDismiss: {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .onAppear {
                        if autoDismiss {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

extension View {
    func notificationBanner(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        type: BannerType = .info,
        autoDismiss: Bool = true,
        duration: TimeInterval = 3.0
    ) -> some View {
        self.modifier(NotificationBannerModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            type: type,
            autoDismiss: autoDismiss,
            duration: duration
        ))
    }
}

// Usage example:
/*
struct ContentView: View {
    @State private var showBanner = false
    
    var body: some View {
        VStack {
            Button("Show Notification") {
                showBanner = true
            }
        }
        .notificationBanner(
            isPresented: $showBanner,
            title: "Success",
            message: "Your prescription has been refilled successfully!",
            type: .success
        )
    }
}
*/
