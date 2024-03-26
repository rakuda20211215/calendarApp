//
//  ContentView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/02.
//
/*
 イベント追加後にsheetがカクツク
 */

import SwiftUI
import RealmSwift
import Foundation
import EventKit

struct ContentView: View {
    @ObservedObject private var eventViewController: EventViewController
    @ObservedObject private var calendarDateUtil: CalendarDateUtil
    init() {
        EventController.requestAccess()
        self.eventViewController = EventViewController(eventStore: EventData.eventStore)
        self.calendarDateUtil = CalendarDateUtil()
    }
    var body: some View {
        CalendarView()
            .environmentObject(eventViewController)
            .environmentObject(calendarDateUtil)
            .environmentObject(CustomColor(foreGround: .black, backGround: .white))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CustomColor(foreGround: .black, backGround: .white))
    }
}
