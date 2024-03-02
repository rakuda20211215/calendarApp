//
//  MonthCalendar.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/06.
//

import SwiftUI
import UIKit
import EventKit

import JapaneseNationalHolidays

struct MonthCalendar: View {
    @EnvironmentObject var eventViewController: EventViewController
    @EnvironmentObject var customColor: CustomColor
    //@ObservedObject var eventData: EventData
    //@Binding var selectedEventDate: Date?
    
    var startWeek: String
    let YEAR: Int
    let MONTH: Int
    let infoMonth: InfoMonth
    let week: [String]
    
    let maxCalendarHeight: CGFloat
    
    let calendar = CalendarDateComponent.calendar
    
    init(YEAR: Int, MONTH: Int, contentHeight: CGFloat) {
        self.YEAR = YEAR
        self.MONTH = MONTH
        self.infoMonth = InfoMonth(year: YEAR, month: MONTH)
        self.week = CalendarDateComponent.getWeekSymbols
        self.startWeek = self.week[0]
        
        self.maxCalendarHeight = contentHeight
    }
    
    let LINE_COLOR = Color.gray.opacity(0.5)
    
    var body: some View {
        let indexStartWeek = week.firstIndex(of: startWeek)!
        let customWeek: [String] = createCustomWeek(indexStartWeek)
        // イベント取得
        GeometryReader { geometry in
            let objectSizes: ObjectSizes = ObjectSizes(width: geometry.size.width, height: geometry.size.height, maxCalendarHeight: maxCalendarHeight)
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
                    /*
                    Rectangle()
                        .fill(LINE_COLOR)
                        .frame(width: objectSizes.WIDTH, height: 1)
                    */
                    HStack(spacing: 0) {
                        ForEach(0..<objectSizes.NUMWEEK, id: \.self) { columnIndex in
                            VStack(spacing: 0) {
                                let indexMonth = rowIndex * 7 + columnIndex
                                let thisDate: Date = Array(infoMonth.rangeMonth)[indexMonth]
                                let day: Int = CalendarDateComponent.getDay(thisDate)
                                let isDateViewMonth: Bool = MONTH ==  CalendarDateComponent.getMonth(thisDate)
                                let isPast = CalendarDateComponent.isPast(thisDate)
                                
                                var dayColor: Color {
                                    if thisDate.isJapaneseNationalHoliday || calendar.component(.weekday, from: thisDate) == 1 {
                                        return customColor.holidays
                                    } else if calendar.component(.weekday, from: thisDate) == 7 {
                                        return customColor.sundays
                                    }
                                    return customColor.workdays
                                }
                                
                                Button {
                                    //let ekEvents = eventViewController.eventController.getEvents(date: thisDate)
                                    eventViewController.updateSelectedDayEvents(date: thisDate)
                                    //if !ekEvents.isEmpty {
                                    //eventViewController.selectedEventDate = thisDate
                                    eventViewController.toggleShowEvents(true)
                                    //}
                                } label: {
                                    //日付
                                    VStack {
                                        Text(day.description)
                                            .frame(width: objectSizes.WIDTH_DATE, height: objectSizes.HEIGHT_DATE, alignment: .center)
                                            .font(.system(size: 10))
                                            .foregroundStyle(isDateViewMonth ? dayColor : dayColor.opacity(0.9))
                                            .fontWeight(isDateViewMonth ? .bold : .light)
                                        //.frame(width: objectSizes.WIDTH_DATE)
                                    }
                                    .frame(height: objectSizes.HEIGHT_ROW_MONTH, alignment: .top)
                                    .background(isPast ? customColor.past: customColor.calendarBack)
                                    .clipShape(isPast && !CalendarDateComponent.isPast(calendar.date(byAdding: .day, value: 1, to: thisDate)) ? UnevenRoundedRectangle(bottomTrailingRadius: 10) : UnevenRoundedRectangle())
                                }
                                
                            }
                            
                        }
                    }
                    .frame(height: objectSizes.HEIGHT_ROW_MONTH, alignment: .top)
                }
                
            }
            
