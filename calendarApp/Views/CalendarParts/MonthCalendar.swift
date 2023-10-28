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
    let week: [String] = ["日","月","火","水","木","金","土"]
    var startWeek: String = "日"
    let NUMWEEK = 7
    let NUMROWMONTH = 6
    let YEAR: Int
    let MONTH: Int
    
    let LINE_COLOR = Color.gray
    
    var body: some View {
        let indexStartWeek = week.firstIndex(of: startWeek)!
        let customWeek: [String] = createCustomWeek(indexStartWeek)
        let infoMonth = getInfoMonth(year: YEAR, month: MONTH)
        let CARRYOVER = infoMonth.noWeekFirstDate
        // イベント取得
        let ekEvents: [EKEvent] = EventControllerMonthClass().getEvents(year: YEAR, month: MONTH)
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let HEIGHT_WEEK: CGFloat = 20
            let WIDTH_DATE: CGFloat = width /  CGFloat(NUMWEEK)
            let HEIGHT_DATE: CGFloat = 12
            let HEIGHT_ROW_MONTH: CGFloat = (height - HEIGHT_WEEK) / CGFloat(NUMROWMONTH)
            let WIDTH_TITLE: CGFloat = WIDTH_DATE - 8
            let HEIGHT_EVENT: CGFloat = 19
            let HEIGHT_EVENT_SPACE = HEIGHT_ROW_MONTH - HEIGHT_DATE
            let ROW_EVENTS: Int = Int((HEIGHT_ROW_MONTH - 10) / HEIGHT_EVENT) - 1
            
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    // 週
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { index in
                            Text(customWeek[index])
                                .frame(width: WIDTH_DATE,height: HEIGHT_WEEK)
                                .font(.system(size: 10))
                        }
                    }
                    
                    //　日付と仕切り線
                    ForEach(0..<NUMROWMONTH, id: \.self) { rowIndex in
                        
                        //仕切りの線
                        Rectangle()
                            .fill(LINE_COLOR)
                            .frame(width: width, height: 1)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<NUMWEEK, id: \.self) { columnIndex in
                                VStack(spacing: 0) {
                                    if infoMonth.rangeMonth ~= infoMonth.getDate(rowIndex, columnIndex, CARRYOVER) {
                                        
                                        //日付
                                        Text(infoMonth.getDate(rowIndex, columnIndex, CARRYOVER).description)
                                            .frame(width: WIDTH_DATE, height: HEIGHT_DATE, alignment: .center)
                                            .font(.system(size: 10))
                                            .frame(width: WIDTH_DATE)
                                        
                                    } else {
                                        Text("")
                                            .frame(width: WIDTH_DATE, height: HEIGHT_DATE)
                                    }
                                }
                            }
                        }
                        .frame(height: HEIGHT_ROW_MONTH, alignment: .top)
                    }
                }
                // イベント
                EventSeal(ekEvent: createEvent(day: 2),
                          countEvents: createEventsArray(range: infoMonth.rangeMonth, rowEvents: ROW_EVENTS),
                          WIDTH_DATE: WIDTH_DATE, HEIGHT_DATE: HEIGHT_DATE,
                          HEIGHT_EVENT: HEIGHT_EVENT,
                          HEIGHT_EVENT_SPACE: HEIGHT_EVENT_SPACE,
                          CARRYOVER: CARRYOVER)
                .padding(EdgeInsets(top: HEIGHT_WEEK, leading: 0, bottom: 0, trailing: 0))
                
                EventSeal(ekEvent: createEvent(day: 3),
                          countEvents: createEventsArray(range: infoMonth.rangeMonth, rowEvents: ROW_EVENTS),
                          WIDTH_DATE: WIDTH_DATE, HEIGHT_DATE: HEIGHT_DATE,
                          HEIGHT_EVENT: HEIGHT_EVENT,
                          HEIGHT_EVENT_SPACE: HEIGHT_EVENT_SPACE,
                          CARRYOVER: CARRYOVER)
                    .padding(EdgeInsets(top: HEIGHT_WEEK, leading: 0, bottom: 0, trailing: 0))
                
                if !ekEvents.isEmpty {
                    ForEach(ekEvents, id: \.self) { ekEvent in
                        EventSeal(ekEvent: ekEvent,
                                  countEvents: createEventsArray(range: infoMonth.rangeMonth, rowEvents: ROW_EVENTS),
                                  WIDTH_DATE: WIDTH_DATE, HEIGHT_DATE: HEIGHT_DATE,
                                  HEIGHT_EVENT: HEIGHT_EVENT,
                                  HEIGHT_EVENT_SPACE: HEIGHT_EVENT_SPACE,
                                  CARRYOVER: CARRYOVER)
                            .padding(EdgeInsets(top: HEIGHT_WEEK, leading: 0, bottom: 0, trailing: 0))
                        
                    }
                }
            }
        }
    }
    
    func createCustomWeek(_ indexStartWeek: Int) -> [String] {
        var w = [String]()
        
        for i in 0..<7 {
            w.append(week[(i + indexStartWeek) % 7])
        }
        
        return w
    }
    
    func createEventsArray(range: Range<Int>, rowEvents: Int) -> [[Int]] {
        var row: [Int] = []
        for _ in 0..<rowEvents {
            row.append(0)
        }
        
        var countEvents: [[Int]] = []
        for _ in range {
            countEvents.append(row)
        }
        
        return countEvents
    }

}

func createEvent(day: Int) -> EKEvent {
    let eventStore = EKEventStore()
    let ekEvent = EKEvent(eventStore: eventStore)
    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = "test"
    calendar.cgColor = CGColor(red: 0.3 * CGFloat(day), green: 0.7 * CGFloat(day), blue: 0.2, alpha: 1)
    ekEvent.calendar = calendar
    ekEvent.title = "titleTest "
    ekEvent.startDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2023, month: 10, day: day))
    ekEvent.endDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2023, month: 11, day: 0))
    ekEvent.isAllDay = false
    
    return ekEvent
}

class getInfoMonth {
    init(year: Int, month: Int) {
        let calendar = Calendar(identifier: .gregorian)
        let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: 1)
        let date = calendar.date(from: dateComp)!
        let rangeMonth = calendar.range(of: .day, in: .month, for: date)!
        let noWeekFirstDate = calendar.component(.weekday, from: date)
        
        self.noWeekFirstDate = noWeekFirstDate - 1
        self.rangeMonth = rangeMonth
    }
    
    init(date: Date) {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let calendar = Calendar(identifier: .gregorian)
        let dateComp = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"),year: year, month: month, day: 1)
        let date = calendar.date(from: dateComp)!
        let rangeMonth = calendar.range(of: .day, in: .month, for: date)!
        let noWeekFirstDate = calendar.component(.weekday, from: date)
        
        self.noWeekFirstDate = noWeekFirstDate - 1
        self.rangeMonth = rangeMonth
    }
    
    func getDate(_ row: Int, _ column: Int, _ carryover: Int) -> Int {
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
        MonthCalendar(YEAR: 2023, MONTH: 10)
    }
}
