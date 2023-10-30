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
    @StateObject private var recurrenceRuleObj: RecurrenceRuleObj
    
    @State private var date: Date = Date()
    @State private var selectedItem: String = "日"
    
    init() {
        let recurrenceRules: [EKRecurrenceRule]? = createEvent(day: 5).hasRecurrenceRules ? createEvent(day: 5).recurrenceRules : nil
        self._recurrenceRuleObj = StateObject(wrappedValue: RecurrenceRuleObj(recurrenceRules: recurrenceRules, date: Date()))
    }
    
    var body: some View {
        //RecurrenceSheet(recurrenceRuleObj: recurrenceRuleObj)
        
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
                   // ekEvent.removeRecurrenceRule(recurrenceRule)
                    
                } content: {
                    RecurrenceSheet(recurrenceRuleObj: recurrenceRuleObj)
                    //.frame(width: width, height: height)
                }
                
            }
            .frame(width: width, height: height)
            
        }
        .frame(height: 150)
        
        
    }
}

struct RecurrenceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var recurrenceRuleObj: RecurrenceRuleObj
    let weeks = getInfoMonth(date: Date()).getWeek()
    
    var isValid: Bool {
        recurrenceRuleObj.frequency == nil ? false : true
    }
    
    @State private var switchMonthWeek: Bool = true
    @State private var isWeekYear: Bool = false
    
    var daysWeekToInt: [Int] {
        guard let daysWeek = recurrenceRuleObj.selectedDaysWeek else { return [-1] }
        return daysWeek.map { $0.dayOfTheWeek.rawValue }
    }
    
    var selectedMonthWeekItem: String {
        guard let element = recurrenceRuleObj.ekMonthWeekItem.first(where: {
            $0.value == daysWeekToInt.sorted(by: { $0 < $1 })
        }) else { return recurrenceRuleObj.monthWeekItem[0] }
        
        return element.key
    }
    
    var selectedSetPositions: Int {
        guard let setPositions = recurrenceRuleObj.setPositions else { return recurrenceRuleObj.numWeekMonth[0] }
        return setPositions.first!.intValue
    }
    
    var daysMonthToInt: [Int] {
        guard let daysMonth = recurrenceRuleObj.selectedDaysMonth else { return [-1] }
        return daysMonth.map { $0.intValue }
    }
    
    var monthsYearToInt: [Int] {
        guard let monthsYear = recurrenceRuleObj.selectedMonthsYear else { return [-1] }
        return monthsYear.map { $0.intValue }
    }
    
    var eventStr: String {
        let interval = recurrenceRuleObj.interval
        var str = "\(interval == 1 ? "毎" : "\(interval)")\(recurrenceRuleObj.intervalUnit)"
        print(str)
        switch recurrenceRuleObj.frequency {
        case .daily:
            print(str)
            guard interval != 1 else { break }
            str = "\(str)に"
        case .weekly:
            var weekStr = ""
            guard daysWeekToInt.first != -1 else { return weekStr }
            let weeksLong = daysWeekToInt.sorted(by: { $0 < $1 }).map({ weeks[$0 - 1] })
            print("\(daysWeekToInt[0])")
            for week in weeksLong {
                weekStr = "\(weekStr)\(weeksLong.firstIndex(of: week) == 0 ? " " : "、")\(week)曜日"
            }
            str = "\(str)\( weekStr )に"
        case .monthly:
            if switchMonthWeek {
                var dayStr = ""
                guard daysMonthToInt.first != -1 else { return dayStr }
                let days = daysMonthToInt.sorted(by: { $0 < $1 })
                for day in days {
                    dayStr = "\(dayStr)\(days.firstIndex(of: day) == 0 ? " " : "、")\(day)日"
                }
                str = "\(str)\(dayStr)に"
            } else {
                guard let setPositions = recurrenceRuleObj.setPositions else { return "" }
                str = "\(str)\(setPositions[0].intValue != -1 ? "第\(setPositions[0].intValue)" : "最後の" )\(selectedMonthWeekItem)に"
            }
        case .yearly:
            var monthStr = ""
            let months = monthsYearToInt.sorted(by: { $0 < $1 })
            guard months.first != -1 else { return monthStr }
            for month in months {
                monthStr = "\(monthStr)\(month)月\(months.firstIndex(of: month) == months.count - 1 ? (isWeekYear ? "の" : "に") : "、")"
            }
            str = "\(str)\(monthStr)"
            if isWeekYear {
                guard let setPositions = recurrenceRuleObj.setPositions else { return "" }
                str = "\(str)\(setPositions[0].intValue != -1 ? "第\(setPositions[0].intValue)" : "最後の" )\(selectedMonthWeekItem)に"
            }
        default:
            return ""
        }
        print(str)
        
        return "\(str)あるイベント"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let padding: CGFloat = 15
            NavigationStack {
                VStack(spacing: 0) {
                    //ScrollView {
                    Picker("繰り返し", selection: $recurrenceRuleObj.frequency) {
                        Text("しない").tag(Optional<EKRecurrenceFrequency>(nil))
                    }
                    .onChange(of: recurrenceRuleObj.frequency) { fre in
                        if fre == nil { recurrenceRuleObj.interval = 1 }
                        recurrenceRuleObj.reset(frequency: nil)
                        recurrenceRuleObj.reset(frequency: fre)
                        switchMonthWeek = true
                        isWeekYear = false
                    }
                    .pickerStyle(.segmented)
                    .padding(padding)
                    
                    Picker("繰り返し", selection: $recurrenceRuleObj.frequency) {
                        ForEach(recurrenceRuleObj.pickerItem
                            .sorted(by: { $0.value.rawValue < $1.value.rawValue })
                            .map{ $0.key }, id: \.self) { key in
                                Text(key).tag(recurrenceRuleObj.pickerItem[key])
                            }
                    }
                    .pickerStyle(.segmented)
                    .padding(padding)
                    if isValid {
                        Text(eventStr)
                            .font(.system(size: 11))
                            .padding(EdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding))
                            .frame(width: width, alignment: .leading)
                    }
                    
                    //日/その他----------------------------------------------
                    HStack(spacing: 0) {
                        if isValid {
                            VerticalWheelPicker(initialCenterItem: recurrenceRuleObj.interval, numItem: 3, items: Array(1...555)) { item in
                                Text(item == 1 ? "毎" : "\(item)")
                                    .font(.system(size: 14))
                            } onChangeEvent: { item in
                                recurrenceRuleObj.interval = item
                            }
                            .frame(width: 30, height: (height * 0.2) * 0.7)
                            .padding(EdgeInsets(top: 0, leading: width / 2 - 15, bottom: 0, trailing: 0))
                            Text(recurrenceRuleObj.intervalUnit)
                                .font(.system(size: 11))
                                .padding(5)
                        }
                    }
                    .background(.white)
                    .frame(width: width, height: height * 0.16, alignment: .leading)
                    .padding(EdgeInsets(top: padding, leading: 0, bottom: padding * 2, trailing: 0))
                    .animation(.easeIn, value: isValid)
                    
                    switch recurrenceRuleObj.frequency {
                        //週----------------------------------------------------
                    case .weekly:
                        HStack(spacing: 0) {
                            ForEach(1...weeks.count, id: \.self) { weekDay in
                                Button {
                                    if daysWeekToInt.contains(weekDay) {
                                        recurrenceRuleObj.removeDayWeek(dayWeek: weekDay)
                                    } else {
                                        recurrenceRuleObj.addDayWeek(dayWeek: weekDay)
                                    }
                                } label: {
                                    Text(weeks[weekDay - 1])
                                        .font(.system(size: 14))
                                        .underline(color:
                                                    Calendar.current.component(.weekday, from: Date()) == weekDay ?
                                                   ( daysWeekToInt.contains(weekDay) ? .white : .black ) : .clear
                                        )
                                        .foregroundStyle(daysWeekToInt.contains(weekDay) ? .white : .black)
                                        .frame(width: 26, height: 26)
                                        .background(daysWeekToInt.contains(weekDay) ? .black : .white)
                                        .cornerRadius(13)
                                        .frame(width: (width - padding) / 7)
                                }
                            }
                        }
                        //月----------------------------------------------------
                    case .monthly:
                        Picker("月か曜日", selection: $switchMonthWeek) {
                            Text("日付").tag(true)
                            Text("曜日").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: width / 2)
                        .onChange(of: switchMonthWeek) { bool in
                            /*
                             recurrenceRuleObj.reset(frequency: nil)
                             if bool {
                             recurrenceRuleObj.reset(frequency: .monthly)
                             } else {
                             recurrenceRuleObj.reset(frequency: .monthly, element: .week)
                             }*/
                        }
                        if switchMonthWeek {
                            VStack(spacing: 0) {
                                ForEach(0..<5, id: \.self) { row in
                                    HStack(spacing: 0) {
                                        ForEach(0..<7, id: \.self) { column in
                                            let day = row * 7 + (column + 1)
                                            if 1...31 ~= day {
                                                Button {
                                                    if daysMonthToInt.contains(day){
                                                        recurrenceRuleObj.removeDayMonth(day: day)
                                                    } else {
                                                        recurrenceRuleObj.addDayMonth(day: day)
                                                    }
                                                } label: {
                                                    Text("\(day)")
                                                        .font(.system(size: 13))
                                                        .underline(color:
                                                                    Calendar.current.component(.day, from: Date()) == day ?
                                                                   ( daysMonthToInt.contains(day) ? .white : .black ) : .clear
                                                        )
                                                        .foregroundStyle(daysMonthToInt.contains(day) ? .white : .black)
                                                }
                                                .frame(width: 26, height: 26)
                                                .background(daysMonthToInt.contains(day) ? .black : .white)
                                                .cornerRadius(13)
                                                .clipped()
                                                //.padding(EdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0))
                                                .padding()
                                                .frame(width: (width - padding) / 7, height: (height * 0.4) / 5)
                                            } else {
                                                Text("")
                                                //.padding(padding)
                                                    .frame(width: (width - padding) / 7)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            HStack(spacing: 0) {
                                VerticalWheelPicker(initialCenterItem: selectedSetPositions, numItem: 3, items: recurrenceRuleObj.numWeekMonth) { num in
                                    Text(num != -1 ? "第\(num)" : "最後" )
                                } onChangeEvent: { num in
                                    recurrenceRuleObj.setPositions = [NSNumber(value: num)]
                                }
                                .frame(width: 50, height: 120)
                                .padding(EdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0))
                                
                                VerticalWheelPicker(initialCenterItem: selectedMonthWeekItem, numItem: 3, items: recurrenceRuleObj.monthWeekItem) { item in
                                    Text(item)
                                } onChangeEvent: { item in
                                    recurrenceRuleObj.selectedDaysWeek = recurrenceRuleObj.ekMonthWeekItem[item]!.map { EKRecurrenceDayOfWeek(EKWeekday(rawValue: $0)!) }
                                }
                                .frame(width: 100,height: 120)
                                .padding(EdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0))
                            }
                            
                        }
                        //年----------------------------------------------------
                    case .yearly:
                        ForEach(0..<2, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<6, id: \.self) { column in
                                    let month = row * 6 + column + 1
                                    Button {
                                        if monthsYearToInt.contains(month) {
                                            recurrenceRuleObj.removeMonthYear(month: month)
                                        } else {
                                            recurrenceRuleObj.addMonthYear(month: month)
                                        }
                                    } label: {
                                        Text("\(month)")
                                            .font(.system(size: 13))
                                            .underline(color:
                                                        Calendar.current.component(.month, from: Date()) == month ?
                                                       ( monthsYearToInt.contains(month) ? .white : .black ) : .clear
                                            )
                                            .foregroundStyle(monthsYearToInt.contains(month) ? .white : .black)
                                            .frame(width: 26, height: 26)
                                            .background(monthsYearToInt.contains(month) ? .black : .white)
                                            .cornerRadius(13)
                                            .frame(width: (width - padding) / 7)
                                            .padding(EdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0))
                                    }
                                    .frame(width: (width - padding) / 6, height: 50)
                                }
                            }
                        }
                        VStack {
                            Toggle("曜日", isOn: $isWeekYear)
                                .frame(width: 100)
                                .padding(padding)
                                .frame(width: width, alignment: .trailing)
                                .onChange(of: isWeekYear) { bool in
                                    /*
                                     if bool {
                                     recurrenceRuleObj.reset(frequency: .monthly, element: .week)
                                     } else {
                                     recurrenceRuleObj.selectedDaysWeek = nil
                                     recurrenceRuleObj.setPositions = nil
                                     }
                                     */
                                }
                            if isWeekYear {
                                HStack(spacing: 0) {
                                    VerticalWheelPicker(initialCenterItem: selectedSetPositions, numItem: 3, items: recurrenceRuleObj.numWeekMonth) { num in
                                        Text(num != -1 ? "第\(num)" : "最後" )
                                    } onChangeEvent: { num in
                                        recurrenceRuleObj.setPositions = [NSNumber(value: num)]
                                    }
                                    .frame(width: 50, height: 120)
                                    .padding(EdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0))
                                    
                                    VerticalWheelPicker(initialCenterItem: selectedMonthWeekItem, numItem: 3, items: recurrenceRuleObj.monthWeekItem) { item in
                                        Text(item)
                                    } onChangeEvent: { item in
                                        recurrenceRuleObj.selectedDaysWeek = recurrenceRuleObj.ekMonthWeekItem[item]!.map { EKRecurrenceDayOfWeek(EKWeekday(rawValue: $0)!)
                                        }
                                    }
                                    .frame(width: 100,height: 120)
                                    .padding(EdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0))
                                }
                            }
                        }
                        .animation(.default, value: isWeekYear)
                        .onAppear {
                            recurrenceRuleObj.reset(frequency: .monthly, element: .week)
                        }
                        
                    default:
                        Spacer()
                    }
                    
                    Spacer()
                    //}
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
                            recurrenceRuleObj.allPrint()
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

