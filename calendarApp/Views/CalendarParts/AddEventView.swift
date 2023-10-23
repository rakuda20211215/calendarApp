//
//  AddEventView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/13.
//

import SwiftUI
import EventKit

struct AddEventView: View {
    @EnvironmentObject var eventData: EventData
    // @ObservedObject var eventData: EventData = EventData(isDeleteAfterEndDate: false)
    @State private var isShownTabCalendar: Bool = false
    @State var tabCalendarX: CGFloat = 0
    @State var tabCalendarY: CGFloat = 0
    
    var body: some View {
        let verticalPadding: CGFloat = 10
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
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
                        DateTimeSelect(startOrEnd: 1, date: $eventData.ekEvent.endDate, width: width)
                        
                        HorizontalLine()
                            .frame(height: 1)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                    // カレンダー
                    if eventData.defaultCalendar == nil {
                        Text("カレンダーはありません")
                            .frame(width: width, height: HEIGHT_CALENDAR)
                            .padding(EdgeInsets(top: Y_CALENDAR, leading: 0, bottom: 0, trailing: 0))
                    } else {
                        TabCalendar(calendars: eventData.eventController.getCalendars(), currentCalendar: $eventData.defaultCalendar, width: width, HEIGHT_TITLE: HEIGHT_CALENDAR,  $isShownTabCalendar)
                            .padding(EdgeInsets(top: Y_CALENDAR, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
            .onTapGesture(count: 1) {
                if(isShownTabCalendar){
                    isShownTabCalendar.toggle()
                }
                
            }
        }
    }
}

struct DateTimeSelect: View {
    @EnvironmentObject var eventData: EventData
    @Binding var date: Date
    let visibleDate: visibleDateTime
    let visibleTime: visibleDateTime
    let dateFormatterDate: DateFormatter
    let dateFormatterTime: DateFormatter
    let width: CGFloat
    let radius: CGFloat = 5
    
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
                    if eventData.visibleSwitch == visibleDate {
                        eventData.visibleSwitch = .invisible
                    } else {
                        eventData.visibleSwitch = visibleDate
                    }
                }
            } label: {
                Text(dateFormatterDate.string(from: date))
                    .font(.system(size: CGFloat(((width / 2) + 15) * 0.8) / 11))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(width: ((width / 2) + 15) * 0.8)
                
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: radius)
                .stroke( eventData.visibleSwitch == visibleDate ? .black : .white, lineWidth: 1))
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
                    .frame(width: ((width / 2) - 15) * 0.3)
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: radius)
                .stroke( eventData.visibleSwitch == visibleTime ? .black : .white, lineWidth: 1))
            .cornerRadius(radius)
            .frame(width: (width / 2) - 15)
        }
        .background(.white)
        
        if eventData.visibleSwitch == visibleDate {
            selectYear(date: $date)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            selectMonth(date: $date)
            
            selectDate(date: $date,diffMonth: 0 , width: width)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                
            // selectDateTab(date: $date, width: width)
            
        } else if eventData.visibleSwitch == visibleTime {
            selectHour(date: $date)
            selectMinute(date: $date)
        }
    }
}

struct selectYear: View {
    @EnvironmentObject var eventData: EventData
    @Binding var date: Date
    @State private var index: Int
    init(date: Binding<Date>) {
        self._date = date
        self._index = State(initialValue: Calendar.current.component(.year, from: date.wrappedValue))
    }
    var body: some View {
        HorizontalWheelPicker(initialCenterItem: index, numItem: 5, items: Array(1500...3000)) { index in
            Text(index.description)
        } onChangeEvent: { item in
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
            components.year = item
            date = calendar.date(from: components)!
            EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
        }
        .frame(height: 40)
    }
}

struct selectMonth: View {
    @EnvironmentObject var eventData: EventData
    @Binding var date: Date
    @State private var index: Int
    init(date: Binding<Date>) {
        self._date = date
        self._index = State(initialValue: Calendar.current.component(.month, from: date.wrappedValue))
    }
    var body: some View {
        HorizontalWheelPicker(initialCenterItem: Calendar.current.component(.month, from: date), numItem: 5, items: Array(1...12)) { index in
            Text(index.description)
        } onChangeEvent: { item in
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
            components.month = item
            date = calendar.date(from: components)!
            EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
        }
        .frame(height: 40)
    }
}

struct selectDate: View {
    @EnvironmentObject var eventData: EventData
    @Binding var date: Date
    // let viewDate: Date
    let diffMonth: Int
    let width: CGFloat
    
    @ObservedObject private var dateObj: DateObject = DateObject()
    
    var body: some View {
        let viewDate = Calendar(identifier: .gregorian).date(from: DateComponents(
            year: dateObj.getYear(date),
            month: dateObj.getMonth(date) + diffMonth,
            day: dateObj.getDay(date)))!
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
                            let calendar = Calendar.current
                            let year = calendar.component(.year, from: date)
                            let month = calendar.component(.month, from: date)
                            let day = infoMonth.getDate(rowIndex, columnIndex, infoMonth.noWeekFirstDate)
                            let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: day)
                            let itemDate = calendar.date(from: dateComp)!
                            let selectedDay = Calendar.current.component(.day, from: viewDate)
                            if infoMonth.rangeMonth ~= day {
                                Button {
                                    let calendar = Calendar.current
                                    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
                                    components.day = day
                                    date = calendar.date(from: components)!
                                    EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
                                } label: {
                                    //日付
                                    Text(day.description)
                                        .foregroundColor(day == selectedDay ? .white : .black)
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .underline(color: compareDate(itemDate) ? (day == selectedDay ? .white : .black) : .clear)
                                        .font(.system(size: 15))
                                        .background(day == selectedDay ? .black : .clear)
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
        let calendar = Calendar.current
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
    @Binding var date: Date
    let width: CGFloat
    @ObservedObject private var dateObj: DateObject = DateObject()
    let calendar: Calendar = Calendar.current
    var body: some View {
        VStack {
            TabView(selection: $dateObj.selection) {
                ForEach(dateObj.rangeMonth, id: \.self) { addMonth in
                    selectDate(date: $date, diffMonth: addMonth, width: width)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: dateObj.selection) { _ in
                dateObj.updateDateObj()
                
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
                components.month = dateObj.monthView
                date = calendar.date(from: components)!
                EventData.compareStartEnd(ekEvent: eventData.ekEvent, date: date)
                
                print(dateObj.monthView.description)
            }
            .frame(height: width * 0.8)
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
        HorizontalWheelPicker(initialCenterItem: Calendar.current.component(.hour, from: date), numItem: 7, items: Array(0...23)) { index in
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
        self._index = State(initialValue: Int((round(Double(Calendar.current.component(.minute, from: date.wrappedValue))) / Double(5))) * 5)
    }
    var body: some View {
        HorizontalWheelPicker(initialCenterItem: index, numItem: 9, items: createMinuteArray(diff: diff)) { index in
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
                        print(scrollID! + (numItem / 2))
                        print(items.wrappedValue.count)
                        if 0..<items.wrappedValue.count ~= scrollID! + (numItem / 2) {
                            onChangeEvent(items.wrappedValue[scrollID! + numItem / 2])
                        }
                    }
                }
            }
        }
    }
}

struct TabCalendar: View {
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
                        .frame(width: width, height: HEIGHT_TITLE)
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
                                    withAnimation(.easeOut){
                                        isShown.toggle()
                                    }
                                    currentCalendar = calendar
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

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
            .environmentObject(EventData())
    }
}
