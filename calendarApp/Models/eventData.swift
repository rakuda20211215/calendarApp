//
//  eventData.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/08.
//

import Foundation
import RealmSwift
import EventKit

// title
// date
// calendar
// url
// place
// memo
// repetition
// notification(通知)

// isDeleteAfter

class EventData: ObservableObject {
    @Published var ekEvent: EKEvent = EKEvent(eventStore: EKEventStore())
    @Published var eventController = EventControllerClass()
    // 日付が過ぎると消去
    @Published var isDeleteAfterEndDate: Bool
    // 最初に表示するカレンダー
    @Published var defaultCalendar: EKCalendar?
    
    @Published var visibleSwitch: visibleDateTime = .invisible
    
    static func compareStartEnd(ekEvent: EKEvent, date: Date) -> Void {
        let start: Date = ekEvent.startDate
        let end:   Date = ekEvent.endDate
        if start > end {
            ekEvent.startDate = date
            ekEvent.endDate =   date
        }
    }
    
    init(isDeleteAfterEndDate: Bool = false) {
        self.isDeleteAfterEndDate = isDeleteAfterEndDate
        self.defaultCalendar = eventController.getCalendars().isEmpty ? nil : eventController.getCalendars()[0]
        let calendar = DateObject().calendar
        let min = Int((Double(calendar.component(.minute, from: Date())) / Double(5)).rounded(.toNearestOrAwayFromZero)) * 5
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: Date())
        components.minute = min >= 60 ? 0 : min
        let date = calendar.date(from: components)!
        self.ekEvent.startDate = date
        self.ekEvent.endDate = date
    }
}

enum visibleDateTime: Int {
    case startDate = 0
    case startTime = 1
    case endDate   = 2
    case endTime   = 3
    case invisible = 5
}

protocol EventController {
    var eventStore: EKEventStore { get }
    
    // アクセス状況を確認
    func checkAccess() -> Bool
    
    // 各処理
    // 取得
    func getEvents(startDate: Date?, endDate: Date?, year: Int?, month: Int?) -> [EKEvent]
    func getCalendars() -> [EKCalendar]
    // イベント追加
    func addEvent(calendar: EKCalendar,
                  title: String,
                  startDate: Date,
                  endDate: Date,
                  isAllDay: Bool,
                  location: String?,
                  timeZone: TimeZone,
                  url: URL?,
                  notes: String?, // メモ
                  recurrenceRules: [EKRecurrenceRule]?) -> Bool
    // カレンダー追加
    func addCalendar(nameCalendar: String) -> Bool
    // 消去
    func removeEvent(idEvent: String) -> Bool
}

// 純正カレンダーとの連絡
class EventControllerClass: EventController, ObservableObject {
    
    var eventStore: EKEventStore
    
    init (startDate: Date = Date(), endDate: Date = Date()) {
        self.eventStore = EKEventStore()
        if !checkAccess() {
            self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if granted && error == nil {
                    print("許可")
                }
            })
        }
    }
    
    func checkAccess() -> Bool {
        let eventStoreStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch eventStoreStatus {
        case .authorized: // 許可済み
            return true
        case .denied: // 拒否
            return false
        case .notDetermined: // 未選択
            return false
        case .restricted: // 非許可
            return false
        default:
            return false
        }
    }
    
    func getEvents(startDate: Date? = Date(), endDate: Date? = Date(), year: Int? = nil, month: Int? = nil) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: getCalendars())
        return eventStore.events(matching: predicate)
    }
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    func addEvent(calendar: EKCalendar,
                  title: String,
                  startDate: Date,
                  endDate: Date,
                  isAllDay: Bool,
                  location: String? = nil,
                  timeZone: TimeZone,
                  url: URL? = nil,
                  notes: String? = nil, // メモ
                  recurrenceRules: [EKRecurrenceRule]? = nil // 繰り返しルール
    ) -> Bool {
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.calendar = calendar
        ekEvent.title = title
        ekEvent.startDate = startDate
        ekEvent.endDate = endDate
        ekEvent.isAllDay = isAllDay
        ekEvent.location = location
        ekEvent.timeZone = timeZone
        ekEvent.url = url
        ekEvent.notes = notes
        ekEvent.recurrenceRules = recurrenceRules
        do {
            try eventStore.save(ekEvent, span: .thisEvent)
        } catch {
            return false
        }
        return true
    }
    
    func addCalendar(nameCalendar: String) -> Bool {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = nameCalendar
        calendar.cgColor = CGColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch {
            return false
        }
        return true
    }
    
    func removeEvent(idEvent: String) -> Bool {
        let event: EKEvent = eventStore.event(withIdentifier: idEvent)!
        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            return false
        }
        return true
    }
}

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

// 純正カレンダーとの連絡
class EventControllerMonthClass: EventController, ObservableObject {
    var eventStore: EKEventStore
    var calendar: Calendar
    
    init () {
        self.eventStore = EKEventStore()
        self.calendar = Calendar(identifier: .gregorian)
        if !checkAccess() {
            self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if granted && error == nil {
                    print("許可")
                }
            })
        }
    }
    
    func checkAccess() -> Bool {
        let eventStoreStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch eventStoreStatus {
        case .authorized: // 許可済み
            return true
        case .denied: // 拒否
            return false
        case .notDetermined: // 未選択
            return false
        case .restricted: // 非許可
            return false
        default:
            return false
        }
    }
    
    func getEvents(startDate: Date? = nil, endDate: Date? = nil, year: Int?, month: Int?) -> [EKEvent] {
        let startDate = calendar.date(from: DateComponents(year: year!, month: month!, day: 1, hour: 0, minute: 0, second: 0))!
        print(startDate)
        let endDate = calendar.date(from: DateComponents(year: year!, month: month! + 1, day: 0, hour: 23, minute: 59, second: 59))!
        print(endDate)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: getCalendars())
        return eventStore.events(matching: predicate)
    }
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    func addEvent(calendar: EKCalendar,
                  title: String,
                  startDate: Date,
                  endDate: Date,
                  isAllDay: Bool,
                  location: String? = nil,
                  timeZone: TimeZone,
                  url: URL? = nil,
                  notes: String? = nil, // メモ
                  recurrenceRules: [EKRecurrenceRule]? = nil // 繰り返しルール
    ) -> Bool {
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.calendar = calendar
        ekEvent.title = title
        ekEvent.startDate = startDate
        ekEvent.endDate = endDate
        ekEvent.isAllDay = isAllDay
        ekEvent.location = location
        ekEvent.timeZone = timeZone
        ekEvent.url = url
        ekEvent.notes = notes
        ekEvent.recurrenceRules = recurrenceRules
        do {
            try eventStore.save(ekEvent, span: .thisEvent)
        } catch {
            return false
        }
        return true
    }
    
    func addCalendar(nameCalendar: String) -> Bool {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = nameCalendar
        calendar.cgColor = CGColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch {
            return false
        }
        return true
    }
    
    func removeEvent(idEvent: String) -> Bool {
        let event: EKEvent = eventStore.event(withIdentifier: idEvent)!
        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            return false
        }
        return true
    }
}
