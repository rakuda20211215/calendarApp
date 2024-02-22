//
//  MonthCalendar.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/06.
//

import SwiftUI
import UIKit
import EventKit

struct MonthCalendar: View {
    @ObservedObject var eventData: EventData
    @ObservedObject private var dateObj: DateObject = DateObject()
    @Binding var selectedEventDate: Date?
    
    var startWeek: String
    let YEAR: Int
    let MONTH: Int
    let infoMonth: InfoMonth
    let week: [String]
    
    let maxCalendarHeight: CGFloat
    
    init(YEAR: Int, MONTH: Int, eventData: EventData, selectedEventDate: Binding<Date?>, contentHeight: CGFloat) {
        self.YEAR = YEAR
        self.MONTH = MONTH
        self.infoMonth = InfoMonth(year: YEAR, month: MONTH)
        self.week = infoMonth.getWeek()
        self.startWeek = self.week[0]
        self.eventData = eventData
        
        self.maxCalendarHeight = contentHeight
        
        self._selectedEventDate = selectedEventDate
    }
    
    let LINE_COLOR = Color.gray.opacity(0.5)
    
    var body: some View {
        let indexStartWeek = week.firstIndex(of: startWeek)!
        let customWeek: [String] = createCustomWeek(indexStartWeek)
        let CARRYOVER = infoMonth.noWeekFirstDate
        // イベント取得
        
        GeometryReader { geometry in
            let objectSizes: ObjectSizes = ObjectSizes(width: geometry.size.width, height: geometry.size.height, maxCalendarHeight: maxCalendarHeight, showEvents: eventData.showEvents)
            
            ZStack(alignment: .topLeading) {
                let ekEvents = eventData.eventController.getEvents(year: YEAR, month: MONTH)
                let ekEventsFloorMap = getEventsFloorMap(ekEvents: ekEvents)
                
                if !ekEvents.isEmpty {
                    ForEach(ekEvents, id: \.self) { ekEvent in
                        if let floor = ekEventsFloorMap[ekEvent],
                            floor < objectSizes.ROW_EVENTS {
                            EventSeal(ekEvent: ekEvent, floor: floor, showEvents: $eventData.showEvents,
                                      objectSizes: objectSizes,
                                      CARRYOVER: CARRYOVER)
                            .padding(EdgeInsets(top: objectSizes.HEIGHT_WEEKCHAR, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    // 週
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { index in
                            Text(customWeek[index])
                                .foregroundStyle(.black)
                                .frame(width: objectSizes.WIDTH_DATE,height: objectSizes.HEIGHT_WEEKCHAR)
                                .font(.system(size: 10))
                        }
                    }
                    
                    //　日付と仕切り線
                    ForEach(0..<objectSizes.NUMROWMONTH, id: \.self) { rowIndex in
                        
                        //仕切りの線
                        Rectangle()
                            .fill(LINE_COLOR)
                            .frame(width: objectSizes.WIDTH, height: 1)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<objectSizes.NUMWEEK, id: \.self) { columnIndex in
                                VStack(spacing: 0) {
                                    let day: Int = infoMonth.getDay(rowIndex, columnIndex, CARRYOVER)
                                    let dateComp: DateComponents = DateComponents(year: YEAR, month: MONTH, day: day)
                                    let thisDate: Date = Calendar.current.date(from: dateComp)!
                                    if infoMonth.rangeMonth ~= day {
                                        Button {
                                            if !eventData.eventController.getEvents(date: thisDate).isEmpty {
                                                selectedEventDate = thisDate
                                                eventData.showEvents = true
                                            }
                                        } label: {
                                            //日付
                                            VStack {
                                                Text(infoMonth.getDay(rowIndex, columnIndex, CARRYOVER).description)
                                                    .foregroundStyle(.black)
                                                    .frame(width: objectSizes.WIDTH_DATE, height: objectSizes.HEIGHT_DATE, alignment: .center)
                                                    .font(.system(size: 10))
                                                    .frame(width: objectSizes.WIDTH_DATE)
                                            }
                                            .frame(height: objectSizes.HEIGHT_ROW_MONTH, alignment: .top)
                                        }
                                        
                                    } else {
                                        Text("")
                                            .frame(width: objectSizes.WIDTH_DATE, height: objectSizes.HEIGHT_DATE)
                                    }
                                }
                            }
                        }
                        .frame(height: objectSizes.HEIGHT_ROW_MONTH, alignment: .top)
                    }
                }
            }
            .background(.white)
            .cornerRadius(5)
        }
    }
    
    func createCustomWeek(_ indexStartWeek: Int) -> [String] {
        var w = [String]()
        
        for i in 0..<7 {
            w.append(week[(i + indexStartWeek) % 7])
        }
        
        return w
    }
    
    func getEventsFloorMap(ekEvents: [EKEvent]) -> [EKEvent: Int] {
        var eventsFloorMap = [EKEvent: Int]()
        for ekEvent in ekEvents {
            let targetStartDay = dateObj.getDay(ekEvent.startDate)
            let targetEventFloors = eventsFloorMap.filter { e, f in
                let loopEndday = dateObj.getDay(e.endDate)
                if targetStartDay <= loopEndday {
                    return true
                }
                return false
            }.map { _, f in
                return f
            }.sorted {
                $0 < $1
            }
            
            var floor = 0
            for (i, f) in zip(targetEventFloors.indices, targetEventFloors) {
                if i != f {
                    floor = i
                    break
                }
                floor = i + 1
            }
            eventsFloorMap[ekEvent] = floor
        }
        return eventsFloorMap
    }
    
    class ObjectSizes: ObjectSizesCollection {
        let WIDTH: CGFloat
        let HEIGHT: CGFloat
        let HEIGHT_WEEKCHAR: CGFloat
        let WIDTH_DATE: CGFloat
        let HEIGHT_DATE: CGFloat
        let HEIGHT_ROW_MONTH: CGFloat
        let WIDTH_EVENT: CGFloat
        var HEIGHT_EVENT: CGFloat
        let HEIGHT_EVENT_AREA: CGFloat
        let HEIGHT_EVENT_RECTANGLE: CGFloat
        let WIDTH_EVENT_TITLE: CGFloat
        let ROW_EVENTS: Int
        
        let NUMWEEK = 7
        let NUMROWMONTH = 6
        init(width: CGFloat, height: CGFloat, maxCalendarHeight: CGFloat, showEvents: Bool) {
            WIDTH = width
            HEIGHT = height
            HEIGHT_WEEKCHAR = 20
            WIDTH_DATE = WIDTH /  CGFloat(NUMWEEK)
            HEIGHT_DATE = 12
            HEIGHT_ROW_MONTH = (HEIGHT - HEIGHT_WEEKCHAR - CGFloat(NUMROWMONTH)) / CGFloat(NUMROWMONTH)
            let maxHeightRowMonth = floor((maxCalendarHeight - HEIGHT_WEEKCHAR - CGFloat(NUMROWMONTH)) / CGFloat(NUMROWMONTH))
            WIDTH_EVENT = WIDTH_DATE - 2
            ROW_EVENTS = Int(maxHeightRowMonth / 19)
            HEIGHT_EVENT_AREA = HEIGHT_ROW_MONTH - HEIGHT_DATE
            HEIGHT_EVENT = HEIGHT_EVENT_AREA / CGFloat(ROW_EVENTS)
            HEIGHT_EVENT_RECTANGLE = 3
            WIDTH_EVENT_TITLE = WIDTH_DATE - 8
        }
    }
}
protocol ObjectSizesCollection {
    var WIDTH: CGFloat { get }
    var HEIGHT: CGFloat { get }
    var HEIGHT_WEEKCHAR: CGFloat { get }
    var WIDTH_DATE: CGFloat { get }
    var HEIGHT_DATE: CGFloat { get }
    var HEIGHT_ROW_MONTH: CGFloat { get }
    var WIDTH_EVENT: CGFloat { get }
    var HEIGHT_EVENT: CGFloat { get }
    var HEIGHT_EVENT_AREA: CGFloat { get }
    var HEIGHT_EVENT_RECTANGLE: CGFloat { get }
    var WIDTH_EVENT_TITLE: CGFloat { get }
    var ROW_EVENTS: Int { get }
    
