//
//  EditEventView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/11/03.
//

import SwiftUI
import EventKitUI

struct EditEventView: View {
    @EnvironmentObject var eventData: EventData
    @State private var isShownTabCalendar: Bool = false
    @State var tabCalendarX: CGFloat = 0
    @State var tabCalendarY: CGFloat = 0
    var startDayDateObj: DateObject = DateObject()
    var endDayDateObj: DateObject = DateObject()
    @State var location: String = ""
    @State var url: String = ""
    @State var memo: String = ""
    
    var body: some View {
        let verticalPadding: CGFloat = 10
        GeometryReader { geometry in
            let width = geometry.size.width
            let HEIGHT_TITLE: CGFloat = 45
            let Y_CALENDAR: CGFloat = HEIGHT_TITLE + 1
            let HEIGHT_CALENDAR: CGFloat = 40
            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        // タイトル
                        TextField("タイトル", text: $eventData.ekEvent.title)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 25,weight: .bold))
                            .padding(EdgeInsets(top: verticalPadding, leading: 0, bottom: verticalPadding, trailing: 0))
                            .frame(height: HEIGHT_TITLE)
                        HorizontalLine()
                            .frame(height: 1)
                        Text("")
                            .frame(height: HEIGHT_CALENDAR)
                        HorizontalLine()
                            .frame(height: 1)
                        // 日付選択
                        HStack {
                            Toggle("終日", isOn: $eventData.ekEvent.isAllDay)
                                .frame(width: 100, alignment: .trailing)
                                .padding(15)
                        }
                        .frame(width: width, alignment: .trailing)
                        DateTimeSelect(startOrEnd: 0, date: $eventData.ekEvent.startDate, width: width)
                            .environmentObject(startDayDateObj)
                        DateTimeSelect(startOrEnd: 1, date: $eventData.ekEvent.endDate, width: width)
                            .environmentObject(endDayDateObj)
                        
                        HorizontalLine()
                            .frame(height: 1)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                        
                        // 繰り返しの選択
                        RecurrencePicker(ekEvent: $eventData.ekEvent)
                            .frame(height: 25)
                        
                        HorizontalLine()
                            .frame(height: 1)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                        
                        // Alarm
                        AlarmPicker()
                            .padding(EdgeInsets(top: verticalPadding, leading: 40, bottom: verticalPadding, trailing: 40))
                        
                        
                        HorizontalLine()
                            .frame(height: 1)
                        
                        TextField("場所", text: $location)
                            .onChange(of: location) { _ in
                                if location.count > 0 {
                                    eventData.ekEvent.location = location
                                } else {
                                    eventData.ekEvent.location = nil
                                }
                            }
                            .padding(EdgeInsets(top: verticalPadding, leading: 40, bottom: verticalPadding, trailing: 40))
                        
                        HorizontalLine()
                            .frame(height: 1)
                        
                        TextField("URL", text: $url)
                            .onChange(of: url) { _ in
                                if url.count > 0 {
                                    eventData.ekEvent.url = URL(string: url)
                                } else {
                                    eventData.ekEvent.url = nil
                                }
                            }
                            .padding(EdgeInsets(top: verticalPadding, leading: 40, bottom: verticalPadding, trailing: 40))
                        
                        HorizontalLine()
                            .frame(height: 1)
                        
                        TextField("メモ", text: $memo)
                            .onChange(of: memo) { _ in
                                if memo.count > 0 {
                                    eventData.ekEvent.notes = memo
                                } else {
                                    eventData.ekEvent.notes = nil
                                }
                            }
                            .padding(EdgeInsets(top: verticalPadding, leading: 40, bottom: verticalPadding, trailing: 40))
                    }
                    
                    // カレンダー
                    if eventData.defaultCalendar != nil {
                        TabCalendar(calendars: eventData.eventController.getCalendars(), currentCalendar: $eventData.defaultCalendar, width: width, HEIGHT_TITLE: HEIGHT_CALENDAR,  $isShownTabCalendar)
                            .padding(EdgeInsets(top: Y_CALENDAR, leading: 0, bottom: 0, trailing: 0))
                    } else {
                        Text("カレンダーはありません")
                            .frame(width: width, height: HEIGHT_CALENDAR)
                            .padding(EdgeInsets(top: Y_CALENDAR, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                .font(.system(size: 14))
            }
            .onTapGesture(count: 1) {
                if(isShownTabCalendar){
                    isShownTabCalendar.toggle()
                }
                
            }
            
        }
    }
}

