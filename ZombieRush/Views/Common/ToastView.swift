//
//  ToastView.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

struct ToastView: View {
    @Environment(ToastManager.self) var toastManager
        
    var body: some View {
        if let toast = toastManager.currentToast {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                VStack(alignment: .leading) {
                    Text(toast.title)
                        .bold()
                    if let desc = toast.description {
                        Text(desc)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    ToastView()
}
