//
//  CustomButtonStyle.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color("PrimaryBlue")
    var foregroundColor: Color = .white
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding()
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(backgroundColor)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var borderColor: Color = Color("PrimaryBlue")
    var foregroundColor: Color = Color("PrimaryBlue")
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding()
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.red)
            .padding()
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct IconButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color("PrimaryBlue").opacity(0.1)
    var foregroundColor: Color = Color("PrimaryBlue")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .padding()
            .background(backgroundColor)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Usage examples:
// Button("Primary Action") {}.buttonStyle(PrimaryButtonStyle())
// Button("Secondary Action") {}.buttonStyle(SecondaryButtonStyle())
// Button("Delete") {}.buttonStyle(DestructiveButtonStyle())
// Button(action: {}) { Image(systemName: "plus") }.buttonStyle(IconButtonStyle())
