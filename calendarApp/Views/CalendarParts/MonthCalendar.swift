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
    @EnvironmentObject var customColor: CustomColor
    @EnvironmentObject var eventViewController: EventViewController
    //@ObservedObject var eventData: EventData
    //@Binding var selectedEventDate: Date?
    
    var startWeek: String
    let year: Int
    let month: Int
    let infoMonth: InfoMonth
    let week: [String]
    
    let maxCalendarHeight: CGFloat
    
    let calendar = CalendarDateUtil.calendar
    
    init(year: Int, MONTH: Int, contentHeight: CGFloat) {
        self.year = year
        self.month = MONTH
        self.infoMonth = InfoMonth(year: year, month: MONTH)
        self.week = CalendarDateUtil.getWeekSymbols
        self.startWeek = self.week[0]
        
        self.maxCalendarHeight = contentHeight
    }
    
    let LINE_COLOR = Color.gray.opacity(0.5)
    
    var body: some View {
        let indexStartWeek = week.firstIndex(of: startWeek)!
        let customWeek: [String] = createCustomWeek(indexStartWeek)
        // イベント取得
        GeometryReader { geometry in
            let objectSizes: EventSizesComponent = EventSizesComponent(width: geometry.size.width, height: geometry.size.height, maxCalendarHeight: maxCalendarHeight)
            VStack(alignment: .leading, spacing: 0) {
                // 週
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        Text(customWeek[index])
                            .foregroundStyle(.black)
                            .background (customColor.backGround)
                            .frame(width: objectSizes.widthDate,height: objectSizes.heightWeekChar)
                            .font(.system(size: 10))
                    }
                }
                
                //　日付と仕切り線
                ForEach(0..<objectSizes.numRowMonth, id: \.self) { rowIndex in
                    
                    //仕切りの線
                    /*
                    Rectangle()
                        .fill(LINE_COLOR)
                        .frame(width: objectSizes.WIDTH, height: 1)
                    */
                    HStack(spacing: 0) {
                        ForEach(0..<objectSizes.numWeek, id: \.self) { columnIndex in
                            VStack(spacing: 0) {
                                let indexMonth = rowIndex * 7 + columnIndex
                                let thisDate: Date = Array(infoMonth.datesInMonth)[indexMonth]
                                let day: Int = CalendarDateUtil.getDay(thisDate)
                                let isDateViewMonth: Bool = month ==  CalendarDateUtil.getMonth(thisDate)
                                let isPast = CalendarDateUtil.isPast(thisDate)
                                
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
                                            .frame(width: objectSizes.widthDate, height: objectSizes.heightDate, alignment: .center)
                                            .font(.system(size: 10))
                                            .foregroundStyle(isDateViewMonth ? dayColor : dayColor.opacity(0.3))
                                            .fontWeight(isDateViewMonth ? .regular : .semibold)
                                        //.frame(width: objectSizes.WIDTH_DATE)
                                    }
                                    .frame(height: objectSizes.heightRowMonth, alignment: .top)
                                    .background(isPast ? customColor.past: customColor.calendarBack)
                                    .clipShape(isPast && !CalendarDateUtil.isPast(calendar.date(byAdding: .day, value: 1, to: thisDate)) && !(indexMonth % 7 == 6) ? UnevenRoundedRectangle(bottomTrailingRadius: 10) : UnevenRoundedRectangle())
                                }
                                .buttonStyle(StaticButtonStyle())
                                
                            }
                            
                        }
                    }
                    .frame(height: objectSizes.heightRowMonth, alignment: .top)
                }
                
            }
            
            ZStack(alignment: .topLeading) {
                
                let ekEvents = EventController.getEvents(startDate: infoMonth.datesInMonth.first, endDate: infoMonth.datesInMonth.last, ekCalendars: eventViewController.shownEKCalendar)
                /*
                let ekEvents = [createEvent(day: 9, title: "かだい"), createEvent(day: 10, title: "課題"),createEvent(day: 11),createEvent(day: 15),createEvent(day: 17),createEvent(day: 18)]*/
                let ekEventsStepMap = getEventsStepMap(ekEvents: ekEvents)
                
                //if !ekEvents.isEmpty {
                ForEach(ekEvents, id: \.self) { ekEvent in
                    if let step = ekEventsStepMap[ekEvent],
                       step < objectSizes.rowEvents {
                        EventSealShortPdding(showEvents: $eventViewController.showEvents, ekEvent: ekEvent, step: step, datesInMonth: infoMonth.datesInMonth)
                            .environmentObject(objectSizes)
                            .padding(EdgeInsets(top: objectSizes.heightWeekChar, leading: 0, bottom: 0, trailing: 0))
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

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

func getEventsStepMap(ekEvents: [EKEvent]) -> [EKEvent: Int] {
    var eventsFloorMap = [EKEvent: Int]()
    let ekEvents = ekEvents.sorted { $0.startDate < $1.startDate }
    for ekEvent in ekEvents {
        let targetEventFloors = eventsFloorMap.filter { e, f in
            if ekEvent.startDate.toStart <= e.endDate.toStart {
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

func createEvent(date: Date, title: String = "titlete テスト", color: CGColor = CGColor(red: 0.5, green: 0.1, blue: 0, alpha: 1)) -> EKEvent {
    let eventStore = EKEventStore()
    let ekEvent = EKEvent(eventStore: eventStore)
    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = "test"
    /*
    let r: Int = Array(1...30).randomElement()!
    let g: Int = Array(1...30).randomElement()!
    let b: Int = Array(1...30).randomElement()!
    calendar.cgColor = CGColor(red: CGFloat(r) / CGFloat(30), green: CGFloat(g) /  CGFloat(30), blue: CGFloat(b) / CGFloat(30), alpha: 1)
     */
    calendar.cgColor = color
    ekEvent.calendar = calendar
    ekEvent.title = title
    ekEvent.recurrenceRules = [EKRecurrenceRule(recurrenceWith: .daily, interval: 5, end: nil)]
    let year = CalendarDateUtil.getYear(date)
    let month = CalendarDateUtil.getMonth(date)
    let day = CalendarDateUtil.getDay(date)
    let hour = CalendarDateUtil.getHour(date)
    ekEvent.startDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day, hour: hour))
    ekEvent.endDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day, hour: hour + 10))
    ekEvent.isAllDay = false
    
    return ekEvent
}

class InfoMonth: ObservableObject {
    let carryover: Int
    let datesInMonth: [Date]
    let intRangeViewMonth: Range<Int>
    
    init(year: Int, month: Int) {
        let calendar = CalendarDateUtil.calendar
        let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: 1)
        let date = calendar.date(from: dateComp)!
        self.carryover = calendar.component(.weekday, from: date) - 1
        self.intRangeViewMonth = calendar.range(of: .day, in: .month, for: date)!
        let start = calendar.date(from: DateComponents(year: year, month: month, day: (intRangeViewMonth.lowerBound - carryover)))!
        let end = calendar.date(from: DateComponents(year: year, month: month, day: (42 - carryover)))!
        self.datesInMonth = CalendarDateUtil.getDates(from: start, to: end)
    }
    
    convenience init(date: Date) {
        let calendar = CalendarDateUtil.calendar
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        self.init(year: year, month: month)
    }
    
    func getDayFromPosition(_ row: Int, _ column: Int) -> Int {
        return (row * 7 + column + 1) - carryover
    }
}

struct MonthCalendar_Previews: PreviewProvider {
    static var previews: some View {
        MonthCalendar(year: 2023, MONTH: 11, contentHeight: 400)
    }
}
