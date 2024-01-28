//
//  RemoveView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/01/28.
//

import SwiftUI
import EventKit

struct RemoveView: View {
    @EnvironmentObject var customColor: CustomColor
    @EnvironmentObject var eventData: EventData
    var ekEvent: EKEvent
    @Binding var showInfo: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack {
                VStack(spacing: 5){
                    HStack {
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .frame(width: 22, height: 17)
                            .fontWeight(.bold)
                        Spacer()
                        Text("このイベント")
                            .font(.system(size: 17))
                        Spacer()
                    }
                    .frame(width: width / 1.5, height: 25, alignment: .center)
                    .padding(10)
                    .background(.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(5)
                    .onTapGesture {
                        showInfo.toggle()
                        let isDelete = eventData.eventController.removeEvent(ekEvent: ekEvent, span: .thisEvent)
                        if isDelete {
                            //成否のメッセージ
                            
                            eventData.selectedEventDate = eventData.selectedEventDate
                            if let eventDate = eventData.selectedEventDate {
                                let selectedDatesEvent = eventData.eventController.getEvents(date: eventDate)
                                if selectedDatesEvent.count == 0 {
                                    eventData.showEvents.toggle()
                                }
                            }
                        }
                        
                    }
                    if ekEvent.hasRecurrenceRules {
                        HStack {
                            Image("tab_close")
                                .resizable()
                                .frame(width: 22, height: 18)
                                .fontWeight(.light)
                            Spacer()
                            Text("これ以降すべて")
                                .font(.system(size: 17))
                            Spacer()
                        }
                        .frame(width: width / 1.5, height: 20, alignment: .center)
                        .padding(10)
                        .background(.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(5)
                        .onTapGesture {
                            showInfo.toggle()
                            eventData.eventController.removeEvent(ekEvent: ekEvent, span: .futureEvents)
                        }
                    }
                }
                .foregroundStyle(customColor.foreGround)
            }
            .frame(width: width)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showInfo.toggle()
                    } label: {
                        Image(systemName: "multiply")
                            .foregroundStyle(customColor.foreGround)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("消去")
                        .foregroundStyle(customColor.foreGround)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