struct TabCalendar: View {
    @EnvironmentObject var eventData: EventData
    var calendarsBySource: [EKSourceType: [EKCalendar]] {
        calendarBySource(calendars: calendars)
    }
    let calendars: [EKCalendar]
    @Binding var currentCalendar: EKCalendar?
    let width: CGFloat
    let HEIGHT_TITLE: CGFloat
    let HEIGHT_CIRCLE: CGFloat = 13
    @Binding var isShown: Bool
    
    init(calendars: [EKCalendar], currentCalendar: Binding<EKCalendar?>, width: CGFloat, HEIGHT_TITLE: CGFloat, _ isShown: Binding<Bool>) {
        self.calendars = calendars
        self._currentCalendar = currentCalendar
        self.width = width - 20
        self.HEIGHT_TITLE = HEIGHT_TITLE
        self._isShown = isShown
    }
    
    var body: some View {
        let keys: Array<EKSourceType> = Array(calendarsBySource.keys).sorted(by: { $0.rawValue < $1.rawValue })
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .frame(height: HEIGHT_CIRCLE)
                    .foregroundColor(Color(currentCalendar!.cgColor))
                    .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0))
                
                Button {
                    withAnimation(.easeOut){
                        isShown.toggle()
                    }
                } label: {
                    Text(currentCalendar!.title)
                        .foregroundColor(.black)
                        .font(.system(size: 13))
                        .frame(width: abs(width), height: HEIGHT_TITLE)
                        .padding(EdgeInsets(top: 0, leading: -40 - HEIGHT_CIRCLE, bottom: 0, trailing: 0))
                }
            }
            if isShown {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(keys, id: \.self) { key in
                        Text(calendarsBySource[key]![0].source.title)
                            .font(.system(size: 10))
                        HStack(spacing: 2) {
                            ForEach(calendarsBySource[key]!, id: \.self) { calendar in
                                Button {
                                    eventData.ekEvent.calendar = calendar
                                    currentCalendar = calendar
                                    withAnimation(.easeOut){
                                        isShown.toggle()
                                    }
                                } label: {
                                    CalendarSeal(calendar: calendar, isCurrent: calendar == currentCalendar)
                                }
                            }
                        }
                        .padding(10)
                    }
                }
                .padding(10)
                .frame(width: width, alignment: .leading)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 0.5))
                .cornerRadius(10)
                .padding(EdgeInsets(top: -3, leading: 0, bottom: 0, trailing: -10))
            }
        }
    }
    
    func calendarBySource(calendars: [EKCalendar]) -> [EKSourceType : [EKCalendar]] {
        var calendarArray: [EKSourceType : [EKCalendar]] = [:]
        for calendar in calendars {
            let calendarType = calendar.source.sourceType
            
            if calendarArray.index(forKey: calendarType) == nil {
                calendarArray.updateValue([calendar], forKey: calendarType)
            } else {
                calendarArray[calendarType]!.append(calendar)
            }
        }
        
        return calendarArray
    }
}

struct CalendarSeal: View {
    var calendar: EKCalendar
    var isCurrent: Bool
    let padding: CGFloat = 7
    var color: CGColor {
        calendar.cgColor.copy(alpha: 0.3)!
    }
    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .frame(height: 10)
                .foregroundColor(Color(calendar.cgColor))
                .padding(padding)
            Text(calendar.title)
                .foregroundColor(.black)
                .font(.system(size: 10))
                .padding(padding)
        }
        .background(isCurrent ? Color(color) : nil)
        .cornerRadius(5)
    }
}

struct DateTimeSelect: View {
    @EnvironmentObject var eventData: EventData
    @EnvironmentObject var dayDateObj: DateObject
    @Binding var date: Date
    @State var hour: Int?
    @State var minute: Int?
    let visibleDate: visibleDateTime
    let visibleTime: visibleDateTime
    let dateFormatterDate: DateFormatter
    let dateFormatterTime: DateFormatter
    let width: CGFloat
    let radius: CGFloat = 5
    let linewidth: CGFloat = 2
    
