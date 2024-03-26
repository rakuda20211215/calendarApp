//
//  EKCalendarTab.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/03.
//

import SwiftUI
import EventKit
import RealmSwift

struct EKCalendarTab: View {
    @EnvironmentObject private var eventViewController: EventViewController
    @EnvironmentObject private var switchableEKResults: SwitchableEKResults
    @State private var animate: Bool = false
    @State private var isShowingDetail: Bool = false
    let toggleIsShown: (Bool) -> Bool
    
    var body: some View {
        let keys: [EKSource] = switchableEKResults.switchableEKBySource.keys.sorted(by: { $0.sourceType.rawValue < $1.sourceType.rawValue})
        VStack {
            ForEach(keys, id: \.self) { key in
                if let switchableEKs = switchableEKResults.switchableEKBySource[key],
                   !switchableEKs.filter({ toggleIsShown($0.isShown) }).isEmpty {
                    Text("\(key.title)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                    ForEach(switchableEKs, id: \.self) { switchableEK in
                        if let simpleEK = switchableEK.simpleEKCalendar,
                           toggleIsShown(switchableEK.isShown),
                            let cgColor = CGColor.fromFloats(floats: Array(simpleEK.cgColor)) {
                            HStack {
                                HStack {
                                    Circle()
                                        .frame(height: 15)
                                        .foregroundStyle(Color(cgColor: cgColor))
                                        .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 10))
                                    Text("\(simpleEK.title)")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(.black)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isShowingDetail.toggle()
                                }
                                .sheet(isPresented: $isShowingDetail) {
                                    EKCalendarDetail(title: simpleEK.title)
                                }
                                Button {
                                    if RealmController.updateTable(update: { switchableEK.isShown.toggle() }) {
                                        switchableEKResults.animate.toggle()
                                        switchableEKResults.update()
                                        eventViewController.updateShownEKCalendars()
                                    }
                                } label: {
                                    Image(systemName: toggleIsShown(true) ? "eye.slash.circle.fill" : "eye.circle.fill")
                                        .foregroundStyle(toggleIsShown(true) ? .gray.opacity(0.7) : .white.opacity(0.55))
                                        .font(.system(size: 22, weight: .regular))
                                }
                            }
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        }
                    }
                }
            }
        }
        .padding()
        .foregroundStyle(.black.opacity(0.5))
        .frame(maxWidth: .infinity)
        .background(toggleIsShown(true) ? .white.opacity(0.8) : .white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
    }
}
struct EKCalendarDemo: View {
    @EnvironmentObject private var eventViewController: EventViewController
    @EnvironmentObject private var switchableEKResults: SwitchableEKResults
    let toggleIsShown: (Bool) -> Bool
    
    var body: some View {
        VStack {
            Text("IPhone")
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.semibold)
                .font(.system(size: 16))
            VStack {
                HStack {
                    Circle()
                        .frame(height: 15)
                        .foregroundStyle(Color(CGColor(red: 0, green: 0.1, blue: 0.5, alpha: 1)))
                        .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 10))
                    Text("プライベート")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black.opacity(0.75))
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: toggleIsShown(true) ? "eye.slash.circle.fill" : "eye.circle.fill")
                            .foregroundStyle(toggleIsShown(true) ? .gray.opacity(0.7) : .white.opacity(0.6))
                            .font(.system(size: 22, weight: .regular))
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    HStack {
                        Circle()
                            .frame(height: 15)
                            .foregroundStyle(Color(CGColor(red: 0, green: 0.5, blue: 0.1, alpha: 1)))
                            .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 10))
                        Text("スクール　　ｓｓｓｓｓｓｓｓｓｓｓｓｓああああああ")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.black)
                        Spacer()
                        Button {
                        } label: {
                            Image(systemName: toggleIsShown(true) ? "eye.slash.circle.fill" : "eye.circle.fill")
                                .foregroundStyle(toggleIsShown(true) ? .gray.opacity(0.7) : .white.opacity(0.55))
                                .font(.system(size: 22, weight: .regular))
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
        }
        .padding()
        .foregroundStyle(.black.opacity(0.5))
        .frame(maxWidth: .infinity)
        .background(toggleIsShown(true) ? .white.opacity(0.8) : .white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

class SwitchableEKResults: ObservableObject {
    @Published var switchableEKCalendars: [SwitchableEKCalendar] = []
    @Published var animate: Bool = false
    //@ObservedResults(SwitchableEKCalendar.self) var switchableEKCalendars
    
    var switchableEKBySource: [EKSource: [SwitchableEKCalendar]] {
        var switchableEKsDict: [EKSource: [SwitchableEKCalendar]] = [:]
        for switchableEK in switchableEKCalendars {
            guard let source = switchableEK.simpleEKCalendar?.getEKSource() else { continue }
            switchableEKsDict.merge([source: [switchableEK]]) { current, new in Array(Set(current + new)) }
        }
        return switchableEKsDict
    }
    
    init() {
        if  SwitchableEKCalendar.sync(),
            let switchableEKs = RealmController.getTable(type: SwitchableEKCalendar.self) {
            self.switchableEKCalendars = Array(switchableEKs)
        }
    }
    
    func update() {
        if let switchableEKs = RealmController.getTable(type: SwitchableEKCalendar.self) {
            self.switchableEKCalendars = Array(switchableEKs)
        } else {
            self.switchableEKCalendars = []
        }
    }
}

#Preview {
    EKCalendarTab() { _ in
        return true
    }
    .environmentObject(EventViewController(eventStore: EventData.eventStore))
}
