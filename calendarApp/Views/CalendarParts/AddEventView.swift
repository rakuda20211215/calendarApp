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
    @EnvironmentObject private var customColor: CustomColor
    private var eventData: EventData = EventData()
    
    var body: some View {
        // ここから
        // NavigationStackとtoolvar ついか
        
        NavigationStack {
            EditEventView()
                .environmentObject(eventData)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar() {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            eventData.initializeObj()
                            dismiss()
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
                            if eventData.ekEvent.title.count > 0 {
                                eventData.ekEvent.isAllDay = eventData.isAllDay
                                let _ = eventData.eventController.addEvent(ekEvent: eventData.ekEvent)
                                eventData.initializeObj()
                                dismiss()
                            }
                        } label: {
                            Text("追加")
                                .foregroundStyle(eventData.ekEvent.title.count > 0 ? customColor.complete : customColor.invalid)
                        }
                    }
                }
        }
    }
}


struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
            .environmentObject(CustomColor(foreGround: .black, backGround: .white))
    }
}