    init (startOrEnd: Int, date: Binding<Date>, width: CGFloat) {
        if startOrEnd == 0 {
            visibleDate = .startDate
            visibleTime = .startTime
        } else {
            visibleDate = .endDate
            visibleTime = .endTime
        }
        
        self._date = date
        
        self.dateFormatterDate = DateFormatter()
        dateFormatterDate.calendar = Calendar(identifier: .gregorian)
        dateFormatterDate.locale = Locale(identifier: "ja_JP")
        dateFormatterDate.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        dateFormatterDate.dateFormat = "yyyy年M月d日(EEEEE)"
        self.dateFormatterTime = DateFormatter()
        dateFormatterTime.calendar = Calendar(identifier: .gregorian)
        dateFormatterTime.locale = Locale(identifier: "ja_JP")
        dateFormatterTime.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        dateFormatterTime.dateFormat = "H:mm"
        self.width = width
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 日付
            Button {
                withAnimation(.easeOut) {
                    dayDateObj.initializObj(date: date)
                    if eventData.visibleSwitch == visibleDate {
                        eventData.visibleSwitch = .invisible
                    } else {
                        eventData.visibleSwitch = visibleDate
                    }
                }
            } label: {
                Text(dateFormatterDate.string(from: date))
                //.font(.system(size: CGFloat(((width / 2) + 15) * 0.8) / 11))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                //.frame(width: ((width / 2) + 15) * 0.8)
                
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: radius)
                .stroke( eventData.visibleSwitch == visibleDate ? .black : .white, lineWidth: linewidth))
            .cornerRadius(radius)
            .frame(width: (width / 2) + 15)
            
            // 時間
            Button {
                withAnimation(.easeOut) {
                    if eventData.visibleSwitch == visibleTime {
                        eventData.visibleSwitch = .invisible
                    } else {
                        eventData.visibleSwitch = visibleTime
                    }
                }
            } label: {
                Text(dateFormatterTime.string(from: date))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(width: abs((width / 2) - 15) * 0.3)
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: radius)
                .stroke( eventData.visibleSwitch == visibleTime ? .black : .white, lineWidth: linewidth))
            .cornerRadius(radius)
            .frame(width: abs((width / 2) - 15))
        }
        .background(.white)
        
        if eventData.visibleSwitch == visibleDate {
            if #available(iOS 17.0, *) {
                selectYear(date: $date)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                selectMonth(date: $date)
                
                selectDateTab(date: $date, width: width)
            } else {
                DatePicker("日付選択", selection: $date)
            }
        } else if eventData.visibleSwitch == visibleTime {
            if #available(iOS 17.0, *) {
                selectHour(date: $date)
                selectMinute(date: $date)
            } else {
                HStack {
                    Picker("時間選択", selection: $hour) {
                        ForEach(1...24, id: \.self) { h in
                            Text("\(h)")
                        }
                    }
                    .onChange(of: hour) { _ in
                        let calendar = dayDateObj.calendar
                        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
                        components.hour = hour
                        date = calendar.date(from: components)!
                        EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
                    }
                    Picker("時間選択", selection: $minute) {
                        ForEach(1...60, id: \.self) { h in
                            Text("\(h)")
                        }
                    }
                    .onChange(of: minute) { _ in
                        let calendar = dayDateObj.calendar
                        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
                        components.minute = minute
                        date = calendar.date(from: components)!
                        EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
                    }
                }
                .onAppear() {
                    self.hour = dayDateObj.getHour(date)
                    self.minute = dayDateObj.getMinute(date)
                }
            }
        }
    }
}

struct selectYear: View {
    @EnvironmentObject var eventData: EventData
    @EnvironmentObject var dayDateObj: DateObject
    @Binding var date: Date
    
    var body: some View {
        let initialPosition = dayDateObj.calendar.component(.year, from: date)
        HorizontalWheelPicker_cigma(initialCenterItem: initialPosition, selection: $dayDateObj.yearView, numItem: 5, items: Array(1500...3000)) { index in
            Text(index.description)
        } onChangeEvent: { item in
            let calendar = dayDateObj.calendar
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
            components.year = item
            date = calendar.date(from: components)!
            dayDateObj.initializObj(date: date)
            EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
        }
        .frame(height: 40)
    }
}

