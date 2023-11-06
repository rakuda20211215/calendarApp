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
    let realm = try! Realm()
    @ObservedObject private var shoptable: modelData
    @State private var name: String
    @State private var ekEventDate: String = ""
    @State private var ekEventCalendar: String = ""
    @ObservedObject private var dateObj: DateObjectForMonthEvents = DateObjectForMonthEvents()
    @ObservedObject private var eventController: EventControllerClass = EventControllerClass()
    @State private var selection: Int = 0
    @State private var rangeMonth: [Int] = Array<Int>(-2...2)
    let padding: CGFloat = 5
    
    // イベント追加画面
    @State private var isAddEventView: Bool = false
    // イベント一覧
    
    init() {
        Task {
            await EventControllerClass().requestAccess()
        }
        self.shoptable = modelData()
        self.name = ""
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let CALENDAR_WIDTH = width - 8
            let CALENDAR_HEIGHT = height - 45
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    // トップバー
                    HStack {
                        Text("\(dateObj.yearView.description)年\(dateObj.monthView)月")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        Spacer()
                        
                        Button{
                            
                        } label: {
                            Image(systemName: "v.square.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                        
                        Button{
                            isAddEventView.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                        .sheet(isPresented: $isAddEventView) {
                            
                        } content: {
                            AddEventView()
                        }
                        
                        Button{
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                    }
                    
                    // カレンダーの日付にtapgestureを追加
                    // カレンダー と　イベント
                    VStack {
                        // カレンダー
                        VStack(spacing: 0) {
                            TabView(selection: $selection) {
                                MonthCalendar(eventController: dateObj.eventController, YEAR: dateObj.yearView, MONTH: dateObj.monthView - 1)
                                    .background(.white)
                                    .frame(width: CALENDAR_WIDTH)
                                    //.frame(width: CALENDAR_WIDTH, height: CALENDAR_HEIGHT)
                                    .cornerRadius(5)
                                    .tag(-1)
                                
                                MonthCalendar(eventController: dateObj.eventController, YEAR: dateObj.yearView, MONTH: dateObj.monthView)
                                    .background(.white)
                                    .frame(width: CALENDAR_WIDTH)
                                    //.frame(width: CALENDAR_WIDTH, height: CALENDAR_HEIGHT / 2)
                                    .cornerRadius(5)
                                    .onDisappear() {
                                        
                                        if selection != 0 {
                                            dateObj.updateDateObj(selection: selection)
                                            selection = 0
                                        }
                                    }
                                    .tag(0)
                                
                                MonthCalendar(eventController: dateObj.eventController, YEAR: dateObj.yearView, MONTH: dateObj.monthView + 1)
                                    .background(.white)
                                    .frame(width: CALENDAR_WIDTH)
                                    //.frame(width: CALENDAR_WIDTH, height: CALENDAR_HEIGHT)
                                    .cornerRadius(5)
                                    .tag(1)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                        .frame(height: CALENDAR_HEIGHT / 2 - padding)
                        
                        Spacer()
                        // イベント
                        VStack(spacing: 0) {
                            EventList([createEvent(day: 1), createEvent(day: 2), createEvent(day: 3), createEvent(day: 4),createEvent(day: 5), createEvent(day: 6), createEvent(day: 7), createEvent(day: 8)], target: Date())
                                .foregroundStyle(.white)
                        }
                        .frame(height: CALENDAR_HEIGHT / 2 - padding)
                    }
                    .frame(height: CALENDAR_HEIGHT)
                    
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
    var rangeMonth: [Int] = Array<Int>(-5...5)
    @Published var selection: Int? = 0
    //@Published var scrollID: Int?
    var oldSelection: Int = 0
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
        self.rangeMonth = Array<Int>(-5...5)
        self.selection = 0
        self.oldSelection = 0
        self.year = Calendar.current.component(.year, from: date)
        self.month = Calendar.current.component(.month, from: date)
        self.yearView = year
        self.monthView = month
    }
    
    func updateDateObj() -> Void {
        if self.selection! > self.oldSelection {
            if (rangeMonth.count - 1) - rangeMonth.firstIndex(of: selection!)! < 3 {
                self.rangeMonth.append(self.rangeMonth[self.rangeMonth.count - 1] + 1)
            }
            self.monthView += 1
            if self.monthView > 12 {
                self.monthView = 1
                self.yearView += 1
            }
        } else if self.selection! < self.oldSelection {
            if rangeMonth.firstIndex(of: selection!)! < 3 {
                self.rangeMonth.insert(self.rangeMonth[0] - 1, at: 0)
            }
            self.monthView -= 1
            if self.monthView < 1 {
                self.monthView = 12
                self.yearView -= 1
            }
            
        }
        self.oldSelection = self.selection!
        
        return
    }
    
    func getYear(_ date: Date = Date()) -> Int {
        Calendar.current.component(.year, from: date)
    }
    func getMonth(_ date: Date = Date()) -> Int {
        Calendar.current.component(.month, from: date)
    }
    func getDay(_ date: Date = Date()) -> Int {
        Calendar.current.component(.day, from: date)
    }
    func getHour(_ date: Date = Date()) -> Int {
        Calendar.current.component(.hour, from: date)
    }
    func getMinute(_ date: Date = Date()) -> Int {
        Calendar.current.component(.minute, from: date)
    }
}
class DateObjectForMonthEvents: DateObject {
    let eventController: EventControllerClass = EventControllerClass()
    
    /*
     override func updateDateObj() {
     if self.selection! > self.oldSelection {
     self.rangeMonth.append(self.rangeMonth[self.rangeMonth.count - 1] + 1)
     self.rangeMonth.remove(at: 0)
     self.monthView += 1
     if self.monthView > 12 {
     self.monthView = 1
     self.yearView += 1
     }
     } else if self.selection! < self.oldSelection {
     self.rangeMonth.insert(self.rangeMonth[0] - 1, at: 0)
     self.rangeMonth.remove(at: self.rangeMonth.count - 1)
     
     self.monthView -= 1
     if self.monthView < 1 {
     self.monthView = 12
     self.yearView -= 1
     }
     }
     print(rangeMonth)
     self.oldSelection = self.selection!
     
     return
     }
     */
    
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
    
    func updateDateObj(_ rM: [Int], selection: Int) -> [Int] {
        print("\(selection):\(self.oldSelection)")
        var rangeMonth = rM
        if selection > self.oldSelection {
            rangeMonth.append(rangeMonth[rangeMonth.count - 1] + 1)
            //rangeMonth.remove(at: 0)
            
            self.monthView += 1
            if self.monthView > 12 {
                self.monthView = 1
                self.yearView += 1
            }
        } else if selection < self.oldSelection {
            rangeMonth.insert(rangeMonth[0] - 1, at: 0)
            //rangeMonth.remove(at: rangeMonth.count - 1)
            
            self.monthView -= 1
            if self.monthView < 1 {
                self.monthView = 12
                self.yearView -= 1
            }
        }
        print(rangeMonth)
        self.oldSelection = selection
        
        return rangeMonth
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
