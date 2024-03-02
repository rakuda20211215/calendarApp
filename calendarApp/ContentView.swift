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
    @ObservedObject private var eventViewController: EventViewController = EventViewController(eventStore: EventData.eventStore)
    @ObservedObject private var calendarDateComp: CalendarDateComponent = CalendarDateComponent()
    var body: some View {
        CalendarView()
            .environmentObject(eventViewController)
            .environmentObject(calendarDateComp)
            .environmentObject(CustomColor(foreGround: .black, backGround: .white))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CustomColor(foreGround: .black, backGround: .white))
    }
}