struct selectMonth: View {
    @EnvironmentObject var eventData: EventData
    @EnvironmentObject var dayDateObj: DateObject
    @Binding var date: Date
    @State private var index: Int
    init(date: Binding<Date>) {
        self._date = date
        self._index = State(initialValue: Calendar.current.component(.month, from: date.wrappedValue))
    }
    var body: some View {
        HorizontalWheelPicker_cigma(initialCenterItem: dayDateObj.calendar.component(.month, from: date), selection: $dayDateObj.monthView, numItem: 5, items: Array(1...12)) { index in
            Text(index.description)
        } onChangeEvent: { item in
            let calendar = dayDateObj.calendar
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
            components.month = item
            date = calendar.date(from: components)!
            dayDateObj.initializObj(date: date)
            EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
        }
        .frame(height: 40)
    }
}
/*
struct selectDate_beta: View {
    @EnvironmentObject var eventData: EventData
    @EnvironmentObject var dateObj: DateObject
    @Binding var date: Date
    // let viewDate: Date
    let diffMonth: Int
    let width: CGFloat
    
    init(date: Binding<Date>, diffMonth: Int, width: CGFloat) {
        self._date = date
        self.diffMonth = diffMonth
        self.width = width
    }
    
    var body: some View {
        let calendar = dateObj.calendar
        let viewDate = calendar.date(from: DateComponents(
            year: dateObj.getYear(dateObj.viewDate),
            month: dateObj.getMonth(dateObj.viewDate) + diffMonth,
            day: dateObj.getDay(dateObj.viewDate)))!
        let itemWidth = width / 7
        let rowMonth = 6
        let infoMonth = getInfoMonth(date: viewDate)
        
        VStack {
            // 週
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(infoMonth.getWeek()[index])
                        .frame(width: itemWidth, height: 10)
                        .font(.system(size: 10))
                }
            }
            
            ForEach(0..<rowMonth, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { columnIndex in
                        VStack(spacing: 0) {
                            let calendar = dateObj.calendar
                            let year = calendar.component(.year, from: viewDate)
                            let month = calendar.component(.month, from: viewDate)
                            let day = infoMonth.getDate(rowIndex, columnIndex, infoMonth.noWeekFirstDate)
                            let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: day)
                            let itemDate = calendar.date(from: dateComp)!
                            
                            if infoMonth.rangeMonth ~= day {
                                Button {
                                    let calendar = dateObj.calendar
                                    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
                                    components.day = day
                                    date = calendar.date(from: components)!
                                    EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
                                } label: {
                                    //日付
                                    Text(day.description)
                                        .foregroundColor(compareDate(itemDate, currentDate: date) ? .white : .black)
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .underline(color: compareDate(itemDate) ? (compareDate(itemDate, currentDate: date)  ? .white : .black) : .clear)
                                        .font(.system(size: 13))
                                        .background(compareDate(itemDate, currentDate: date) ? .black : .clear)
                                        .cornerRadius(15)
                                        .frame(width: itemWidth)
                                }
                            } else {
                                Text("")
                                    .frame(width: itemWidth, height: 30)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func compareDate(_ date: Date, currentDate: Date = Date()) -> Bool {
        let calendar = dateObj.calendar
        guard calendar.component(.year, from: date) == calendar.component(.year, from: currentDate) else {
            return false
        }
        guard calendar.component(.month, from: date) == calendar.component(.month, from: currentDate) else {
            return false
        }
        guard calendar.component(.day, from: date) == calendar.component(.day, from: currentDate) else {
            return false
        }
        return true
    }
}
*/
struct selectDate_beta: View {
    @EnvironmentObject var eventData: EventData
    @EnvironmentObject var dateObj: DateObject
    @Binding var date: Date
    // let viewDate: Date
    let diffMonth: Int
    let width: CGFloat
    
    init(date: Binding<Date>, diffMonth: Int, width: CGFloat) {
        self._date = date
        self.diffMonth = diffMonth
        self.width = width
    }
    
    var body: some View {
        let calendar = dateObj.calendar
        let viewDate = calendar.date(from: DateComponents(
            year: dateObj.getYear(dateObj.viewDate),
            month: dateObj.getMonth(dateObj.viewDate) + diffMonth,
            day: dateObj.getDay(dateObj.viewDate)))!
        let itemWidth = width / 7
        let rowMonth = 6
        let infoMonth = getInfoMonth(date: viewDate)
        
        VStack {
            // 週
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(infoMonth.getWeek()[index])
                        .frame(width: itemWidth, height: 10)
                        .font(.system(size: 10))
                }
            }
            
