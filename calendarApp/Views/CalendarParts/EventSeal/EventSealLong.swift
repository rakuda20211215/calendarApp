//
//  EventSealLong.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/02/13.
//

import SwiftUI
import EventKit

struct EventSealLong: View {
    @EnvironmentObject private var customColor: CustomColor
    let ekEvent: EKEvent
    //let eventController: EventControllerClass
    var isAllDayStart: Bool = false
    var isAllDayend:   Bool = false
    var startTime: String
    var endTime:   String
    
    let period: dateElements
    
    @State private var infoSelection: infoElements?
    @State private var showInfo: Bool = false
    
    @State private var showEventSheet: Bool = false
    
    @State private var isValidURL: Bool = false
    
    init(_ ekEvent: EKEvent, date: Date? = Date(), period: dateElements = .day) {
        self.ekEvent = ekEvent
        
        self.period = period
        
        let dateObj: DateObject = DateObject()
        
        let startDay: Int = dateObj.getDay(ekEvent.startDate)
        let endDay:   Int = dateObj.getDay(ekEvent.endDate)
        
        switch period {
        case .year:
            self.startTime = "\(dateObj.getMonth(ekEvent.startDate)) / \(startDay)"
            self.endTime   = "\(dateObj.getMonth(ekEvent.endDate)) / \(endDay)"
        case .month:
            self.startTime = "\(startDay)"
            self.endTime   = "\(endDay)"
        default:
            // 終日チェック
            let day: Int = dateObj.getDay(date!)
            
            if startDay == day {
                startTime = "\(dateObj.getHour(ekEvent.startDate)):\(String(format: "%02d", (dateObj.getMinute(ekEvent.startDate))))"
                
                if 0 == dateObj.getHour(ekEvent.startDate)
                    && 0 == dateObj.getMinute(ekEvent.startDate) {
                    isAllDayStart = true
                } else {
                    isAllDayStart = false
                }
            } else {
                startTime = ""
                isAllDayStart = true
            }
            
            if endDay == day {
                endTime = "\(dateObj.getHour(ekEvent.endDate)):\(String(format: "%02d", (dateObj.getMinute(ekEvent.endDate))))"
                
                if 23 == dateObj.getHour(ekEvent.endDate)
                    && 59 == dateObj.getMinute(ekEvent.endDate) {
                    isAllDayend = true
                } else {
                    isAllDayend = false
                }
            } else {
                endTime = ""
                isAllDayend = true
            }
        }
    }
    
    
    