    var NUMWEEK: Int { get }
    var NUMROWMONTH: Int { get }
}

func createEvent(day: Int) -> EKEvent {
    let eventStore = EKEventStore()
    let ekEvent = EKEvent(eventStore: eventStore)
    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = "test"
    let r: Int = Array(1...30).randomElement()!
    let g: Int = Array(1...30).randomElement()!
    let b: Int = Array(1...30).randomElement()!
    calendar.cgColor = CGColor(red: CGFloat(r) / CGFloat(30), green: CGFloat(g) /  CGFloat(30), blue: CGFloat(b) / CGFloat(30), alpha: 1)
    ekEvent.calendar = calendar
    ekEvent.title = "titleTest \(day)"
    ekEvent.url = URL(string: "https://lepl.net")
    ekEvent.location = "山口県"
    ekEvent.recurrenceRules = [EKRecurrenceRule(recurrenceWith: .daily, interval: 5, end: nil)]
    let year = DateObject().getYear(Date())
    let month = DateObject().getMonth(Date())
    ekEvent.startDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day, hour: r % 24))
    ekEvent.endDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day, hour: r % 24 + 10))
    ekEvent.isAllDay = false
    
    return ekEvent
}

class InfoMonth {
    init(year: Int, month: Int) {
        let calendar = Calendar.current
        let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: 1)
        let date = calendar.date(from: dateComp)!
        let rangeMonth = calendar.range(of: .day, in: .month, for: date)!
        let noWeekFirstDate = calendar.component(.weekday, from: date)
        
        self.noWeekFirstDate = noWeekFirstDate - 1
        self.rangeMonth = rangeMonth
    }
    
    init(date: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: 1)
        let date = calendar.date(from: dateComp)!
        let rangeMonth = calendar.range(of: .day, in: .month, for: date)!
        let noWeekFirstDate = calendar.component(.weekday, from: date)
        
        self.noWeekFirstDate = noWeekFirstDate - 1
        self.rangeMonth = rangeMonth
    }
    
    func getDay(_ row: Int, _ column: Int, _ carryover: Int) -> Int {
        return (row * 7 + column + 1) - carryover
    }
    
    func getWeek(calendar: Calendar = Calendar.current) -> [String] {
        var calendar = calendar
        calendar.locale = Locale(identifier: "ja_JP")
        return calendar.shortWeekdaySymbols
    }
    
    var noWeekFirstDate: Int
    var rangeMonth: Range<Int>
}

struct MonthCalendar_Previews: PreviewProvider {
    static var previews: some View {
        MonthCalendar(YEAR: 2023, MONTH: 11, eventData: EventData(), selectedEventDate: Binding.constant(Date()), contentHeight: 400)
    }
}
