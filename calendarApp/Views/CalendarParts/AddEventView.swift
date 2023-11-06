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
                            dismiss()
                        } label: {
                            Text("キャンセル")
                        }
                    }
                    ToolbarItem(placement: .principal) {
                            Text("新規イベント")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            print(eventData.ekEvent)
                            let _ = eventData.eventController.addEvent(ekEvent: eventData.ekEvent)
                            dismiss()
                        } label: {
                            Text("追加")
                        }
                    }
                }
        }
    }
}


struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