            ForEach(0..<rowMonth, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { columnIndex in
                        VStack(spacing: 0) {
                            let calendar = dateObj.calendar
                            let year = calendar.component(.year, from: viewDate)
                            let month = calendar.component(.month, from: viewDate)
                            let day = infoMonth.getDate(rowIndex, columnIndex, infoMonth.noWeekFirstDate)
                            let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: day)
                            let itemDate = calendar.date(from: dateComp)!
                            
                            if infoMonth.rangeMonth ~= day {
                                Button {
                                    let calendar = dateObj.calendar
                                    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
                                    components.day = day
                                    date = calendar.date(from: components)!
                                    EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
                                } label: {
                                    //日付
                                    Text(day.description)
                                        .foregroundColor(compareDate(itemDate, currentDate: date) ? .white : .black)
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .underline(color: compareDate(itemDate) ? (compareDate(itemDate, currentDate: date)  ? .white : .black) : .clear)
                                        .font(.system(size: 13))
                                        .background(compareDate(itemDate, currentDate: date) ? .black : .clear)
                                        .cornerRadius(15)
                                        .frame(width: itemWidth)
                                }
                            } else {
                                Text("")
                                    .frame(width: itemWidth, height: 30)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func compareDate(_ date: Date, currentDate: Date = Date()) -> Bool {
        let calendar = dateObj.calendar
        guard calendar.component(.year, from: date) == calendar.component(.year, from: currentDate) else {
            return false
        }
        guard calendar.component(.month, from: date) == calendar.component(.month, from: currentDate) else {
            return false
        }
        guard calendar.component(.day, from: date) == calendar.component(.day, from: currentDate) else {
            return false
        }
        return true
    }
}

struct selectDateTab: View {
    @EnvironmentObject var eventData: EventData
    @EnvironmentObject var dateObj: DateObject
    @Binding var date: Date
    let width: CGFloat
    //let calendar: Calendar = Calendar.current
    var body: some View {
        if #available(iOS 17.0, *) {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    LazyHStack(spacing: 0) {
                        ForEach(dateObj.rangeMonth, id: \.self) { addMonth in
                            selectDate_beta(date: $date, diffMonth: addMonth, width: width)
                                .frame(width: width)
                        }
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $dateObj.selection)
            .onChange(of: dateObj.selection) { _ in
                dateObj.updateDateObj()
                
                let calendar = dateObj.calendar
                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
                components.year = dateObj.yearView
                components.month = dateObj.monthView
                date = calendar.date(from: components)!
                EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
                
            }
        }
    }
}

struct selectHour: View {
    @EnvironmentObject var eventData: EventData
    @Binding var date: Date
    @State private var index: Int
    init(date: Binding<Date>) {
        self._date = date
        self._index = State(initialValue: Calendar.current.component(.month, from: date.wrappedValue))
    }
    var body: some View {
        HorizontalWheelPicker_cigma(initialCenterItem: Calendar.current.component(.hour, from: date), numItem: 7, items: Array(0...23)) { index in
            Text(index.description)
        } onChangeEvent: { item in
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
            components.hour = item
            date = calendar.date(from: components)!
            EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
        }
        .frame(height: 40)
    }
}

struct selectMinute: View {
    @EnvironmentObject var eventData: EventData
    @Binding var date: Date
    @State private var index: Int
    let diff: Int = 5
    init(date: Binding<Date>) {
        self._date = date
        let min = DateObject().calendar.component(.minute, from: date.wrappedValue)
        self._index = State(initialValue: min)
    }
    var body: some View {
        HorizontalWheelPicker_cigma(initialCenterItem: index, numItem: 9, items: createMinuteArray(diff: diff)) { index in
            Text(index.description)
                .font(.system(size: 15))
        } onChangeEvent: { item in
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
            components.minute = item
            date = calendar.date(from: components)!
            EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
        }
        .frame(height: 40)
    }
    
