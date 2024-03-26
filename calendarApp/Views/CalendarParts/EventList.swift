//
//  EventList.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/11/05.
//

import SwiftUI
import EventKit
import CoreGraphics
import MapKit

struct EventList: View {
    let ekEvents: [EKEvent]
    let startDate: Date
    let endDate: Date
    let targetDate: Date?
    
    let isOverMonth: Bool
    
    init(_ ekEvents: [EKEvent], start: Date, end: Date) {
        self.startDate = start
        self.endDate = end
        self.targetDate = nil
        
        if CalendarDateUtil.getMonth(start) != CalendarDateUtil.getMonth(end) {
            isOverMonth = true
        } else {
            isOverMonth = false
        }
        self.ekEvents = ekEvents
            .filter({!(start > $0.endDate || $0.startDate > end)})
            .sorted(by: {$0.startDate < $1.startDate})
    }
    
    init(_ ekEvents: [EKEvent], target: Date) {
        self.targetDate = target
        
        let startDateComp = DateComponents(calendar: CalendarDateUtil.calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"), year: CalendarDateUtil.getYear(target), month: CalendarDateUtil.getMonth(target), day: CalendarDateUtil.getDay(target), hour: 0, minute: 0, second: 0)
        let start = CalendarDateUtil.calendar.date(from: startDateComp)!
        self.startDate = start
        
        let endDateComp = DateComponents(calendar: CalendarDateUtil.calendar, timeZone: TimeZone(identifier: "Asia/Tokyo"), year: CalendarDateUtil.getYear(target), month: CalendarDateUtil.getMonth(target), day: CalendarDateUtil.getDay(target), hour: 23, minute: 59, second: 59)
        let end = CalendarDateUtil.calendar.date(from: endDateComp)!
        self.endDate = end
        
        self.ekEvents = ekEvents
            .filter({!(start > $0.endDate || $0.startDate > end)})
            .sorted(by: {$0.startDate < $1.startDate})
        
        isOverMonth = false
    }
    
    var body: some View {
        let eventSealLong: CGFloat = 45
        GeometryReader { geometry in
            let width = geometry.size.width
            ScrollView {
                LazyVStack(alignment: .center) {
                    ForEach(ekEvents, id: \.self) { ekEvent in
                        if let date = targetDate {
                            EventSealLong(ekEvent, date: date, period: .day)
                                .frame(width: width * 0.9, height: eventSealLong)
                        } else {
                            if isOverMonth {
                                EventSealLong(ekEvent, period: .year)
                                    .frame(width: width * 0.9, height: eventSealLong)
                            } else {
                                EventSealLong(ekEvent, period: .month)
                                    .frame(width: width * 0.9, height: eventSealLong)
                            }
                        }
                    }
                }
                .frame(width: width, alignment: .center)
                .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

#Preview {
    EventList([createEvent(date: Date())], target: Date())
        .environmentObject(CustomColor(foreGround: .black, backGround: .white))
}
