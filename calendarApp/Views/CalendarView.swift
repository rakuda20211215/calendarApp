//
//  CalendarView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/13.
//

import SwiftUI
import RealmSwift
import Foundation
import EventKit

struct CalendarView: View {
    @EnvironmentObject private var customColor: CustomColor
    @ObservedObject private var eventData: EventData = EventData()
    @ObservedObject private var dateObj: DateObject = DateObject()
    @State private var selection: Int = 0
    
    private var selectedDateEvents: [EKEvent]? {
        if let eventDate = eventData.selectedEventDate {
            let ekEvents = eventData.eventController.getEvents(date: eventDate)
            return !ekEvents.isEmpty ? ekEvents : nil
        } else {
            return nil
        }
    }
    
    // イベント追加画面
    @State private var showAddEventView: Bool = false
    
    var dateFormatterDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        if let date = eventData.selectedEventDate,
           (dateObj.getYear(date) != dateObj.getYear()
            || dateObj.getYear(date) != dateObj.yearView) {
            formatter.dateFormat = "yyyy年M月d日(EEEEE)"
        } else {
            formatter.dateFormat = "M月d日(EEEEE)"
        }
        return formatter
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let CONTENT_HEIGHT = height - 45
            let CALENDAR_WIDTH = width - 8
            var CALENDAR_EVENT_HEIGHT: CGFloat {
                if !eventData.showEvents {
                    return CONTENT_HEIGHT
                } else {
                    return CONTENT_HEIGHT / 2
                }
            }
            let padding: CGFloat = 5
            
            ZStack {
                customColor.homeBack.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    // トップバー
                    HStack {
                        Text("\(dateObj.yearView.description)年\(dateObj.monthView)月")
                            .foregroundColor(customColor.backGround)
                            .font(.system(size: 20, weight: .bold))
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        Spacer()
                        
                        Button{
                            withAnimation(.easeInOut) {
                                dateObj.yearView = dateObj.getYear()
                                dateObj.monthView = dateObj.getMonth()
                                selection = 0
                            }
                        } label: {
                            Image(systemName: "v.square.fill")
                                .foregroundColor(customColor.backGround)
                                .font(.system(size: 20))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                        
                        Button{
                            showAddEventView.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(customColor.backGround)
                                .font(.system(size: 20, weight: .bold))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                        .sheet(isPresented: $showAddEventView) {
                            AddEventView()
                            //.environmentObject(eventData)
                        }
                        
                        Button{
                            //kari -----
                            eventData.selectedEventDate = nil
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(customColor.backGround)
                                .font(.system(size: 20, weight: .bold))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                    }
                    
                    //
                    // カレンダー と　イベント
                    VStack {
                        // カレンダー
                        VStack(spacing: 0) {
                            TabView(selection: $selection) {
                                MonthCalendar(YEAR: dateObj.yearView, MONTH: dateObj.monthView - 1, eventData: eventData, selectedEventDate: $eventData.selectedEventDate, showEvents: $eventData.showEvents)
                                    .frame(width: CALENDAR_WIDTH)
                                    .tag(-1)
                                
                                MonthCalendar(YEAR: dateObj.yearView, MONTH: dateObj.monthView, eventData: eventData, selectedEventDate: $eventData.selectedEventDate, showEvents: $eventData.showEvents)
                                    .frame(width: CALENDAR_WIDTH)
                                    .onDisappear() {
                                        
                                        if selection != 0 {
                                            dateObj.updateDateObj(selection: selection)
                                            selection = 0
                                        }
                                    }
                                    .tag(0)
                                
                                MonthCalendar(YEAR: dateObj.yearView, MONTH: dateObj.monthView + 1, eventData: eventData, selectedEventDate: $eventData.selectedEventDate, showEvents: $eventData.showEvents)
                                    .frame(width: CALENDAR_WIDTH)
                                    .tag(1)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                        .frame(height: CALENDAR_EVENT_HEIGHT - padding)
                        .animation(.easeOut, value: eventData.showEvents)
                        
                        Spacer()
                        // イベント
                        if eventData.showEvents,
                           let ekEvents = selectedDateEvents {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text(dateFormatterDate.string(from: eventData.selectedEventDate!))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(customColor.backGround)
                                    Spacer()
                                    Button {
                                        eventData.showEvents.toggle()
                                    } label: {
                                        Image(systemName: "triangle.fill")
                                            .resizable()
                                            .rotation3DEffect(
                                                .degrees(180),axis: (x: 1.0, y: 0.0, z: 0.0)
                                            )
                                            .foregroundStyle(customColor.backGround)
                                            .frame(width: 10, height: 10)
                                            .padding(5)
                                    }
                                }
                                .padding(15)
                                .frame(width: width * 0.95, height: 30)
                                .background(.black.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                /*
                                 .overlay {
                                 RoundedRectangle(cornerRadius: 15)
                                 .stroke(.white, lineWidth: 1)
                                 }
                                 */
                                
                                EventList(ekEvents, target: eventData.selectedEventDate!)
                                    .foregroundStyle(customColor.backGround)
                                    .environmentObject(eventData)
                            }
                            .frame(height: CALENDAR_EVENT_HEIGHT - padding)
                            .zIndex(-1)
                            .animation(.easeOut, value: eventData.showEvents)
                        }
                        
                    }
                    .frame(height: CONTENT_HEIGHT)
                    
                    Spacer()
                }
            }
        }
    }
}

enum dateElements {
    case year
    case month
    case week
    case day
    case hour
    case minute
}

class DateObject: ObservableObject {
    var year: Int
    var month: Int
    @Published var yearView: Int
    @Published var monthView: Int
    @Published var viewDate: Date
    var rangeMonth: [Int] = Array<Int>(-2...2)
    let calendar: Calendar
    
    init(viewDate: Date = Date()) {
        self.viewDate = viewDate
        self.year = Calendar.current.component(.year, from: viewDate)
        self.month = Calendar.current.component(.month, from: viewDate)
        self.yearView = year
        self.monthView = month
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? calendar.timeZone
        calendar.locale = Locale(identifier: "ja_JP")
        self.calendar = calendar
    }
    
    func initializObj(date: Date) {
        self.viewDate = date
        self.rangeMonth = Array<Int>(-2...2)
        self.year = Calendar.current.component(.year, from: date)
        self.month = Calendar.current.component(.month, from: date)
        self.yearView = year
        self.monthView = month
    }
    
    func updateDateObj(selection: Int) {
        if selection < 0 {
            self.monthView -= 1
            if self.monthView < 1 {
                self.monthView = 12
                self.yearView -= 1
            }
        } else {
            self.monthView += 1
            if self.monthView > 12 {
                self.monthView = 1
                self.yearView += 1
            }
        }
    }
    
    func getYear(_ date: Date = Date()) -> Int {
        calendar.component(.year, from: date)
    }
    func getMonth(_ date: Date = Date()) -> Int {
        calendar.component(.month, from: date)
    }
    func getDay(_ date: Date = Date()) -> Int {
        calendar.component(.day, from: date)
    }
    func getHour(_ date: Date = Date()) -> Int {
        calendar.component(.hour, from: date)
    }
    func getMinute(_ date: Date = Date()) -> Int {
        calendar.component(.minute, from: date)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(CustomColor(foreGround: .black, backGround: .white))
            .environmentObject(EventData())
    }
}