    func createMinuteArray(diff: Int) -> [Int] {
        var array: [Int] = []
        
        for minute in 0...59 {
            if minute % diff == 0 {
                array.insert(minute, at: array.count)
            }
        }
        
        return array
    }
}

struct HorizontalItemPrefurenceKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGPoint>] = [:]
    
    static func reduce(value: inout [Int : Anchor<CGPoint>], nextValue: () -> [Int : Anchor<CGPoint>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct HorizontalWheelPicker<Content: View, Item: Comparable>: View {
    var position: Int
    var items: Binding<[Item]>
    let contentBuilder: (Item) -> Content
    @State private var scrollID: Int?
    let onChangeEvent: (Item) -> Void
    let numItem: Int
    
    init (initialCenterItem item: Item, numItem: Int = 5, items: Binding<[Item]>, content: @escaping (Item) -> Content, onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.wrappedValue.firstIndex(of: item)!
        self.numItem = numItem
        self.items = items
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    init (initialCenterItem item: Item, numItem: Int = 5, items: [Item], content: @escaping (Item) -> Content, onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.firstIndex(of: item)!
        self.numItem = numItem
        self.items = .constant(items)
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    // let height = geometry.size.height
                    let itemWidth = width / CGFloat(numItem)
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            LazyHStack(spacing: 0) {
                                ForEach(-numItem / 2..<items.wrappedValue.count + (numItem / 2), id: \.self) { index in
                                    if 0..<items.wrappedValue.count ~= index {
                                        contentBuilder(items.wrappedValue[index])
                                            .foregroundColor( (scrollID ?? position - numItem / 2) + numItem / 2  == index ? .black : .gray)
                                            .fontWeight((scrollID ?? position - numItem / 2) + numItem / 2  == index ? .bold : .regular)
                                            .id(index)
                                            .frame(width: itemWidth)
                                    } else {
                                        Text("")
                                            .frame(width: itemWidth)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                            .onAppear {
                                proxy.scrollTo(position + (numItem / 2))
                            }
                        }
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrollID)
                    .onChange(of: scrollID) {
                        if 0..<items.wrappedValue.count ~= scrollID! + (numItem / 2) {
                            onChangeEvent(items.wrappedValue[scrollID! + numItem / 2])
                        }
                    }
                }
            }
        }
    }
}

struct HorizontalWheelPicker_beta<Content: View, Item: Comparable>: View {
    var position: Int
    @Binding var positioningItem: Item
    var items: Binding<[Item]>
    let contentBuilder: (Item) -> Content
    @State private var scrollID: Int?
    @State private var oldScrollID: Int?
    let onChangeEvent: (Item) -> Void
    let numItem: Int
    
    init (initialCenterItem item: Item,
          selection: Binding<Item> = Binding.constant(0),
          numItem: Int = 5, items: Binding<[Item]>,
          content: @escaping (Item) -> Content,
          onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.wrappedValue.firstIndex(of: item)!
        self._positioningItem = selection
        self.numItem = numItem
        self.items = items
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    init (initialCenterItem item: Item,
          selection: Binding<Item> = Binding.constant(0),
          numItem: Int = 5, items: [Item],
          content: @escaping (Item) -> Content,
          onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.firstIndex(of: item)!
        self._positioningItem = selection
        self.numItem = numItem
        self.items = .constant(items)
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    // let height = geometry.size.height
                    let itemWidth = floor(width / CGFloat(numItem))
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            LazyHStack(spacing: 0) {
                                ForEach(-numItem / 2..<items.wrappedValue.count + (numItem / 2), id: \.self) { index in
                                    if 0..<items.wrappedValue.count ~= index {
                                        contentBuilder(items.wrappedValue[index])
                                            .foregroundColor( (scrollID ?? position - numItem / 2) + numItem / 2  == index ? .black : .gray)
                                            .fontWeight((scrollID ?? position - numItem / 2) + numItem / 2  == index ? .bold : .regular)
                                            .id(index)
                                            .frame(width: itemWidth)
                                    } else {
                                        Text("")
                                            .frame(width: itemWidth)
                                            .id(index)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                            .onAppear {
                                proxy.scrollTo(position, anchor: .center)
                            }
                            .onChange(of: positioningItem) { index in
                                if  scrollID == oldScrollID {
                                    withAnimation {
                                        let id = items.wrappedValue.firstIndex(of: positioningItem)!
                                        print("scroll to : \(id)")
                                        proxy.scrollTo(id, anchor: .center)
                                    }
                                }
                                
                                oldScrollID = scrollID
                            }
                        }
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrollID)
                    .onChange(of: scrollID) { _ in
                        if 0..<items.wrappedValue.count ~= scrollID! + (numItem / 2) {
                            onChangeEvent(items.wrappedValue[scrollID! + numItem / 2])
                        }
                    }
                }
            }
        }
    }
}

