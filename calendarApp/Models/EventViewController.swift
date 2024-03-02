//
//  EventViewController.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/02/25.
//

import Foundation
import EventKit

class EventViewController: ObservableObject {
    @Published var selectedDayEvents: [EKEvent]? = nil
    @Published var selectedEventDate: Date? = nil
    @Published var showEvents: Bool = false
    
    let eventController: EventControllerClass
    
    init(eventStore: EKEventStore) {
        eventController = EventControllerClass(eventStore: eventStore)
    }
    
    func updateSelectedDayEvents() {
        guard let eventDate = selectedEventDate else { return }
            print("update")
            let ekEvents = eventController.getEvents(date: eventDate)
            if !ekEvents.isEmpty {
                selectedDayEvents = ekEvents
            } else {
                selectedDayEvents = nil
                selectedEventDate = nil
            }
    }
    
    func updateSelectedDayEvents(date: Date) {
        let ekEvents = eventController.getEvents(date: date)
        if !ekEvents.isEmpty {
            selectedEventDate = date
            selectedDayEvents = ekEvents
        } else {
            selectedEventDate = nil
            selectedDayEvents = nil
        }
    }
    
    func toggleShowEvents() {
        if selectedDayEvents != nil {
            showEvents.toggle()
        } else {
            showEvents = false
        }
    }
    
    func toggleShowEvents(_ isShow: Bool) {
        if selectedDayEvents != nil {
            showEvents = isShow
        } else {
            showEvents = false
        }
    }
}
