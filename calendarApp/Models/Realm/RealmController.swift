//
//  RealmController.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/05.
//

import Foundation
import RealmSwift

public protocol RealmControllerProtocol {
    static func getTable<Element: RealmFetchable>(type object: Element.Type) -> Results<Element>?
    static func saveNewTable<Element: Object>(table object: Element) -> Bool
    static func updateTable(update: () -> Void) -> Bool
    static func deleteTable<Element: Object>(table object: Element) -> Bool
}

class RealmController: RealmControllerProtocol {
    static func getTable<Element>(type objectType: Element.Type) -> Results<Element>? where Element : RealmFetchable {
        do {
            let realm = try Realm()
            return realm.objects(objectType)
        } catch {
            print("Failed to get: Realm")
            return nil
        }
    }
    static func saveNewTable<Element>(table object: Element) -> Bool where Element : Object {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
            return true
        } catch {
            print("Failed to save: Realm")
            return false
        }
    }
    static func updateTable(update: () -> Void) -> Bool {
        do {
            let realm = try Realm()
            try realm.write(update)
            return true
        } catch {
            print("Failed to update: Realm")
            return false
        }
    }
    static func deleteTable<Element>(table object: Element) -> Bool where Element : Object {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(object)
            }
            return true
        } catch {
            print("Failed to delete: Realm")
            return false
        }
    }
}