    var body: some View {
        GeometryReader { geometry in
            let width: CGFloat  = geometry.size.width
            let height: CGFloat = geometry.size.height
            let padding: CGFloat = 10
            let rectangleWidth: CGFloat = 13
            let triangleSize: CGFloat = 8
            let timeWidth: CGFloat = 60
            let locationSize: CGFloat = 10
            let infoCircleSize: CGFloat = 16
            let titleWidth: CGFloat = width - rectangleWidth - timeWidth - infoCircleSize - (padding * 2)
            let titleHeight: CGFloat = height - padding
            let centerSpace: CGFloat = height * 0.05
            HStack(spacing: 0) {
                // カレンダー色の図形
                /*
                 RoundedRectangle(cornerRadius: width, style: .circular)
                 .fill(Color(ekEvent.calendar.cgColor))
                 .frame(width: rectangleWidth)
                 */
                EventSealLongRectangle(isAllDayStart: isAllDayStart, isAllDayEnd: isAllDayend, color: Color(ekEvent.calendar.cgColor))
                    .frame(width: rectangleWidth)
                HStack {
                    // 日付
                    VStack( alignment: .trailing, spacing: 0) {
                        switch period {
                        case .year:
                            if startTime == endTime {
                                Text("\(startTime)")
                            } else {
                                Text("\(startTime)")
                                Text("\(endTime)")
                            }
                        case .month:
                            if startTime == endTime {
                                Text("\(startTime)")
                            } else {
                                HStack {
                                    Text("\(startTime)")
                                    Image(systemName: "triangle.fill")
                                        .resizable()
                                        .frame(width: triangleSize, height: triangleSize)
                                        .rotationEffect(Angle(degrees: 90))
                                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                    Text("\(endTime)")
                                }
                            }
                        default:
                            if isAllDayStart && isAllDayend {
                                Text("終日")
                            } else {
                                Spacer()
                                Text(startTime)
                                Text(endTime)
                                Spacer()
                            }
                        }
                    }
                    .font(.system(size: 13))
                    .frame(width: timeWidth)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        // 場所
                        if let location = ekEvent.location {
                            HStack {
                                Image("location_on")
                                    .resizable()
                                    .frame(width: locationSize * 0.8, height: locationSize)
                                    .foregroundColor(.blue)
                                Text("\(location)")
                                    .font(.system(size: 13))
                            }
                        } else {
                            Text("")
                                .font(.system(size: 13))
                        }
                        Spacer()
                            .frame(height: centerSpace)
                        // タイトル
                        Text("\(ekEvent.title)")
                            .font(.system(size: 17, weight: .bold))
                        Spacer()
                    }
                    .frame(width: titleWidth, height: titleHeight, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showEventSheet.toggle()
                    }
                }
                
                Menu {
                    if ekEvent.location != nil {
                        Button {
                            infoSelection = .location
                            showInfo.toggle()
                        } label: {
                            Label(infoElements.location.rawValue, systemImage: "map")
                        }
                    }
                    if isValidURL {
                        Button {
                            infoSelection = .url
                            showInfo.toggle()
                        } label: {
                            Label(infoElements.url.rawValue, systemImage: "network")
                        }
                    }
                    Divider()
                    Button {
                        infoSelection = .copy
                    } label: {
                        Label(infoElements.copy.rawValue, image: "calendar_add")
                    }
                    Button(role: .destructive) {
                        infoSelection = .remove
                        showInfo.toggle()
                    } label: {
                        Label(infoElements.remove.rawValue, systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .renderingMode(.original)
                        .foregroundStyle(customColor.backGround)
                        .frame(width: infoCircleSize, height: infoCircleSize)
                        .padding(padding)
                }
                .menuOrder(.fixed)
                .onAppear {
                    checkURL(url: ekEvent.url)
                }
                
                Spacer()
            }
            .lineLimit(1)
            .sheet(isPresented: $showEventSheet) {
                Text("\(ekEvent)")
                    .foregroundStyle(customColor.foreGround)
            }
            .sheet(isPresented: $showInfo) {
                BrowsOrRemoveOrMap(ekEvent: ekEvent, showInfo: $showInfo, infoSelection: $infoSelection)
            }
        }
    }
    
    func checkURL(url: URL?) {
        if let url = url {
            let task = URLSession.shared.dataTask(with: url) { _, response, error in
                guard error == nil else { return }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else { return }
                self.isValidURL = true
            }
            task.resume()
        }
    }
    
    struct BrowsOrRemoveOrMap: View {
        @EnvironmentObject private var customColor: CustomColor
        var ekEvent: EKEvent
        
        @Binding var showInfo: Bool
        @Binding var infoSelection: infoElements?
        
        init(ekEvent: EKEvent, showInfo: Binding<Bool>, infoSelection: Binding<infoElements?>) {
            self.ekEvent = ekEvent
            self._showInfo = showInfo
            self._infoSelection = infoSelection
        }
        var body: some View {
            NavigationStack {
                switch infoSelection {
                case .location:
                    MapView(address: ekEvent.location!, showInfo: $showInfo)
                case .url:
                    WebViewCustom(url: ekEvent.url!, showInfo: $showInfo)
                case .remove:
                    RemoveView(ekEvent: ekEvent, showInfo: $showInfo)
                default:
                    Text("")
                        .onAppear {
                            showInfo = false
                        }
                }
            }
            .presentationDetents(infoSelection == .remove  ? [.height(ekEvent.hasRecurrenceRules ? 170 : 120)]: [.large])
            .presentationBackground(.thinMaterial)
        }
    }
    
    enum infoElements: String, CaseIterable {
        case copy = "イベントを複製"
        case location = "マップを表示"
        case url = "ブラウザを表示"
        case remove = "消去"
    }
}

struct EventSealLongRectangle: View {
    let parameters: EventSealLongParameters
    let isAllDayStart: Bool
    let isAllDayend: Bool
    let color: Color
    
    init(isAllDayStart: Bool, isAllDayEnd: Bool, color: Color) {
        self.parameters = EventSealLongParameters(start: isAllDayStart, end: isAllDayEnd)
        self.isAllDayStart = isAllDayStart
        self.isAllDayend = isAllDayEnd
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width: CGFloat = geometry.size.width
            Path { path in
                path.move(
                    to: CGPoint(
                        x: width * parameters.Segments[1].curve.x,
                        y: width * parameters.Segments[1].curve.y))
                parameters.Segments.forEach { segment in
                    let isStart: Bool = segment.line.x != 0
                    path.addLine(
                        to: CGPoint(x: width * segment.line.x,
                                    y: width * segment.line.y))
                    if (isStart && isAllDayStart) || (!isStart && isAllDayend) {
                        path.addLine(
                            to: CGPoint(x: width * segment.curve.x,
                                        y: width * segment.curve.y))
                    } else {
                        path.addArc(center: CGPoint(x: width * segment.controll.x,
                                                    y: width * segment.controll.y),
                                    radius: width / 2.0,
                                    startAngle: Angle(degrees: isStart ? 0 : 180),
                                    endAngle: Angle(degrees: isStart ? 180 : 360),
                                    clockwise: true)
                    }
                }
            }
            .fill(color)
        }
    }
}
struct EventSealLongParameters {
    struct Segment {
        let line: CGPoint
        let curve: CGPoint
        let controll: CGPoint
    }
    
    let Segments: [Segment]
    
    init(start: Bool, end: Bool) {
        let width: CGFloat = 1
        let height: CGFloat = 3.5
        let center: CGFloat = width / 2.0
        let topY: CGFloat = start ? 0 : center
        let bottomY: CGFloat = end ? height : height - center
        Segments = [
            Segment(
                line: CGPoint(x: width, y: topY),
                curve: CGPoint(x: 0, y: topY),
                controll: CGPoint(x: center, y: center)),
            Segment(
                line: CGPoint(x: 0, y: bottomY),
                curve: CGPoint(x: width, y: bottomY),
                controll: CGPoint(x: center, y: height - center))
        ]
    }
}
