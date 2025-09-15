//
//  CharacterCard.swift
//  ZombieRush
//
//  Created by 김민성 on 9/15/25.
//

import SwiftUI

struct CharacterCard: View {
    var body: some View {
        VStack {
            characterImage
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        .blur(radius: 0.5)
                )
        )
    }
    
    private var characterImage: some View {
        Image(systemName: "person.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
    }
    
    
}

#Preview {
    CharacterCard()
}
