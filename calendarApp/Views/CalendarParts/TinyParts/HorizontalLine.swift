//
//  HorizontalLine.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/10.
//

import SwiftUI

struct HorizontalLine: View {
    let color: Color
    init(color: Color = .gray) {
        self.color = color
    }
    var body: some View {
        GeometryReader { geometry in
            let width:CGFloat = geometry.size.width
            Rectangle()
                .fill(color)
                .frame(width: width)
        }
    }
}


#Preview {
    HorizontalLine()
}
