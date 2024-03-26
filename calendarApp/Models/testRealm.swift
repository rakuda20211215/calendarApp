//
//  testRealm.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/10/08.
//

import Foundation
import RealmSwift

class userData: Object, ObjectKeyIdentifiable {
    //@Persisted(primaryKey: true) public var id: Int = 0
    @Persisted var name = ""
    convenience init(name: String = "") {
        self.init()
        self.name = name
    }
}

class userData2: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: Int = 0
    @Persisted var name = ""
    convenience init(name: String = "") {
        self.init()
        self.name = name
    }
}

final class modelData: ObservableObject {
    func getter() {
        let realm = try! Realm()
        let shopdata = realm.objects(userData2.self)
        if let aa = shopdata.first {
            print(aa.name)
        }
    }
    
    func saveName(_ str: String) {
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(userData2(name: str))
            }
        } catch {
            print("error")
        }
    }
}