            ZStack(alignment: .topLeading) {
                let ekEvents = eventViewController.eventController.getEvents(startDate: infoMonth.rangeMonth.first, endDate: infoMonth.rangeMonth.last)
                let ekEventsStepMap = getEventsStepMap(ekEvents: ekEvents)
                
                //if !ekEvents.isEmpty {
                ForEach(ekEvents, id: \.self) { ekEvent in
                    if let step = ekEventsStepMap[ekEvent],
                       step < objectSizes.ROW_EVENTS {
                        
                        
                        EventSeal(showEvents: $eventViewController.showEvents, ekEvent: ekEvent, step: step)
                            .environmentObject(objectSizes)
                            .environmentObject(infoMonth)
                            .padding(EdgeInsets(top: objectSizes.HEIGHT_WEEKCHAR, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
            
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    func createCustomWeek(_ indexStartWeek: Int) -> [String] {
        var w = [String]()
        
        for i in 0..<7 {
            w.append(week[(i + indexStartWeek) % 7])
        }
        
        return w
    }
}


func getEventsStepMap(ekEvents: [EKEvent]) -> [EKEvent: Int] {
    var eventsFloorMap = [EKEvent: Int]()
    for ekEvent in ekEvents {
        let targetStartDay = ekEvent.startDate!
        let targetEventFloors = eventsFloorMap.filter { e, f in
            let loopEndday = e.endDate!
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


class ObjectSizes: ObservableObject {
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
    init(width: CGFloat, height: CGFloat, maxCalendarHeight: CGFloat) {
        WIDTH = width
        HEIGHT = height
        HEIGHT_WEEKCHAR = 20
        WIDTH_DATE = WIDTH /  CGFloat(NUMWEEK)
        HEIGHT_DATE = 13
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
    let year = CalendarDateComponent.getYear(Date())
    let month = CalendarDateComponent.getMonth(Date())
    ekEvent.startDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day, hour: r % 24))
    ekEvent.endDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day, hour: r % 24 + 10))
    ekEvent.isAllDay = false
    
    return ekEvent
}

class InfoMonth: ObservableObject {
    let carryover: Int
    let rangeMonth: [Date]
    let intRangeViewMonth: Range<Int>
    
    init(year: Int, month: Int) {
        let calendar = CalendarDateComponent.calendar
        let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: 1)
        let date = calendar.date(from: dateComp)!
        self.carryover = calendar.component(.weekday, from: date) - 1
        self.intRangeViewMonth = calendar.range(of: .day, in: .month, for: date)!
        let start = calendar.date(from: DateComponents(year: year, month: month, day: (intRangeViewMonth.lowerBound - carryover)))!
        let end = calendar.date(from: DateComponents(year: year, month: month, day: (42 - carryover)))!
        self.rangeMonth = CalendarDateComponent.getDates(from: start, to: end)
    }
    
    init(date: Date) {
        let calendar = CalendarDateComponent.calendar
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: 1)
        let date = calendar.date(from: dateComp)!
        self.carryover = calendar.component(.weekday, from: date) - 1
        self.intRangeViewMonth = calendar.range(of: .day, in: .month, for: date)!
        let start = calendar.date(from: DateComponents(year: year, month: month, day: (intRangeViewMonth.lowerBound - carryover)))!
        let end = calendar.date(from: DateComponents(year: year, month: month, day: (42 - carryover)))!
        self.rangeMonth = CalendarDateComponent.getDates(from: start, to: end)
    }
    
    func getDayFromPosition(_ row: Int, _ column: Int) -> Int {
        return (row * 7 + column + 1) - carryover
    }
}

struct MonthCalendar_Previews: PreviewProvider {
    static var previews: some View {
        MonthCalendar(YEAR: 2023, MONTH: 11, contentHeight: 400)
    }
}
