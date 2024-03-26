//
//  EventSeal.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/06.
//

import SwiftUI
import UIKit
import EventKit

struct EventSealShortPdding: View {
    @EnvironmentObject private var objectSizes: EventSizesComponent
    @Binding var showEvents: Bool
    //let objectSizes: ObjectSizesCollection
    let ekEvent: EKEvent
    let step: Int
    let datesInMonth: [Date]
    
    init(showEvents: Binding<Bool>, ekEvent: EKEvent, step: Int, datesInMonth: [Date]) {
        self._showEvents = showEvents
        self.ekEvent = ekEvent
        self.step = step
        self.datesInMonth = datesInMonth
    }
    
    var eventRangeCalendar: ClosedRange<Int> {
        var startIndex = 0
        var endIndex = 0
        
        for (index, date) in zip(datesInMonth.indices, datesInMonth) {
            if date <= ekEvent.startDate {
                startIndex = index
            }
            
            if date <= ekEvent.endDate {
                endIndex = index
            } else {
                break
            }
        }
        return startIndex...endIndex
    }
    
    var numberOfEventDaysPerWeeks: [Int] {
        let startIndex = eventRangeCalendar.lowerBound
        let columnIndex = (startIndex) % 7
        let numOfDays = (eventRangeCalendar.upperBound - eventRangeCalendar.lowerBound) + 1
        var sum = numOfDays + columnIndex
        var nodList: [Int] = []
        while true {
            if sum - 7 > 0 {
                nodList.append(7)
                sum = sum - 7
            } else {
                nodList.append(sum)
                break
            }
        }
        nodList[0] = nodList[0] - columnIndex
        return nodList
    }
    
    var body: some View {
        ForEach(0..<numberOfEventDaysPerWeeks.count, id: \.self) { index in
            let numDayPerWeek = numberOfEventDaysPerWeeks[index]
            var paddingTopLeading: (top: CGFloat, leading: CGFloat) {
                let startIndex = eventRangeCalendar.lowerBound
                let rowIndex = Int(startIndex / objectSizes.numWeek) + index
                let columnIndex = index > 0 ? 0 : startIndex % objectSizes.numWeek
                
                let topPadding = CGFloat(rowIndex) * (objectSizes.heightDate + objectSizes.heightEventArea) + objectSizes.heightDate + ((showEvents ? objectSizes.heightEventRectangle + 5 : objectSizes.heightEvent) * CGFloat(step))
                let leadingPadding = CGFloat(columnIndex) * (objectSizes.widthDate) + ((objectSizes.widthDate - objectSizes.widthEvent) / 2)
                
                return (top: topPadding, leading: leadingPadding)
            }
            VStack(spacing: 0) {
                if !showEvents {
                    Text(ekEvent.title)
                        .kerning(0)
                        .font(.system(size: objectSizes.heightEventTitle, weight: .semibold, design: .monospaced))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: objectSizes.widthDate * CGFloat(numDayPerWeek) - 5, height: objectSizes.heightEventTitle, alignment: .top)
                        //.frame(height: )
                        .padding(EdgeInsets(top: 0, leading: 2, bottom: 2, trailing: 2))
                        .clipped()
                        .animation(.easeOut, value: showEvents)
                }
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(ekEvent.calendar.cgColor))
                    .frame(height: objectSizes.heightEventRectangle)
            }
            .frame(width: objectSizes.widthDate * CGFloat(numDayPerWeek) - 2, height: objectSizes.heightEvent)
            .padding(EdgeInsets(top: paddingTopLeading.top, leading: paddingTopLeading.leading, bottom: 0, trailing: 0))
        }
    }
}

struct EventSeal: View {
    @EnvironmentObject private var objectSizes: EventSizesComponent
    @Binding var showEvents: Bool
    let title: String
    var body: some View {
        Text(title)
            .kerning(0)
            .font(.system(size: objectSizes.heightEventTitle, weight: .semibold, design: .monospaced))
            .foregroundColor(.black)
            .fixedSize(horizontal: false, vertical: true)
            //.frame(width: objectSizes.widthDate * CGFloat(numDayPerWeek) - 5, height: objectSizes.heightEventTitle, alignment: .top)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
            .clipped()
            .animation(.easeOut, value: showEvents)
        RoundedRectangle(cornerRadius: 2)
            //.fill(Color(ekEvent.calendar.cgColor))
            .frame(height: objectSizes.heightEventRectangle)
    }
}
