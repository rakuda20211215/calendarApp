//
//  ObjectSizeComponent.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/11.
//

import Foundation

class EventSizesComponent: ObservableObject {
    let heightWeekChar: CGFloat
    let widthDate: CGFloat
    let heightDate: CGFloat
    let heightRowMonth: CGFloat
    let widthEvent: CGFloat
    var heightEvent: CGFloat
    let heightEventArea: CGFloat
    let heightEventTitle: CGFloat
    let heightEventRectangle: CGFloat
    let widthEventTitle: CGFloat
    let rowEvents: Int
    
    let numWeek = 7
    let numRowMonth = 6
    init(width: CGFloat, height: CGFloat, maxCalendarHeight: CGFloat) {
        heightWeekChar = 20
        widthDate = width /  CGFloat(numWeek)
        heightDate = 13
        heightRowMonth = (height - heightWeekChar) / CGFloat(numRowMonth)
        let maxHeightRowMonth = floor((maxCalendarHeight - heightWeekChar) / CGFloat(numRowMonth))
        widthEvent = widthDate - 2
        rowEvents = Int(maxHeightRowMonth / 19)
        heightEventArea = heightRowMonth - heightDate
        heightEvent = heightEventArea / CGFloat(rowEvents)
        heightEventRectangle = 3
        heightEventTitle = heightEvent - heightEventRectangle - 3
        widthEventTitle = widthDate - 8
    }
}
