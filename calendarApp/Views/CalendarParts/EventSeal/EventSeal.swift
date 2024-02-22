//
//  EventSeal.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/06.
//

import SwiftUI
import UIKit
import EventKit

struct EventSeal: View {
    let ekEvent: EKEvent
    let floor: Int
    @Binding var showEvents: Bool
    let objectSizes: ObjectSizesCollection
    let CARRYOVER: Int
    let title: String
    let color: CGColor
    
    init(ekEvent: EKEvent, floor: Int, showEvents: Binding<Bool>, objectSizes: ObjectSizesCollection, CARRYOVER: Int) {
        self.ekEvent = ekEvent
        self.floor = floor
        self._showEvents = showEvents
        self.objectSizes = objectSizes
        self.CARRYOVER = CARRYOVER
        self.title = ekEvent.title == nil ? "no title" : ekEvent.title!
        self.color = ekEvent.calendar.cgColor == nil ? CGColor(gray: 1, alpha: 1) : ekEvent.calendar.cgColor!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !showEvents {
                Text(title)
                    .kerning(0)
                    .font(.system(size: 9,weight: .bold))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: objectSizes.WIDTH_EVENT_TITLE, height: 9, alignment: .top)
                    .clipped()
                    .animation(.easeOut, value: showEvents)
            }
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(color))
                .frame(height: objectSizes.HEIGHT_EVENT_RECTANGLE)
        }
        .frame(width: objectSizes.WIDTH_EVENT * CGFloat(numberOfEventDaysPerWeek[0]), height: objectSizes.HEIGHT_EVENT)
        .padding(EdgeInsets(top: paddingTopLeading.top, leading: paddingTopLeading.leading, bottom: 0, trailing: 0))
    }
    
    var numberOfEventDaysPerWeek: [Int] {
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: ekEvent.startDate)
        let columnIndex = Int((startDay + CARRYOVER - 1) % objectSizes.NUMWEEK)
        let numOfDays = calendar.numberOfDaysBetween(ekEvent.startDate, and: ekEvent.endDate)
        var sum = numOfDays + columnIndex
        var nodList: [Int] = []
        while true {
            if sum - objectSizes.NUMWEEK > 0 {
                nodList.append(objectSizes.NUMWEEK)
                sum = sum - objectSizes.NUMWEEK
            } else {
                nodList.append(sum)
                break
            }
        }
        nodList[0] = nodList[0] - columnIndex
        return nodList
    }
    
    var paddingTopLeading: (top: CGFloat, leading: CGFloat) {
        let startDay = Calendar.current.component(.day, from: ekEvent.startDate)
        let rowIndex = Int((startDay + CARRYOVER - 1) / objectSizes.NUMWEEK)
        let columnIndex = Int((startDay + CARRYOVER - 1) % objectSizes.NUMWEEK)
        
        let topPadding = CGFloat(rowIndex) * (objectSizes.HEIGHT_DATE + objectSizes.HEIGHT_EVENT_AREA) + CGFloat(rowIndex) + objectSizes.HEIGHT_DATE + ((showEvents ? objectSizes.HEIGHT_EVENT_RECTANGLE + 5 : objectSizes.HEIGHT_EVENT) * CGFloat(floor))
        let leadingPadding = CGFloat(columnIndex) * (objectSizes.WIDTH_DATE) + ((objectSizes.WIDTH_DATE - objectSizes.WIDTH_EVENT) / 2)
        
        return (top: topPadding, leading: leadingPadding)
    }
}
