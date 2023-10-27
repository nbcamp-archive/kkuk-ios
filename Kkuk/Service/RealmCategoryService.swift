//
//  RealmCategoryService.swift
//  Kkuk
//
//  Created by 장가겸 on 10/26/23.
//

import RealmSwift
import UIKit

protocol Storage {
    func write<T: Object>(_ object: T)
    func delete<T: Object>(_ object: T)
    func sort<T: Object>(_ object: T.Type, by keyPath: String, ascending: Bool) -> Results<T>
}

final class RealmCategoryManager: Storage {
    static let shared = RealmCategoryManager()

    private let database: Realm

    private init() {
        do {
            self.database = try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error)")
        }
    }

    func getLocationOfDefaultRealm() {
        print("Realm is located at:", database.configuration.fileURL!)
    }

    func read() -> [Category] {
        let result = database.objects(Category.self)
        let array: [Category] = Array(result)
        return array
    }

    func write<T: Object>(_ object: T) {
        do {
            try database.write {
                database.add(object, update: .modified)
            }

        } catch {
            print(error)
        }
    }

    func update<T: Object>(_ object: T, completion: @escaping ((T) -> Void)) {
        do {
            try database.write {
                completion(object)
            }
        } catch {
            print(error)
        }
    }

    func delete<T: Object>(_ object: T) {
        do {
            try database.write {
                database.delete(object)
                print("Delete Success")
            }

        } catch {
            print(error)
        }
    }

    func sort<T: Object>(_ object: T.Type, by keyPath: String, ascending: Bool = true) -> Results<T> {
        return database.objects(object).sorted(byKeyPath: keyPath, ascending: ascending)
    }
}