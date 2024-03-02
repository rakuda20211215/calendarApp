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
    @EnvironmentObject var objectSizes: ObjectSizes
    @EnvironmentObject var infoMonth: InfoMonth
    
    @Binding var showEvents: Bool
    //let objectSizes: ObjectSizesCollection
    let ekEvent: EKEvent
    let step: Int
    
    init(showEvents: Binding<Bool>, ekEvent: EKEvent, step: Int) {
        self._showEvents = showEvents
        self.ekEvent = ekEvent
        self.step = step
    }
    
    var eventRangeInCalendar: ClosedRange<Int> {
        var startIndex = 0
        var endIndex = 0
        
        for (index, date) in zip(infoMonth.rangeMonth.indices, infoMonth.rangeMonth) {
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
        let startIndex = eventRangeInCalendar.lowerBound
        let columnIndex = (startIndex) % 7
        let numOfDays = (eventRangeInCalendar.upperBound - eventRangeInCalendar.lowerBound) + 1
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
                let startIndex = eventRangeInCalendar.lowerBound
                let rowIndex = Int(startIndex / objectSizes.NUMWEEK) + index
                let columnIndex = index > 0 ? 0 : startIndex % objectSizes.NUMWEEK
                
                let topPadding = CGFloat(rowIndex) * (objectSizes.HEIGHT_DATE + objectSizes.HEIGHT_EVENT_AREA) + objectSizes.HEIGHT_DATE + ((showEvents ? objectSizes.HEIGHT_EVENT_RECTANGLE + 5 : objectSizes.HEIGHT_EVENT) * CGFloat(step))
                let leadingPadding = CGFloat(columnIndex) * (objectSizes.WIDTH_DATE) + ((objectSizes.WIDTH_DATE - objectSizes.WIDTH_EVENT) / 2)
                
                return (top: topPadding, leading: leadingPadding)
            }
            VStack(spacing: 0) {
                if !showEvents {
                    Text(ekEvent.title)
                        .kerning(0)
                        .font(.system(size: 9,weight: .bold))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: objectSizes.WIDTH_EVENT_TITLE, height: 9, alignment: .top)
                        .clipped()
                        .animation(.easeOut, value: showEvents)
                }
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(ekEvent.calendar.cgColor))
                    .frame(height: objectSizes.HEIGHT_EVENT_RECTANGLE)
            }
            .frame(width: objectSizes.WIDTH_DATE * CGFloat(numDayPerWeek) - 2, height: objectSizes.HEIGHT_EVENT)
            .padding(EdgeInsets(top: paddingTopLeading.top, leading: paddingTopLeading.leading, bottom: 0, trailing: 0))
        }
    }
}
