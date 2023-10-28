//
//  RecurrencePicker.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/28.
//

import SwiftUI
import EventKit

struct RecurrencePicker: View {
    @State var ekEvent: EKEvent = createEvent(day: 5)
    @State private var isValid: Bool = false
    @State private var recurrenceRule: EKRecurrenceRule = .init(recurrenceWith: .daily, interval: 1, end: nil)
    
    @State private var selectedItem: String = "日"
    
    enum Flavor: String, CaseIterable, Identifiable {
        case chocolate, vanilla, strawberry
        var id: Self { self }
    }
    
    
    @State private var selectedFlavor: Flavor = .chocolate
    
    var body: some View {
        /*
         GeometryReader { geometry in
         let width = geometry.size.width
         let height = geometry.size.height
         let paddingTenPer = width / CGFloat(10)
         let paddingTen: CGFloat = 10
         VStack {
         Button {
         isValid.toggle()
         } label: {
         HStack {
         Text("繰り返し間隔")
         .padding(EdgeInsets(top: 0, leading: paddingTenPer, bottom: paddingTen, trailing: 0))
         Spacer()
         Text("\(selectedItem)")
         .fontWeight(.bold)
         .padding(EdgeInsets(top: 0, leading: 0, bottom: paddingTen, trailing: 0))
         .frame(width: width / 2 - 15)
         }
         }
         .foregroundColor(.black)
         .sheet(isPresented: $isValid) {
         ekEvent.removeRecurrenceRule(recurrenceRule)
         
         } content: {
         RecurrenceSheet(recurrenceRule: $recurrenceRule)
         //.frame(width: width, height: height)
         }
         
         }
         .frame(width: width, height: height)
         
         }
         .frame(height: 150)
         */
        RecurrenceSheet(recurrenceRule: $recurrenceRule)
        
    }
}

struct RecurrenceSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var recurrenceRule: EKRecurrenceRule
    @State private var frequency: EKRecurrenceFrequency?
    @State private var interval: Int = 1
    private var isValid: Bool {
        frequency == nil ? false : true
    }
    
    let pickerItem = [
        "日": EKRecurrenceFrequency.daily,
        "週": EKRecurrenceFrequency.weekly,
        "月": EKRecurrenceFrequency.monthly,
        "年": EKRecurrenceFrequency.yearly,
    ]
    
    var intervalUnit: String {
        switch frequency {
        case .daily:
            return interval == 1 ? "日" : "日 おき"
        case .weekly:
            return interval == 1 ? "週" : "週 おき"
        case .monthly:
            return interval == 1 ? "月" : "ヶ月 おき"
        case .yearly:
            return interval == 1 ? "年" : "年 おき"
        default:
            return ""
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let padding: CGFloat = 15
            NavigationStack {
                VStack(spacing: 0) {
                    
                    Picker("繰り返し", selection: $frequency) {
                        Text("しない").tag(Optional<EKRecurrenceFrequency>(nil))
                    }
                    .pickerStyle(.segmented)
                    .padding(padding)
                    
                    Picker("繰り返し", selection: $frequency) {
                        ForEach(pickerItem.sorted(by: { $0.value.rawValue < $1.value.rawValue }).map{ $0.key }, id: \.self) { key in
                            Text(key).tag(pickerItem[key])
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(padding)
                    
                    
                    //Text(pickerItem.first(where: {$1 == frequency})?.key ?? "なし")
                    HStack(spacing: 0) {
                        if isValid {
                            VerticalWheelPicker(initialCenterItem: 1, numItem: 3, items: Array(1...555)) { item in
                                Text(item == 1 ? "毎" : "\(item)")
                                    .font(.system(size: 14))
                            } onChangeEvent: { item in
                                interval = item
                            }
                            .frame(width: 30, height: 100)
                            .padding(EdgeInsets(top: 0, leading: width / 2 - 15, bottom: 0, trailing: 0))
                            Text(intervalUnit)
                                .font(.system(size: 11))
                                .padding(5)
                        }
                    }
                    .background(.white)
                    .frame(width: width, alignment: .leading)
                    .animation(.easeIn, value: isValid)
                    
                    // ここからーーーーーーーーーーーーーーーー
                    // switch でそれぞれのview表示　ここでanimationすればいいかも！！
                    
                    Spacer()
                }
                //.background(.gray)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar() {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("キャンセル")
                                .foregroundStyle(.red)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("繰り返し")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Text("完了")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RecurrencePicker()
}
