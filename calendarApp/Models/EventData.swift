//
//  eventData.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/08.
//

import Foundation
import SwiftUI
import RealmSwift
import EventKitUI


class EventData: ObservableObject {
    static var eventStore: EKEventStore = EKEventStore()
    
    @Published var ekEvent: EKEvent
    @Published var eventController: EventControllerClass
    // 日付が過ぎると消去
    //@Published var isDeleteAfterEndDate: Bool
    
    @Published var isAllDay: Bool = false
    // 最初に表示するカレンダー
    var defaultEkCalendar: EKCalendar? {
        eventController.getCalendars().isEmpty ? nil : eventController.getCalendars()[0]
    }
    
    @Published var currentCalendar: EKCalendar?
    
    @Published var visibleSwitch: visibleDateTime = .invisible
    
    //@Published var selectedEventDate: Date?
    //@Published var showEvents: Bool = false
    
    static func compareStartEnd(ekEvent: EKEvent, date: Date) -> Void {
        let start: Date = ekEvent.startDate
        let end:   Date = ekEvent.endDate
        if start > end {
            ekEvent.startDate = date
            ekEvent.endDate =   date
        }
    }
    
    init(isDeleteAfterEndDate: Bool = false) {
        self.eventController = EventControllerClass(eventStore: Self.eventStore)
        self.ekEvent = EKEvent(eventStore: Self.eventStore)
        self.currentCalendar = eventController.getCalendars().isEmpty ? nil : eventController.getCalendars()[0]
        self.ekEvent.calendar = self.currentCalendar
        
        let calendar = CalendarDateComponent.calendar
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: Date())
        let startDate = calendar.date(from: components)!
        self.ekEvent.startDate = startDate
        
        if let hour = components.hour {
            components.hour = hour + 1
        }
        let endDate = calendar.date(from: components)!
        self.ekEvent.endDate = endDate
    }
    
    func initializeEvent() {
        self.ekEvent = EKEvent(eventStore: Self.eventStore)
        self.currentCalendar = eventController.getCalendars().isEmpty ? nil : eventController.getCalendars()[0]
        self.ekEvent.calendar = self.currentCalendar
        
        let calendar = CalendarDateComponent.calendar
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: Date())
        let startDate = calendar.date(from: components)!
        self.ekEvent.startDate = startDate
        
        if let hour = components.hour {
            components.hour = hour + 1
        }
        let endDate = calendar.date(from: components)!
        self.ekEvent.endDate = endDate
    }
}

enum visibleDateTime: Int {
    case startDate = 0
    case startTime = 1
    case endDate   = 2
    case endTime   = 3
    case invisible = 5
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day! + 1
    }
}
/*
// カレンダーのオブジェクト
class CalendarDataManager {
    var ekEvent: EKEvent?
    // 日跨ぎの途中
    var isSpan: passageType
    
    enum passageType: Int {
        case beginning = 1
        case span = 2
        case end = 3
        case disabled = 4
    }
    
    init(ekEvent: EKEvent, isSpan: passageType) {
        self.ekEvent = ekEvent
        self.isSpan = isSpan
    }
}
*/
