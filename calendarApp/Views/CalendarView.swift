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
    @ObservedObject private var dateObj: DateObject = DateObject()
    
    init() {
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
                Color.red.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(dateObj.yearView)年\(dateObj.monthView)月")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    TabView(selection: $dateObj.selection) {
                        ForEach(dateObj.rangeMonth, id: \.self) { month in
                            MonthCalendar(YEAR: dateObj.year, MONTH: dateObj.month + month)
                                .background(.white)
                                .frame(width: CALENDAR_WIDTH, height: CALENDAR_HEIGHT)
                                .cornerRadius(5)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onReceive(dateObj.$selection) { _ in
                        dateObj.updateDateObj()
                    }
                    Spacer()
                }
            }
        }
    }
    
    
    /*
     var body: some View {
     var ekEvents: [EKEvent] = ekEventController.getEvents()
     VStack {
     TextField("text", text: $name)
     Button(action: {
     // レコードの生成
     let shop = userData()
     shop.name = name
     
     // 保存
     try! realm.write {
     realm.add(shop)
     }
     
     }, label: {
     Text("追加")
     })
     
     Text(shoptable.shopdata[shoptable.shopdata.count-1].name)
     
     Button {
     shoptable.setter()
     
     ekEvents = ekEventController.getEvents(startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!)
     ekEventDate = ekEvents.isEmpty ? "empty" : ekEvents[0].description
     ekEventCalendar = ekEventController.getCalendars().isEmpty ? "empty" : ekEventController.getCalendars().description
     } label: {
     Text("更新")
     }
     
     Button {
     var calendar: EKCalendar = ekEventController.getCalendars()[0]
     _ = ekEventController.addEvent(calendar: calendar, title: name, startDate: Date(), endDate: Date(), isAllDay: false, timeZone: TimeZone.current)
     } label: {
     Text("イベント追加")
     }
     
     Button {
     _ = ekEventController.addCalendar(nameCalendar: name)
     } label: {
     Text("カレンダー追加")
     }
     
     Spacer()
     
     ScrollView {
     Text(ekEventDate)
     Text(ekEventCalendar)
     Text(ekEventController.checkAccess().description)
     }
     }
     .padding()
     }
     
     func getRealmData() -> String {
     let realm = try! Realm()
     
     return realm.objects(userData.self).description
     }*/
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
    
    
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
