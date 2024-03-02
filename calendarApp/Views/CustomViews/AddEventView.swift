//
//  AddEventView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/13.
//

import SwiftUI
import EventKit

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var eventViewController: EventViewController
    //@EnvironmentObject private var eventData: EventData
    @EnvironmentObject private var customColor: CustomColor
    //@EnvironmentObject private var eventStoreManager: EventStoreManager
    private var eventData: EventData = EventData()
    
    @State private var isActiveAdd: Bool = false
    @Binding private var isShowAddView: Bool
    
    init(_ isShowAddView: Binding<Bool>) {
        self._isShowAddView = isShowAddView
    }
    
    var body: some View {
        NavigationStack {
            EditEventView(isActiveAdd: $isActiveAdd)
                .environmentObject(eventData)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar() {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            eventData.initializeEvent()
                            isShowAddView.toggle()
                        } label: {
                            Text("キャンセル")
                                .foregroundStyle(customColor.cancel)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                            Text("新規イベント")
                            .foregroundStyle(customColor.foreGround)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if isActiveAdd {
                                Task {
                                    await addEventAsync()
                                    isShowAddView.toggle()
                                    //eventData.initializeEvent()
                                }
                            }
                        } label: {
                            Text("追加")
                                .foregroundStyle(isActiveAdd ? customColor.complete : customColor.invalid)
                        }
                    }
                }
       }
    }
    
    func addEventAsync() async {
        eventData.ekEvent.isAllDay = eventData.isAllDay
        eventData.ekEvent.calendar = eventData.currentCalendar
        let _ = eventData.eventController.addEvent(ekEvent: eventData.ekEvent)
        //eventViewController.updateSelectedDayEvents()
    }
}

