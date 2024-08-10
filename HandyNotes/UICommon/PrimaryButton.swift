//
//  PrimaryButton.swift
//  HandyNotes
//
//  Created by Aman on 10/08/24.
//


import SwiftUI

struct PrimaryButton: View {
    var title: String
    var onPressed: (() -> Void)?

    var body: some View {
        Button(action: {
            onPressed?()
        }) {
            ZStack {
                Image("primary_btn")
                    .resizable()
                    .scaledToFill()
                    .padding(.horizontal, 20)
                    .frame(width: .screenWidth, height: 48)
                Text(title)
                    .font(.customfont(.semibold, fontSize: 14))
                    .padding(.horizontal, 20)
            }
            .foregroundColor(.white)
            .shadow(color: .secondaryC.opacity(0.3), radius: 5, y: 3)
        }
    }
}

#Preview {
    PrimaryButton(title: "Log in")
}
