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
    @EnvironmentObject private var eventViewController: EventViewController
    @EnvironmentObject private var calendarDateComp: CalendarDateUtil
    //@EnvironmentObject private var eventStoreManager: EventStoreManager
    //@ObservedObject private var eventViewController: EventViewController = EventViewController(eventStore: EventData.eventStore)
    //@ObservedObject private var eventData: EventData = EventData()
    @State private var selection: Int = 0
    
    // イベント追加画面
    @State private var showAddEventView: Bool = false
    // メニュー画面
    @State private var showMenuView: Bool = false
    
    var dateFormatterDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        if let date = eventViewController.selectedEventDate,
           (CalendarDateUtil.getYear(date) != CalendarDateUtil.getYear()
            || CalendarDateUtil.getYear(date) != calendarDateComp.yearView) {
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
                if !eventViewController.showEvents {
                    return CONTENT_HEIGHT
                } else {
                    return CONTENT_HEIGHT / 2
                }
            }
            let padding: CGFloat = 5
            NavigationStack {
                ZStack {
                    customColor.homeBack.ignoresSafeArea()
                    VStack(alignment: .leading, spacing: 0) {
                        // トップバー
                        HStack {
                            Text("\(calendarDateComp.yearView.description)年\(calendarDateComp.monthView)月")
                                .foregroundColor(customColor.backGround)
                                .font(.system(size: 20, weight: .bold))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                            Spacer()
                            
                            Button{
                                withAnimation(.easeInOut) {
                                    calendarDateComp.yearView = CalendarDateUtil.getYear()
                                    calendarDateComp.monthView = CalendarDateUtil.getMonth()
                                    selection = 0
                                }                                
                            } label: {
                                Text("\(CalendarDateUtil.getMonth())")
                                    .font(.system(size: 16))
                                    .fontWeight(.heavy)
                                    .frame(width: 27, height: 20)
                                    .foregroundColor(customColor.homeBack)
                                    .background(customColor.backGround)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
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
                                AddEventView($showAddEventView)
                                //.environmentObject(eventViewController)
                                //.environmentObject(eventStoreManager)
                            }
                            /*
                            Button{
                                //kari -----
                                if let gUrl = URL(string: "comgooglemaps://"),
                                   UIApplication.shared.canOpenURL(gUrl) {
                                    UIApplication.shared.open(gUrl)
                                }
                                
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(customColor.backGround)
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                            }*/
                            
                            NavigationLink {
                                MenuView()
                                    .background(customColor.homeBack)
                                    .foregroundStyle(.white)
                            } label: {
                                    Image(systemName: "line.3.horizontal")
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
                                    MonthCalendar(year: calendarDateComp.yearView, MONTH: calendarDateComp.monthView - 1, contentHeight: CONTENT_HEIGHT - padding)
                                        .frame(width: CALENDAR_WIDTH)
                                        .tag(-2)
                                    
                                    MonthCalendar(year: calendarDateComp.yearView, MONTH: calendarDateComp.monthView - 1, contentHeight: CONTENT_HEIGHT - padding)
                                        .frame(width: CALENDAR_WIDTH)
                                        .tag(-1)
                                    
                                    MonthCalendar(year: calendarDateComp.yearView, MONTH: calendarDateComp.monthView, contentHeight: CONTENT_HEIGHT - padding)
                                        .frame(width: CALENDAR_WIDTH)
                                        .onDisappear() {
                                            if selection != 0 {
                                                calendarDateComp.updateDateObj(selection: selection)
                                                selection = 0
                                            }
                                        }
                                        .tag(0)
                                    
                                    MonthCalendar(year: calendarDateComp.yearView, MONTH: calendarDateComp.monthView + 1, contentHeight: CONTENT_HEIGHT - padding)
                                        .frame(width: CALENDAR_WIDTH)
                                        .tag(1)
                                    
                                    MonthCalendar(year: calendarDateComp.yearView, MONTH: calendarDateComp.monthView + 1, contentHeight: CONTENT_HEIGHT - padding)
                                        .frame(width: CALENDAR_WIDTH)
                                        .tag(2)
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                            }
                            .frame(height: CALENDAR_EVENT_HEIGHT - padding)
                            .animation(.easeOut, value: eventViewController.showEvents)
                            
                            Spacer()
                            // イベント
                            if eventViewController.showEvents,
                               let selectedDate = eventViewController.selectedEventDate {
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        Text(dateFormatterDate.string(from: selectedDate))
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(customColor.backGround)
                                        Spacer()
                                        Button {
                                            eventViewController.toggleShowEvents()
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
                                    
                                    EventList(EventController.getEvents(date: selectedDate, ekCalendars: EventController.getCalendars(isShown: true)), target: selectedDate)
                                    //.environmentObject(eventViewController)
                                        .foregroundStyle(customColor.backGround)
                                    //.environmentObject(eventStoreManager)
                                        .onAppear {
                                            eventViewController.updateSelectedDayEvents()
                                        }
                                }
                                .frame(height: CALENDAR_EVENT_HEIGHT - padding)
                                .zIndex(-1)
                                //.animation(.easeOut, value: eventViewController.showEvents)
                            }
                            
                        }
                        .frame(height: CONTENT_HEIGHT)
                        
                        Spacer()
                    }
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


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(EventViewController(eventStore: EventData.eventStore))
            .environmentObject(CalendarDateUtil())
            .environmentObject(CustomColor(foreGround: .black, backGround: .white))
    }
}