enum dateElements {
    case year
    case month
    case week
    case day
    case hour
    case minute
}

class RecurrenceRuleObj: ObservableObject {
    @Published var recurrenceRules: [EKRecurrenceRule]?
    @Published var frequency: EKRecurrenceFrequency?
    @Published var recurrenceEnd: EKRecurrenceEnd?
    @Published var interval: Int = 1
    @Published var selectedDaysWeek: [EKRecurrenceDayOfWeek]?
    @Published var selectedDaysMonth: [NSNumber]?
    @Published var selectedDaysYear: [NSNumber]?
    @Published var selectedWeeksYear: [NSNumber]?
    @Published var selectedMonthsYear: [NSNumber]?
    @Published var setPositions: [NSNumber]?
    var date: Date
    
    init(recurrenceRules: [EKRecurrenceRule]?, date: Date) {
        self.recurrenceRules = recurrenceRules
        if recurrenceRules != nil {
            for rule in recurrenceRules! {
                self.frequency = rule.frequency
                if rule.recurrenceEnd != nil { self.recurrenceEnd = rule.recurrenceEnd }
                self.interval = rule.interval
                if rule.daysOfTheWeek != nil { self.selectedDaysWeek = rule.daysOfTheWeek }
                if rule.daysOfTheMonth != nil { self.selectedDaysMonth = rule.daysOfTheMonth }
                if rule.daysOfTheYear != nil { self.selectedDaysYear = rule.daysOfTheYear }
                if rule.weeksOfTheYear != nil { self.selectedWeeksYear = rule.weeksOfTheYear }
                if rule.monthsOfTheYear != nil { self.selectedMonthsYear = rule.monthsOfTheYear }
                if rule.setPositions != nil { self.setPositions = rule.setPositions }
            }
        }
        self.date = date
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ja_JP")
        self.monthWeekItem = calendar.weekdaySymbols + ["平日","週末","日"]
        self.ekMonthWeekItem = [
            self.monthWeekItem[0]: [1],
            self.monthWeekItem[1]: [2],
            self.monthWeekItem[2]: [3],
            self.monthWeekItem[3]: [4],
            self.monthWeekItem[4]: [5],
            self.monthWeekItem[5]: [6],
            self.monthWeekItem[6]: [7],
            self.monthWeekItem[7]: [2,3,4,5,6],
            self.monthWeekItem[8]: [1,7],
            self.monthWeekItem[9]: [1,2,3,4,5,6,7]
        ]
    }
    
