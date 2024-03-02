//
//  EventController.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/02/25.
//

import Foundation
import EventKit

protocol EventController {
    var eventStore: EKEventStore { get }
    
    // アクセス状況を確認
    func checkAccess() -> Bool
    
    // 各処理
    // 取得
    func getEvents(startDate: Date?, endDate: Date?) -> [EKEvent]
    func getCalendars() -> [EKCalendar]
    // イベント追加
    /*
    func addEvent(calendar: EKCalendar,
                  title: String,
                  startDate: Date,
                  endDate: Date,
                  isAllDay: Bool,
                  location: String?,
                  timeZone: TimeZone,
                  url: URL?,
                  notes: String?, // メモ
                  recurrenceRules: [EKRecurrenceRule]?) -> Bool*/
    // カレンダー追加
    func addCalendar(nameCalendar: String, cgColor: CGColor) -> Bool
    // 消去
    func removeEvent(idEvent: String, span: EKSpan) -> Bool
}

// 純正カレンダーとの連絡
class EventControllerClass: EventController, ObservableObject {
    var eventStore: EKEventStore
    var calendar: Calendar
    
    init (eventStore: EKEventStore) {
        self.eventStore = eventStore
        self.calendar = CalendarDateComponent.calendar
        if !checkAccess() {
            Task {
                await self.requestAccess()
            }
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
    
    func requestAccess() async -> Bool {
        if !checkAccess() {
            if #available(iOS 17.0, *) {
                self.eventStore.requestFullAccessToEvents { granted, error in
                    if granted && error == nil {
                        print("許可")
                    } else {
                        print("拒否")
                    }
                }
            } else {
                // Fallback on earlier versions
                self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
                    if granted && error == nil {
                        print("許可")
                    } else {
                        print("拒否")
                    }
                })
            }
        }
        return checkAccess()
    }
    
    func getEvents(date: Date = Date()) -> [EKEvent] {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startDate = calendar.date(from: components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)
        let predicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: getCalendars())
        return eventStore.events(matching: predicate)
    }
    
    func getEvents(startDate: Date? = Date(), endDate: Date? = Date()) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: getCalendars())
        return eventStore.events(matching: predicate)
    }
    
    func getEvents(year: Int, month: Int) -> [EKEvent] {
        let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: 0))!
        let endDate = calendar.date(from: DateComponents(year: year, month: month + 1, day: 0, hour: 23, minute: 59, second: 59))!
        let predicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: getCalendars())
        return self.eventStore.events(matching: predicate)
    }
    
    func getEvent(identifier: String) -> EKEvent? {
        return eventStore.event(withIdentifier: identifier)
    }
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    /*
    func addEvent(calendar: EKCalendar,
                  title: String,
                  startDate: Date,
                  endDate: Date,
                  isAllDay: Bool,
                  location: String? = nil,
                  timeZone: TimeZone = TimeZone(identifier: "Asia/Tokyo")!,
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
            try eventStore.save(ekEvent, span: .thisEvent, commit: true)
            try eventStore.commit()
        } catch  {
            return false
        }
        return true
    }*/
    
    func addEvent(ekEvent: EKEvent) -> Bool {
        do {
            try self.eventStore.save(ekEvent, span: .thisEvent, commit: true)
        } catch  {
            return false
        }
        return true
    }
    
    func saveEvent(ekEvent: EKEvent, span: EKSpan) -> Bool {
        do {
            try self.eventStore.save(ekEvent, span: span, commit: true)
        } catch  {
            return false
        }
        return true
    }
    
    func addCalendar(nameCalendar: String, cgColor: CGColor) -> Bool {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = nameCalendar
        calendar.cgColor = cgColor
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch {
            return false
        }
        return true
    }
    
    func removeEvent(idEvent: String, span: EKSpan = .thisEvent) -> Bool {
        if let event: EKEvent = eventStore.event(withIdentifier: idEvent) {
            do {
                try eventStore.remove(event, span: span, commit: true)
            } catch {
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    func removeEvent(ekEvent: EKEvent, span: EKSpan = .thisEvent) -> Bool {
        do {
            try eventStore.remove(ekEvent, span: span, commit: true)
        } catch {
            return false
        }
        return true
    }
}
