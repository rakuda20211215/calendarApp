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
                    VStack(alignment: .center) {
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
                        SimpleColorSelect(selectedColor: $selectedColor, hexColor: $hexColor)
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

#Preview {
    AddEKCalendar()
        .backgroundStyle(.gray)
        .environmentObject(CustomColor(foreGround: .black, backGround: .white))
}