    let pickerItem = [
        "日": EKRecurrenceFrequency.daily,
        "週": EKRecurrenceFrequency.weekly,
        "月": EKRecurrenceFrequency.monthly,
        "年": EKRecurrenceFrequency.yearly,
    ]
    
    /*
     let numWeekMonth = [
     "第1": 1,
     "第2": 2,
     "第3": 3,
     "第4": 4,
     "第5": 5,
     "最後": -1
     ]*/
    
    let numWeekMonth = [
        1,
        2,
        3,
        4,
        5,
        -1
    ]
    
    let monthWeekItem: [String]
    
    let ekMonthWeekItem: [String: [Int]]
    
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
    
    func addDayWeek(dayWeek: Int) {
        if self.selectedDaysWeek == nil
            || !self.selectedDaysWeek!.map({ $0.dayOfTheWeek.rawValue }).contains(dayWeek) {
            selectedDaysWeek?.append(EKRecurrenceDayOfWeek(EKWeekday(rawValue: dayWeek)!))
        }
    }
    
    func removeDayWeek(dayWeek: Int) {
        guard let daysWeek = self.selectedDaysWeek else { return }
        if daysWeek.count > 1 {
            self.selectedDaysWeek = self.selectedDaysWeek?.filter { $0.dayOfTheWeek.rawValue != dayWeek }
        }
    }
    
