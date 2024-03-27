//
//  SimpleColorPicker.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/27.
//

import SwiftUI

struct SimpleColorPicker: View {
    @FocusState private var focusedField: Bool
    @State var selectedColor: CGColor = CGColor(gray: 1, alpha: 1)
    @State var hexColor: String = ""
    var body: some View {
        HStack {
            Spacer()
            TextField( hexColor, text: $hexColor)
                .frame(width: 100)
                .foregroundStyle(.black)
                .padding(3)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: .init(lineWidth: 1))
                }
                .onAppear {
                    if let hex = selectedColor.colorToHex() {
                        hexColor = hex
                    }
                }
                .onChange(of: hexColor) { _ in
                    if let color = CGColor.hexToColor(hex: hexColor) {
                        selectedColor = color
                    }
                }
                .focused($focusedField)
        }
        .font(.system(size: 15))
        .padding()
        SimpleColorSelect(selectedColor: $selectedColor, hexColor: $hexColor)
    }
}

struct SimpleColorSelect: View {
    @Binding var selectedColor: CGColor
    @Binding var hexColor: String
    let spectrumNum = 12
    var colorSelection: [CGColor] {
        var colorS: [CGColor] = []
        if let colors = makeSpectrum(start: CGColor(red: 1, green: 0.0, blue: 0.0, alpha: 1), end: CGColor(red: 1, green: 0.9, blue: 0.9, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0.5, green: 0.1, blue: 0, alpha: 1), end: CGColor(red: 1, green: 1, blue: 0.8, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0.7, green: 0.7, blue: 0.0, alpha: 1), end: CGColor(red: 1, green: 0.9, blue: 0.9, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0.2, green: 0.4, blue: 0, alpha: 1), end: CGColor(red: 1, green: 1, blue: 0.9, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0, green: 0.7, blue: 0.3, alpha: 1), end: CGColor(red: 0.9, green: 1, blue: 0.9, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0, green: 0.8, blue: 0.8, alpha: 1), end: CGColor(red: 0.9, green: 1, blue: 1, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0, green: 0.5, blue: 1, alpha: 1), end: CGColor(red: 0.8, green: 0.9, blue: 1, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0, green: 0, blue: 0.9, alpha: 1), end: CGColor(red: 0.9, green: 0.9, blue: 1, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0.8, green: 0, blue: 0.8, alpha: 1), end: CGColor(red: 1, green: 0.9, blue: 1, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        if let colors = makeSpectrum(start: CGColor(red: 0, green: 0, blue: 0, alpha: 1), end: CGColor(red: 1, green: 1, blue: 1, alpha: 1), num: spectrumNum) {
            colorS += colors
        }
        return colorS
    }
    var body: some View {
        GeometryReader { geometry in
            let colorSize = (geometry.size.width) / CGFloat(spectrumNum)
            
            VStack(alignment: .center, spacing: 0) {
                ForEach(0...colorSelection.count, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<spectrumNum, id: \.self) { column in
                            if colorSelection.indices.contains((row * spectrumNum) + column) {
                                let color = colorSelection[(row * spectrumNum) + column]
                                Button {
                                    selectedColor = color
                                    if let hex = color.colorToHex() {
                                        hexColor = hex
                                    }
                                } label: {
                                    Rectangle()
                                        .frame(width: colorSize, height: colorSize)
                                        .foregroundStyle(Color(color))
                                }
                            }
                        }
                    }
                }
            }
            //.frame(height: (colorSize + space * CGFloat(2)) * CGFloat(numColumn))
        }
    }
    
    func makeSpectrum(start: CGColor, end: CGColor, num: Int) -> [CGColor]? {
        guard num > 0 else { return nil }
        guard var startFloats = start.componentsFloat,
              var endFloats = end.componentsFloat else { return nil }
        if startFloats.count != 4 {
            startFloats = [startFloats[0], startFloats[0], startFloats[0], startFloats[1]]
        }
        if endFloats.count != 4 {
            endFloats = [endFloats[0], endFloats[0], endFloats[0], endFloats[1]]
        }
        guard startFloats.count == 4 && endFloats.count == 4 else { return nil }
        
        let intervalR = (endFloats[0] - startFloats[0]) / Float(num)
        let intervalG = (endFloats[1] - startFloats[1]) / Float(num)
        let intervalB = (endFloats[2] - startFloats[2]) / Float(num)
        
        var colors: [CGColor] = []
        for index in 0..<num {
            guard let color = CGColor.fromFloats(floats: [
                startFloats[0] + (intervalR * Float(index)),
                startFloats[1] + (intervalG * Float(index)),
                startFloats[2] + (intervalB * Float(index))
            ]) else { continue }
            colors.append(color)
        }
        guard colors.count == num else { return nil }
        return colors
    }
}


struct DetailColorSelect: View {
    @EnvironmentObject private var customColor: CustomColor
    @Binding var selectedColor: CGColor
    let rgbColors: [CGColor] = [
        CGColor(red: 1, green: 0.1, blue: 0.1, alpha: 1),
        CGColor(red: 0, green: 1, blue: 0, alpha: 1),
        CGColor(red: 0, green: 0, blue: 1, alpha: 1)
    ]
    
    var body: some View {
        VStack {
            ForEach(0..<rgbColors.count, id: \.self) { index in
                HStack {
                    ZStack(alignment: .center) {
                        /*
                         Rectangle()
                         .foregroundStyle(.white)
                         .frame(width: 40, height: 40)*/
                        Image(systemName: "minus")
                            .font(.system(size: 40))
                            .contentShape(Rectangle())
                            .onLongPressRepeatGesture {
                                setRGB(index, add: -1)
                            } startedAction: {
                                setRGB(index, add: -1)
                            }
                    }
                    if let rgbInt = selectedColor.components?[index] {
                        Text("\(Int(rgbInt * 255))")
                            .foregroundStyle(customColor.backGround)
                            .font(.system(size: 19))
                            .frame(width: 70)
                    }
                    ZStack(alignment: .center) {
                        Image(systemName: "plus")
                            .font(.system(size: 40))
                            .contentShape(Rectangle())
                            .onLongPressRepeatGesture {
                                setRGB(index, add: 1)
                            } startedAction: {
                                setRGB(index, add: 1)
                            }
                    }
                }
                .padding(7)
                .background(Color(rgbColors[index]).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(5)
            }
        }
    }
    
    func setRGB(_ index: Int, add: CGFloat) {
        print(add)
        guard var rgbComponents: [CGFloat] = selectedColor.components else { return }
        rgbComponents[index] = (rgbComponents[index] * 255 + add) / 255
        selectedColor = CGColor(red: rgbComponents[0], green: rgbComponents[1], blue: rgbComponents[2], alpha: 1)
    }
}
#Preview {
    SimpleColorPicker()
}
