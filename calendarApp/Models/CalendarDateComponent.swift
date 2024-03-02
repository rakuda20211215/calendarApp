//
//  CalendarDateComponent.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/02/29.
//

import Foundation

class CalendarDateComponent: ObservableObject {
    var year: Int
    var month: Int
    @Published var yearView: Int
    @Published var monthView: Int
    @Published var viewDate: Date
    var rangeMonth: [Int] = Array<Int>(-2...2)
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? calendar.timeZone
        calendar.locale = Locale(identifier: "ja_JP")
        return calendar
    }
    
    init(viewDate: Date = Date()) {
        self.viewDate = viewDate
        self.year = Calendar.current.component(.year, from: viewDate)
        self.month = Calendar.current.component(.month, from: viewDate)
        self.yearView = year
        self.monthView = month
    }
    
    func initializObj(date: Date) {
        self.viewDate = date
        self.rangeMonth = Array<Int>(-2...2)
        self.year = Calendar.current.component(.year, from: date)
        self.month = Calendar.current.component(.month, from: date)
        self.yearView = year
        self.monthView = month
    }
    
    func updateDateObj(selection: Int) {
        if selection < 0 {
            self.monthView -= 1
            if self.monthView < 1 {
                self.monthView = 12
                self.yearView -= 1
            }
        } else {
            self.monthView += 1
            if self.monthView > 12 {
                self.monthView = 1
                self.yearView += 1
            }
        }
    }
    
    static var getWeekSymbols: [String] {
        var calendar = CalendarDateComponent.calendar
        calendar.locale = Locale(identifier: "ja_JP")
        return calendar.shortWeekdaySymbols
    }
    
    static func getDates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        let calendar = CalendarDateComponent.calendar
        var from = calendar.startOfDay(for: fromDate)
        var to = calendar.startOfDay(for: toDate)
        
        while from <= to {
            dates.append(from)
            guard let nextDate = CalendarDateComponent.calendar.date(byAdding: .day, value: 1, to: from) else { break }
            from = nextDate
        }
        
        return dates
    }
    
    static func getDate(year: Int, month: Int, day: Int) -> Date {
        let dateComp = DateComponents(year: year, month: month, day: day)
        return self.calendar.date(from: dateComp)!
    }
    
    static func getYear(_ date: Date = Date()) -> Int {
        Self.calendar.component(.year, from: date)
    }
    static func getMonth(_ date: Date = Date()) -> Int {
        calendar.component(.month, from: date)
    }
    static func getDay(_ date: Date = Date()) -> Int {
        calendar.component(.day, from: date)
    }
    static func getHour(_ date: Date = Date()) -> Int {
        calendar.component(.hour, from: date)
    }
    static func getMinute(_ date: Date = Date()) -> Int {
        calendar.component(.minute, from: date)
    }
    
    static func isPast(_ date: Date?) -> Bool {
        let calendar = CalendarDateComponent.calendar
        let target = calendar.startOfDay(for: date ?? Date())
        let today = calendar.startOfDay(for: Date())
        return target < today
    }
}
