//
//  EventController.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/02/25.
//

import Foundation
import EventKit
import EventKitUI

protocol EventControllerProtocol {
    
    // アクセス状況を確認
    static func checkAccess() -> Bool
    static func requestAccess()
    
    // 各処理
    // 取得
    static func getEvents(startDate: Date?, endDate: Date?, ekCalendars: [EKCalendar]?) -> [EKEvent]
    static func getEvents(date: Date, ekCalendars: [EKCalendar]?) -> [EKEvent]
    static func getEvents(year: Int, month: Int, ekCalendars: [EKCalendar]?) -> [EKEvent]
    static func getCalendars() -> [EKCalendar]
    static func getCalendars(isShown: Bool?) -> [EKCalendar]
    // カレンダー追加
    static func addCalendar(nameCalendar: String, cgColor: CGColor) -> Bool
    // 消去
    static func addEvent(ekEvent: EKEvent) -> Bool
    static func saveEvent(ekEvent: EKEvent, span: EKSpan) -> Bool
    static func calendarBySourceAllows(calendars: [EKCalendar]) -> [EKSourceType : [EKCalendar]]
    static func calendarBySourceAll(calendars: [EKCalendar]) -> [EKSourceType : [EKCalendar]]
    static func removeEvent(idEvent: String, span: EKSpan) -> Bool
    static func removeEvent(ekEvent: EKEvent, span: EKSpan) -> Bool
}

// 純正カレンダーとの連絡
class EventController: EventControllerProtocol, ObservableObject {
    static var isAllowingAccess: Bool = false
    
    static func checkAccess() -> Bool {
        let eventStoreStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch eventStoreStatus {
        case .authorized: // 許可済み
            EventController.isAllowingAccess = true
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
    
    static func requestAccess() {
        if !Self.checkAccess() {
            if #available(iOS 17.0, *) {
                EventData.eventStore.requestFullAccessToEvents { granted, error in
                    if granted && error == nil {
                        print("許可")
                        EventController.isAllowingAccess = true
                        SwitchableEKCalendar.sync()
                    } else {
                        print("拒否")
                    }
                }
            } else {
                // Fallback on earlier versions
                EventData.eventStore.requestAccess(to: .event, completion: { (granted, error) in
                    if granted && error == nil {
                        print("許可")
                        EventController.isAllowingAccess = true
                        SwitchableEKCalendar.sync()
                    } else {
                        print("拒否")
                    }
                })
            }
        }
    }
    
    static func getEvents(startDate: Date?, endDate: Date?, ekCalendars: [EKCalendar]? = nil) -> [EKEvent] {
        guard Self.isAllowingAccess else { return [] }
        guard ekCalendars?.count != 0 else { return [] }
        let predicate = EventData.eventStore.predicateForEvents(withStart: startDate ?? Date().toStart, end: endDate ?? Date().toEnd, calendars: ekCalendars)
        return EventData.eventStore.events(matching: predicate)
    }
    
    static func getEvents(date: Date = Date(), ekCalendars: [EKCalendar]? = nil) -> [EKEvent] {
        return getEvents(startDate: date.toStart, endDate: date.toEnd, ekCalendars: ekCalendars)
    }
    
    static func getEvents(year: Int, month: Int, ekCalendars: [EKCalendar]? = nil) -> [EKEvent] {
        guard let startDate = CalendarDateUtil.calendar.date(from: DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: 0)) else { return [] }
        guard let endDate = CalendarDateUtil.calendar.date(from: DateComponents(year: year, month: month + 1, day: 0, hour: 23, minute: 59, second: 59)) else { return [] }
        return getEvents(startDate: startDate, endDate: endDate, ekCalendars: ekCalendars)
    }
    /*
    static func getEvent(identifier: String) -> EKEvent? {
        return EventData.eventStore.event(withIdentifier: identifier)
    }*/
    
    static func getCalendars() -> [EKCalendar] {
        guard Self.isAllowingAccess else { return [] }
        return EventData.eventStore.calendars(for: .event)
    }
    
    static func getCalendars(isShown: Bool?) -> [EKCalendar] {
        guard Self.isAllowingAccess else { return [] }
        let calendars = EventData.eventStore.calendars(for: .event)
        guard let isShown = isShown else { return calendars }
        guard SwitchableEKCalendar.sync() else { return [] }
        
        if isShown {
            return calendars.filter {
                return SwitchableEKCalendar.checkShown(ekCalendar: $0)
            }
        } else {
            return calendars.filter {
                return !SwitchableEKCalendar.checkShown(ekCalendar: $0)
            }
        }
    }
    
    static func addEvent(ekEvent: EKEvent) -> Bool {
        guard Self.isAllowingAccess else { return false }
        do {
            try EventData.eventStore.save(ekEvent, span: .thisEvent, commit: true)
        } catch  {
            return false
        }
        return true
    }
    
    static func saveEvent(ekEvent: EKEvent, span: EKSpan) -> Bool {
        guard Self.isAllowingAccess else { return false }
        do {
            try EventData.eventStore.save(ekEvent, span: span, commit: true)
        } catch  {
            return false
        }
        return true
    }
    
    static func addCalendar(nameCalendar: String, cgColor: CGColor) -> Bool {
        guard Self.isAllowingAccess else { return false }
        var source: EKSource? = EventData.eventStore.defaultCalendarForNewEvents?.source
        if source == nil {
            source = EventData.eventStore.sources.filter({$0.sourceType.rawValue == 0}).first
        }
        guard source != nil else { return false }
        let calendar = EKCalendar(for: .event, eventStore: EventData.eventStore)
        calendar.title = nameCalendar
        calendar.cgColor = cgColor
        calendar.source = source
        do {
            try EventData.eventStore.saveCalendar(calendar, commit: true)
        } catch {
            return false
        }
        return true
    }
    
    static func calendarBySourceAllows(calendars: [EKCalendar]) -> [EKSourceType : [EKCalendar]] {
        var calendarArray: [EKSourceType : [EKCalendar]] = [:]
        for calendar in calendars {
            if calendar.allowsContentModifications {
                let calendarType = calendar.source.sourceType
                
                if calendarArray.index(forKey: calendarType) == nil {
                    calendarArray.updateValue([calendar], forKey: calendarType)
                } else {
                    calendarArray[calendarType]!.append(calendar)
                }
            }
        }
        
        return calendarArray
    }
    
    static func calendarBySourceAll(calendars: [EKCalendar]) -> [EKSourceType : [EKCalendar]] {
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
    
    static func removeEvent(idEvent: String, span: EKSpan = .thisEvent) -> Bool {
        guard Self.isAllowingAccess else { return false }
        if let event: EKEvent = EventData.eventStore.event(withIdentifier: idEvent) {
            do {
                try EventData.eventStore.remove(event, span: span, commit: true)
            } catch {
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    static func removeEvent(ekEvent: EKEvent, span: EKSpan = .thisEvent) -> Bool {
        guard Self.isAllowingAccess else { return false }
        do {
            try EventData.eventStore.remove(ekEvent, span: span, commit: true)
        } catch {
            return false
        }
        return true
    }
}
