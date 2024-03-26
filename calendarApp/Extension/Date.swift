//
//  Date.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/10.
//

import Foundation

extension Date {
    var toStart: Date {
        let calendar = CalendarDateUtil.calendar
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? self
    }
    
    var toEnd: Date {
        let calendar = CalendarDateUtil.calendar
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return calendar.date(from: components) ?? self
    }
}
