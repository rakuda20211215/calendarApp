//
//  ContentView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/02.
//

import SwiftUI
import RealmSwift
import Foundation
import EventKit

struct ContentView: View {
    var body: some View {
        CalendarView()
        /*
        let year = DateObject().getYear(Date())
        let month = DateObject().getMonth(Date())
        let startDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: 2))!
        let endDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: 8))!
        EventList([createEvent(day: -2), createEvent(day: 2), createEvent(day: 3), createEvent(day: 4),createEvent(day: 5), createEvent(day: 6), createEvent(day: 7), createEvent(day: 8)], start: startDate, end: endDate)
         */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
