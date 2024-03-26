//
//  SwitchableEKCalendar.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/05.
//

import Foundation
import RealmSwift
import EventKit
/*
 次回: 下記のオブジェクトを使ってDBを操作する
 */

class SwitchableEKCalendar: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var simpleEKCalendar: SimpleEKCalendar?
    @Persisted var isShown: Bool = true
    
    convenience init(ekCalendar: EKCalendar) {
        self.init()
        guard let cgColor = ekCalendar.cgColor.componentsFloat else { return }
        self.simpleEKCalendar = SimpleEKCalendar(title: ekCalendar.title, cgColor: cgColor, sourceIdentifier: ekCalendar.source.sourceIdentifier)
    }
    
    static func sync() -> Bool {
        let ekCalendars = EventController.getCalendars()
        guard let switchableEKCalendars = RealmController.getTable(type: SwitchableEKCalendar.self) else { return false }
        // 消去
        for switchEK in switchableEKCalendars {
            if ekCalendars.map({ SimpleEKCalendar.makeSimple($0) }).contains(switchEK.simpleEKCalendar) { continue }
            guard RealmController.deleteTable(table: switchEK) else { return false }
        }
        // 追加
        for ekCalendar in ekCalendars {
            let simpleEK = SimpleEKCalendar.makeSimple(ekCalendar)
            if switchableEKCalendars.map({ $0.simpleEKCalendar }).contains(simpleEK) { continue }
            guard RealmController.saveNewTable(table: SwitchableEKCalendar(ekCalendar: ekCalendar)) else { return false }
        }
        return true
    }
    
    static func checkShown(ekCalendar: EKCalendar) -> Bool {
        guard let switchEKs = RealmController.getTable(type: SwitchableEKCalendar.self) else { return false }
        for switchEK in switchEKs {
            if switchEK.simpleEKCalendar == SimpleEKCalendar.makeSimple(ekCalendar) {
                return switchEK.isShown
            }
        }
        return false
    }
}

class SimpleEKCalendar: Object {
    @objc dynamic var title: String = ""
    dynamic  var cgColor: List<Float> = List<Float>()
    @objc private dynamic var sourceIdentifier: String = ""
    
    convenience init(title: String, cgColor: [Float], sourceIdentifier: String) {
        self.init()
        self.title = title
        self.cgColor.append(objectsIn: cgColor)
        self.sourceIdentifier = sourceIdentifier
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let target = object as? SimpleEKCalendar else { return false }
        let selfColors = self.cgColor
        let tarColors = target.cgColor
        guard self.title == target.title && selfColors.count == tarColors.count && self.sourceIdentifier == target.sourceIdentifier else { return false }
        for index in 0..<selfColors.count {
            guard selfColors[index] == tarColors[index] else { return false }
        }
        return true
    }
    
    func getEKSource() -> EKSource? {
        return EventData.eventStore.sources.first(where: { $0.sourceIdentifier == self.sourceIdentifier })
    }
    
    static func makeSimple(_ ekCalendar: EKCalendar) -> SimpleEKCalendar? {
        guard let cgColor = ekCalendar.cgColor.componentsFloat else { return nil }
        return SimpleEKCalendar(title: ekCalendar.title, cgColor: cgColor, sourceIdentifier: ekCalendar.source.sourceIdentifier)
    }
}
