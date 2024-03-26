//
//  EventViewController.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/02/25.
//

import Foundation
import EventKit

class EventViewController: ObservableObject {
    @Published var shownEKCalendar: [EKCalendar]
    @Published var selectedDayEvents: [EKEvent]? = nil
    @Published var selectedEventDate: Date? = nil
    @Published var showEvents: Bool = false
    
    init(eventStore: EKEventStore) {
        self.shownEKCalendar = EventController.getCalendars(isShown: true)
    }
    
    func updateShownEKCalendars() {
        shownEKCalendar = EventController.getCalendars(isShown: true)
    }
    
    func updateSelectedDayEvents() {
        guard let eventDate = selectedEventDate else { return }
            let ekEvents = EventController.getEvents(date: eventDate)
            if !ekEvents.isEmpty {
                selectedDayEvents = ekEvents
            } else {
                selectedDayEvents = nil
                selectedEventDate = nil
            }
    }
    
    func updateSelectedDayEvents(date: Date) {
        let ekEvents = EventController.getEvents(date: date)
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
