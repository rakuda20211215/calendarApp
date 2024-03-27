//
//  MenuView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/03.
//

import SwiftUI
/*
 
 
 次：　カレンダーの詳細画面　と　イベントの詳細画面　！！！！！！！！！！！！！！！！！！
 
 
 */

struct MenuView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var customColor: CustomColor
    @ObservedObject private var switchableEKResults: SwitchableEKResults = SwitchableEKResults()
    @State private var searchText: String = ""
    @State private var isShowingAdd: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let monthWeekButtonSize: CGFloat = 40
            ScrollView {
                VStack {
                    TextField("検索", text: $searchText)
                        .padding(8)
                        .background(customColor.backGround.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                        .padding()
                    HStack {
                        Spacer()
                        Button {
                            
                        } label: {
                            Text(30.description)
                                .frame(width: monthWeekButtonSize, height: monthWeekButtonSize)
                                .foregroundStyle(customColor.foreGround)
                                .background(customColor.backGround.opacity(0.8))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Text(7.description)
                                .frame(width: monthWeekButtonSize, height: monthWeekButtonSize)
                                .foregroundStyle(customColor.backGround)
                                .background(customColor.backGround.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding()
                    VStack(alignment: .leading) {
                        Text("カレンダー")
                        //.foregroundStyle(.white)
                            .fontWeight(.bold)
                            .font(.system(size: 22))
                            .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("カレンダーを追加")
                        }
                        .onTapGesture {
                            isShowingAdd.toggle()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .sheet(isPresented: $isShowingAdd) {
                            AddEKCalendar()
                        }
                        VStack {
                            Text("表示中")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 13))
                            //.foregroundStyle(.white)
                            EKCalendarTab() { isShown in
                                return isShown == true
                            }
                            .environmentObject(switchableEKResults)
                            Text("非表示")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 13))
                            //.foregroundStyle(.white)
                            EKCalendarTab() { isShown in
                                return isShown == false
                            }
                            .environmentObject(switchableEKResults)
                        }
                        .animation(.easeInOut, value: switchableEKResults.animate)
                    }
                    .padding()
                    
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.bold)
                    //.foregroundStyle(customColor.backGround)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "gear")
                    //.foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(CustomColor(foreGround: .black, backGround: .white))
        .background(.gray)
}
