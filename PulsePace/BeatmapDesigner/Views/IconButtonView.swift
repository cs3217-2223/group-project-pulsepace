//
//  PlaybackControlButtonView.swift
//  PulsePace
//
//  Created by Peter Jung on 2023/03/11.
//

import SwiftUI

struct IconButtonView: View {
    var systemName: String = "play"
    var fontSize: CGFloat = 24
    var color: Color = .accentColor
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: fontSize))
                .foregroundColor(color)
        }
    }
}

struct PlaybackControlButtonView_Previews: PreviewProvider {
    static var previews: some View {
        IconButtonView(action: {})
    }
}
