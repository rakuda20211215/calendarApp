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
        //CalendarView()
        //AddEventView()
          //  .environmentObject(EventData())
        RecurrencePicker()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
