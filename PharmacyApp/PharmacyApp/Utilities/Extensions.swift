//
//  Extensions.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(AppMetrics.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(AppMetrics.cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

// MARK: - Date Extensions
extension Date {
    func formattedString(style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func isTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    func daysFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}

// MARK: - String Extensions
extension String {
    var initials: String {
        let words = self.components(separatedBy: " ")
        let firstLetters = words.compactMap { $0.first }
        return firstLetters.prefix(2).map { String($0) }.joined().uppercased()
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

// MARK: - Array Extensions
extension Array where Element: Identifiable {
    func indexOf(id: Element.ID) -> Int? {
        return self.firstIndex(where: { $0.id == id })
    }
}

// MARK: - Helper Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Double Extensions
extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}

// MARK: - UIApplication Extensions
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - UIScreen Extensions
extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let screenSize = UIScreen.main.bounds.size
}
