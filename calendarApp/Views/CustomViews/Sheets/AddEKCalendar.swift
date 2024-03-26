//
//  AddEKCalendar.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/10.
//

import SwiftUI

struct AddEKCalendar: View {
    @FocusState private var focusedField: Field?
    enum Field {
        case title
        case color
    }
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customColor: CustomColor
    @State private var calendarTitle: String = ""
    @State private var selectedColor: CGColor = CGColor(red: 0.6, green: 0.1, blue: 0, alpha: 1)
    @State private var hexColor: String = ""
    @State private var isSimple: Bool = true
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            NavigationStack {
                VStack {
                    HStack {
                        Rectangle()
                            .foregroundStyle(Color(selectedColor))
                            .frame(width: 20,height: 20)
                            .clipShape(Circle())
                            .padding(5)
                        TextFieldDynamicWidth(text: $calendarTitle) {
                            Text("タイトル")
                                .foregroundStyle(customColor.backGround.opacity(0.4))
                        }
                        .foregroundStyle(customColor.backGround)
                        .font(.system(size: 25,weight: .bold))
                        .focused($focusedField, equals: .title)
                        .onTapGesture {
                            focusedField = .title
                        }
                    }
                    .padding()
                    let paddingSize: CGFloat = 10
                    VStack {
                        HStack {
                            Text("カラー")
                                .font(.system(size: 18, weight: .medium))
                                .padding()
                            Spacer()
                            /*
                            Button {
                                isSimple.toggle()
                            } label: {
                                if isSimple {
                                    Text("カスタム")
                                        .foregroundStyle(customColor.foreGround)
                                        .padding(9)
                                        .background(customColor.backGround)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                } else {
                                    Text("シンプル")
                                        .foregroundStyle(.white)
                                        .padding(9)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(style: .init(lineWidth: 2))
                                        }
                                }
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .padding()
                             */
                            
                            HStack {
                                TextField( hexColor, text: $hexColor)
                                    .frame(width: 100)
                                    .foregroundStyle(.black)
                                    .padding(3)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
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
                                    .focused($focusedField, equals: .color)
                                    .onTapGesture {
                                        focusedField = .color
                                    }
                            }
                            .font(.system(size: 15))
                            .padding()
                        }
                        SimpleColorSelect(selectedColor: $selectedColor, hexColor: $hexColor, width: width - paddingSize * 2)
                        /*
                        if isSimple {
                            SimpleColorSelect(selectedColor: $selectedColor, hexColor: $hexColor, width: width - paddingSize * 2)
                        } else {
                            DetailColorSelect(selectedColor: $selectedColor)
                        }*/
                    }
                    .padding(paddingSize)
                    Spacer()
                }
                .foregroundStyle(customColor.backGround)
                .background(customColor.homeBack)
                .onTapGesture {
                    focusedField = nil
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            print(EventData.eventStore.sources.map({$0.sourceType.rawValue.description}))
                            dismiss()
                        } label: {
                            Text("キャンセル")
                                .foregroundStyle(customColor.cancel)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("新規カレンダー")
                            .foregroundStyle(customColor.backGround)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if calendarTitle != "" {
                            Button {
                                if EventController.addCalendar(nameCalendar: calendarTitle, cgColor: selectedColor),
                                   SwitchableEKCalendar.sync() {
                                    print("ok")
                                } else {
                                    print("失敗")
                                }
                                dismiss()
                            } label: {
                                Text("追加")
                                    .foregroundStyle(customColor.complete)
                            }
                        } else {
                            Text("追加")
                                .foregroundStyle(customColor.invalid)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct SimpleColorSelect: View {
    @Binding var selectedColor: CGColor
    @Binding var hexColor: String
    let width: CGFloat
    let colorSelection: [CGColor] = [
        CGColor(red: 1, green: 0, blue: 0, alpha: 1),
        CGColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1),
        CGColor(red: 1, green: 1, blue: 0, alpha: 1),
        CGColor(red: 0.6, green: 1, blue: 0, alpha: 1),
        CGColor(red: 0.2, green: 0.4, blue: 0, alpha: 1),
        CGColor(red: 0, green: 0.8, blue: 0.4, alpha: 1),
        CGColor(red: 0, green: 0.8, blue: 0.8, alpha: 1),
        CGColor(red: 0, green: 0.5, blue: 1, alpha: 1),
        CGColor(red: 0, green: 0, blue: 0.9, alpha: 1),
        CGColor(red: 0.4, green: 0, blue: 0.9, alpha: 1),
        CGColor(red: 0.8, green: 0, blue: 0.8, alpha: 1),
        CGColor(red: 0.8, green: 0, blue: 0.5, alpha: 1),
        CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
        CGColor(red: 1, green: 1, blue: 1, alpha: 1),
        CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    ]
    var body: some View {
        let minColorSize: CGFloat = 60
        let space: CGFloat = 5
        let numColumn = Int(width / (minColorSize + space))
        let colorSize = width / CGFloat(numColumn) - space * 2
        var numRow: Int {
            print(width, numColumn)
            return !colorSelection.isEmpty && numColumn != 0 ? (colorSelection.count / numColumn) : 0
        }
        
        VStack(alignment: .center, spacing: 0) {
            ForEach(0...numRow, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<numColumn, id: \.self) { column in
                        if colorSelection.indices.contains((row * numColumn) + column) {
                            let color = colorSelection[(row * numColumn) + column]
                            Button {
                                selectedColor = color
                                if let hex = color.colorToHex() {
                                    hexColor = hex
                                }
                            } label: {
                                Rectangle()
                                    .frame(width: colorSize, height: colorSize)
                                    .foregroundStyle(Color(color))
                                    .clipShape(Circle())
                            }
                            .padding(space)
                        }
                    }
                }
            }
        }
        //.frame(height: (colorSize + space * CGFloat(2)) * CGFloat(numColumn))
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
    AddEKCalendar()
        .backgroundStyle(.gray)
        .environmentObject(CustomColor(foreGround: .black, backGround: .white))
}