    func addDayMonth(day: Int) {
        if self.selectedDaysMonth == nil
            || !self.selectedDaysMonth!.map({ $0.intValue }).contains(day) {
            selectedDaysMonth?.append(NSNumber(value: day))
        }
    }
    
    func removeDayMonth(day: Int) {
        guard let daysMonth = self.selectedDaysMonth else { return }
        if daysMonth.count > 1 {
            self.selectedDaysMonth = self.selectedDaysMonth?.filter { $0.intValue != day }
        }
    }
    
    func addMonthYear(month: Int) {
        if self.selectedMonthsYear == nil
            || !self.selectedMonthsYear!.map({ $0.intValue }).contains(month) {
            selectedMonthsYear?.append(NSNumber(value: month))
        }
    }
    
    func removeMonthYear(month: Int) {
        guard let daysMonth = self.selectedMonthsYear else { return }
        if daysMonth.count > 1 {
            self.selectedMonthsYear = self.selectedMonthsYear?.filter { $0.intValue != month }
        }
    }
    
    
    
    func reset(frequency: EKRecurrenceFrequency?, element: dateElements? = nil) {
        let calendar = Calendar.current
        switch frequency {
        case .weekly:
            let weekDay = calendar.component(.weekday, from: date)
            self.selectedDaysWeek = [EKRecurrenceDayOfWeek(EKWeekday(rawValue: weekDay)!)]
        case .monthly:
            /*
             if element == .week {
             self.selectedDaysWeek = [EKRecurrenceDayOfWeek(EKWeekday.sunday)]
             self.setPositions = [NSNumber(value: 1)]
             return
             }
             let day = calendar.component(.day, from: date)
             self.selectedDaysMonth = [NSNumber(value: day)]
             */
            self.selectedDaysWeek = [EKRecurrenceDayOfWeek(EKWeekday.sunday)]
            self.setPositions = [NSNumber(value: 1)]
            
            let day = calendar.component(.day, from: date)
            self.selectedDaysMonth = [NSNumber(value: day)]
            
        case .yearly:
            self.selectedDaysWeek = [EKRecurrenceDayOfWeek(EKWeekday.sunday)]
            self.setPositions = [NSNumber(value: 1)]
            
            let month = calendar.component(.month, from: date)
            self.selectedMonthsYear = [NSNumber(value: month)]
        default:
            self.selectedDaysWeek = nil
            self.selectedDaysMonth = nil
            self.selectedDaysYear = nil
            self.selectedWeeksYear = nil
            self.selectedMonthsYear = nil
            self.setPositions = nil
            return
        }
    }
    
    func allPrint() {
        print(self.interval)
        print(self.selectedDaysWeek)
        print(self.selectedDaysMonth)
        print(self.selectedDaysYear)
        print(self.selectedWeeksYear)
        print(self.selectedMonthsYear)
        print(self.setPositions)
    }
}

#Preview {
    RecurrencePicker()
}