struct HorizontalWheelPicker_cigma<Content: View, Item: Comparable>: View {
    var position: Int
    @Binding var positioningItem: Item
    var items: Binding<[Item]>
    let contentBuilder: (Item) -> Content
    @State private var scrollID: Int?
    @State private var oldScrollID: Int?
    @State private var itemPoints: [Int: CGPoint]?
    let onChangeEvent: (Item) -> Void
    let numItem: Int
    
    init (initialCenterItem item: Item,
          selection: Binding<Item>? = nil,
          numItem: Int = 5, items: Binding<[Item]>,
          content: @escaping (Item) -> Content,
          onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.wrappedValue.firstIndex(of: item)!
        self._positioningItem = selection ?? Binding.constant(item)
        self.numItem = numItem
        self.items = items
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    init (initialCenterItem item: Item,
          selection: Binding<Item>? = nil,
          numItem: Int = 5, items: [Item],
          content: @escaping (Item) -> Content,
          onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.firstIndex(of: item)!
        self._positioningItem = selection ?? Binding.constant(item)
        self.numItem = numItem
        self.items = .constant(items)
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    // let height = geometry.size.height
                    let itemWidth = floor(width / CGFloat(numItem))
                    var centerItem: Int {
                        guard itemPoints != nil else { return 0 }
                        for point in itemPoints!.sorted(by: { $0.key < $1.key }) {
                            if point.value.x >= width / 2 - itemWidth {
                                return point.key
                            }
                        }
                        return itemPoints!.max(by: { $0.key < $1.key })?.key ?? 0
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            LazyHStack(spacing: 0) {
                                ForEach(0..<items.wrappedValue.count, id: \.self) { index in
                                    if 0..<items.wrappedValue.count ~= index {
                                        contentBuilder(items.wrappedValue[index])
                                            .foregroundColor(centerItem  == index ? .black : .gray)
                                            .fontWeight(centerItem  == index ? .bold : .regular)
                                            .id(index)
                                            .frame(width: itemWidth)
                                            .anchorPreference(key: HorizontalItemPrefurenceKey.self, value: .topLeading) {
                                                return [index: $0]
                                            }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                            .safeAreaPadding(.horizontal, itemWidth * CGFloat(numItem / 2))
                            .onAppear {
                                proxy.scrollTo(position, anchor: .center)
                            }
                            .onPreferenceChange(HorizontalItemPrefurenceKey.self) { prefs in
                                // 非同期で実行しないとcenteItemの参照に間に合わない
                                Task {
                                    itemPoints = prefs.mapValues {  geometry[$0] }
                                }
                            }
                            .onChange(of: positioningItem) { index in
                                // 自らscrollIDを更新した場合は処理を飛ばす
                                if  scrollID == oldScrollID {
                                    withAnimation {
                                        let id = items.wrappedValue.firstIndex(of: positioningItem)!
                                        proxy.scrollTo(id, anchor: .center)
                                    }
                                }
                                
                                oldScrollID = scrollID
                            }
                        }
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrollID, anchor: .center)
                    .onChange(of: scrollID) { _ in
                        if 0..<items.wrappedValue.count ~= scrollID! {
                            onChangeEvent(items.wrappedValue[scrollID!])
                        }
                    }
                }
            }
        }
    }
}

struct VerticalWheelPicker<Content: View, Item: Comparable>: View {
    var position: Int
    @Binding var positioningItem: Item
    var items: Binding<[Item]>
    let contentBuilder: (Item) -> Content
    @State private var scrollID: Int?
    @State private var oldScrollID: Int?
    @State private var itemPoints: [Int: CGPoint]?
    let onChangeEvent: (Item) -> Void
    let numItem: Int
    
