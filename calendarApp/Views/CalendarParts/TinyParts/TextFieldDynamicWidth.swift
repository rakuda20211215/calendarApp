//
//  TextFieldDynamicWidth.swift
//
//  Created by Joseph Hinkle on 9/10/20.
//  gitHub: https://github.com/joehinkle11/TextFieldDynamicWidth/blob/main/TextFieldDynamicWidth.swift
//
//  2024/3/13 蒔苗純平 編集

import SwiftUI

struct TextFieldDynamicWidth<T: View>: View {
    @Binding var text: String
    let titleLabel: () -> T
    @State private var titleRect = CGRect()
    @State private var textRect = CGRect()
    
    var body: some View {
        ZStack {
            titleLabel().background(GlobalGeometryGetter(rect: $titleRect)).layoutPriority(1).opacity(0)
            Text(text).background(GlobalGeometryGetter(rect: $textRect)).layoutPriority(1).opacity(0)
            HStack {
                TextField(text: $text, label: titleLabel)
                    .frame(width: max(titleRect.width, textRect.width))
            }
        }
    }
}

//
//  GlobalGeometryGetter
//
// source: https://stackoverflow.com/a/56729880/3902590
//

struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}