    init (initialCenterItem item: Item,
          selection: Binding<Item>? = nil,
          numItem: Int = 5, items: Binding<[Item]>,
          content: @escaping (Item) -> Content,
          onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.wrappedValue.firstIndex(of: item)!
        self._positioningItem = selection ?? Binding.constant(item)
        self.numItem = numItem
        self.items = items
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    init (initialCenterItem item: Item,
          selection: Binding<Item>? = nil,
          numItem: Int = 5, items: [Item],
          content: @escaping (Item) -> Content,
          onChangeEvent: @escaping (Item) -> Void) {
        self.position = items.firstIndex(of: item)!
        self._positioningItem = selection ?? Binding.constant(item)
        self.numItem = numItem
        self.items = .constant(items)
        self.contentBuilder = content
        self.onChangeEvent = onChangeEvent
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                GeometryReader { geometry in
                    // let width = geometry.size.width
                    let height = geometry.size.height
                    let itemHeight = floor(height / CGFloat(numItem))
                    var centerItem: Int {
                        guard itemPoints != nil else { return 0 }
                        for point in itemPoints!.sorted(by: { $0.key < $1.key }) {
                            if point.value.y >= height / 2 - itemHeight {
                                return point.key
                            }
                        }
                        return itemPoints!.max(by: { $0.key < $1.key })?.key ?? 0
                    }
                    ScrollView(.vertical, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            LazyVStack(spacing: 0) {
                                ForEach(0..<items.wrappedValue.count, id: \.self) { index in
                                    if 0..<items.wrappedValue.count ~= index {
                                        contentBuilder(items.wrappedValue[index])
                                            .foregroundColor(centerItem  == index ? .black : .gray)
                                            .fontWeight(centerItem  == index ? .bold : .regular)
                                            .frame(height: itemHeight)
                                            .id(index)
                                            .anchorPreference(key: HorizontalItemPrefurenceKey.self, value: .topLeading) {
                                                return [index: $0]
                                            }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                            .safeAreaPadding(.vertical, itemHeight * CGFloat(numItem / 2))
                            .onAppear {
                                proxy.scrollTo(position, anchor: .center)
                            }
                            .onPreferenceChange(HorizontalItemPrefurenceKey.self) { prefs in
                                // 非同期で実行しないとcenteItemの参照に間に合わない
                                Task {
                                    itemPoints = prefs.mapValues {  geometry[$0] }
                                }
                            }
                            .onChange(of: positioningItem) { index in
                                // 自らscrollIDを更新した場合は処理を飛ばす
                                if  scrollID == oldScrollID {
                                    withAnimation {
                                        let id = items.wrappedValue.firstIndex(of: positioningItem)!
                                        proxy.scrollTo(id, anchor: .center)
                                    }
                                }
                                
                                oldScrollID = scrollID
                            }
                        }
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrollID, anchor: .center)
                    .onChange(of: scrollID) { _ in
                        if 0..<items.wrappedValue.count ~= scrollID! {
                            onChangeEvent(items.wrappedValue[scrollID!])
                        }
                    }
                }
            }
        }
    }
}

struct AlarmPicker: View {
    @EnvironmentObject var eventData: EventData
    @State private var selectedAlarm: Double?
    var body: some View {
        Menu {
            Picker("通知", selection: $selectedAlarm) {
                ForEach(alarms, id: \.self.key) { alarm in
                    Text(alarm.key).tag(alarm.value)
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text("通知")
                    .foregroundStyle(.black)
                Spacer()
                Text(alarms.first(where: {$0.value == selectedAlarm})?.key ?? "なし")
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
            }
        }
        .onChange(of: selectedAlarm) { _ in
            if let alarms = eventData.ekEvent.alarms {
                for alarm in alarms {
                    eventData.ekEvent.removeAlarm(alarm)
                }
            }
            if let offset = selectedAlarm {
                eventData.ekEvent.addAlarm(EKAlarm(relativeOffset: -offset))
            }
        }
    }
    
    let alarms: Array<(key: String, value: Double?)> = [
        (key: "なし", value: nil),
        (key: "5分前", value: 300),
        (key: "10分前", value: 600),
        (key: "20分前", value: 1200),
        (key: "40分前", value: 2400),
        (key: "1時間前", value: 3600),
        (key: "2時間前", value: 7200),
        (key: "1日前", value: 86400),
        (key: "2日前", value: 172800),
        (key: "半日前",value: 43200),
        (key: "1週間前", value: 604800),
    ]
}

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

struct EditEventView_Previews: PreviewProvider {
    static var previews: some View {
        EditEventView()
            .environmentObject(EventData())
    }
}
