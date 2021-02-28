import Foundation
import RealmSwift

typealias StorageDatabaseCompletionHandler = ((Bool) -> Void)?
typealias StorageDatabaseBlockHandler = (() -> Void)?
typealias StorageDatabaseType = Object

private protocol StorageDatabaseProtocol {
    func save(objects: [StorageDatabaseType], completion: StorageDatabaseCompletionHandler)
    func save(object: StorageDatabaseType, completion: StorageDatabaseCompletionHandler)

    func replace(block: StorageDatabaseBlockHandler, completion: StorageDatabaseCompletionHandler)
    func replace(objects type: StorageDatabaseType.Type, withObjects objects: [StorageDatabaseType], completion: StorageDatabaseCompletionHandler)
    func replace(object type: StorageDatabaseType.Type, withObject object: StorageDatabaseType, completion: StorageDatabaseCompletionHandler)

    func get(objects type: StorageDatabaseType.Type) -> [StorageDatabaseType]?
    func get(object type: StorageDatabaseType.Type) -> StorageDatabaseType?
    func get(objectsWithQuery type: StorageDatabaseType.Type, predicate: NSPredicate) -> [StorageDatabaseType]?

    func delete(objects type: StorageDatabaseType.Type, completion: StorageDatabaseCompletionHandler)
    func delete(object type: StorageDatabaseType.Type, completion: StorageDatabaseCompletionHandler)
    func delete(objects: [StorageDatabaseType], completion: StorageDatabaseCompletionHandler)
    func delete(object: StorageDatabaseType, completion: StorageDatabaseCompletionHandler)

    func migrateStorage()
    func wipeStorage(completion _: StorageDatabaseCompletionHandler)
}

class StorageRealmDatabaseManager: NSObject, StorageDatabaseProtocol {
    // MARK: - Variables

    static let shared = StorageRealmDatabaseManager()
    private var sharedRealm: Realm!
    var realmVersion: UInt64!

    // MARK: - Init

    override init() {
        super.init()
        createRealmInstance()
        realmVersion = UInt64(40)
    }

    func createRealmInstance() {
        if sharedRealm == nil {
            do {
                sharedRealm = try Realm()
            } catch {
                print("can't creat realm object")
            }
        }
    }

    // MARK: - Save Functions

    func save(object: StorageDatabaseType, completion: StorageDatabaseCompletionHandler) {
        guard let realm = sharedRealm else {
            completion?(false)
            return
        }
        do {
            try realm.safeWrite {
                realm.add(object)
                completion?(true)
            }
        } catch {
            completion?(false)
        }
    }

    func save(objects: [StorageDatabaseType], completion: StorageDatabaseCompletionHandler) {
        guard let realm = sharedRealm else {
            completion?(false)
            return
        }
        do {
            try realm.safeWrite {
                realm.add(objects)
                completion?(true)
            }
        } catch {
            completion?(false)
        }
    }

    // MARK: - Replace Functions

    func replace(objects type: StorageDatabaseType.Type, withObjects objects: [StorageDatabaseType], completion: StorageDatabaseCompletionHandler) {
        if get(objects: type) == nil {
            self.save(objects: objects, completion: completion)
            return
        }

        delete(objects: type) { success in
            if success {
                self.save(objects: objects, completion: completion)
            } else {
                completion?(false)
            }
        }
    }

    func replace(object type: StorageDatabaseType.Type, withObject object: StorageDatabaseType, completion: StorageDatabaseCompletionHandler) {
        if get(object: type) == nil {
            self.save(object: object, completion: completion)
            return
        }

        delete(object: type) { success in
            if success {
                self.save(object: object, completion: completion)
            } else {
                completion?(false)
            }
        }
    }

    func replace(block: StorageDatabaseBlockHandler, completion: StorageDatabaseCompletionHandler) {
        guard let realm = sharedRealm, let block = block else {
            completion?(false)
            return
        }
        do {
            try realm.safeWrite(block)
            completion?(true)
        } catch {
            completion?(false)
        }
    }

    // MARK: - Get Functions

    func get(objects type: StorageDatabaseType.Type) -> [StorageDatabaseType]? {
        guard let realm = sharedRealm else {
            return nil
        }

        var objects = [Object]()
        for result: Object in realm.objects(type) {
            objects.append(result)
        }
        if objects.count > 0 {
            return objects
        }
        return nil
    }

    func get(object type: StorageDatabaseType.Type) -> StorageDatabaseType? {
        guard let realm = sharedRealm else {
            return nil
        }

        var storageObject: Object?
        for result: Object in realm.objects(type) {
            storageObject = Object()
            storageObject = result
            break
        }
        return storageObject
    }

    func get(objectsWithQuery type: StorageDatabaseType.Type, predicate: NSPredicate) -> [StorageDatabaseType]? {
        guard let realm = sharedRealm else {
            return nil
        }

        realm.refresh()
        let result: Results<Object> = realm.objects(type).filter(predicate)
        var objects = [Object]()
        for object: Object in result {
            objects.append(object)
        }
        if objects.count > 0 {
            return objects
        }
        return nil
    }

    // MARK: - Delete Functions

    func delete(objects type: StorageDatabaseType.Type, completion: StorageDatabaseCompletionHandler) {
        guard let realm = sharedRealm, let objects = get(objects: type) else {
            completion?(false)
            return
        }

        do {
            try realm.safeWrite {
                realm.delete(objects)
                completion?(true)
            }
        } catch {
            completion?(false)
        }
    }

    func delete(object type: StorageDatabaseType.Type, completion: StorageDatabaseCompletionHandler) {
        guard let realm = sharedRealm, let object = get(object: type) else {
            completion?(false)
            return
        }

        do {
            try realm.safeWrite {
                realm.delete(object)
                completion?(true)
            }
        } catch {
            completion?(false)
        }
    }

    func delete(objects: [StorageDatabaseType], completion: StorageDatabaseCompletionHandler) {
        guard let realm = sharedRealm else {
            completion?(false)
            return
        }
        do {
            try realm.safeWrite {
                realm.delete(objects)
                completion?(true)
            }
        } catch {
            completion?(false)
        }
    }

    func delete(object: StorageDatabaseType, completion: StorageDatabaseCompletionHandler) {
        guard let realm = sharedRealm else {
            completion?(false)
            return
        }
        do {
            try realm.safeWrite {
                realm.delete(object)
                completion?(true)
            }
        } catch {
            completion?(false)
        }
    }

    func wipeStorage(completion: StorageDatabaseCompletionHandler) {
        let realm: Realm? = try? Realm()
        do {
            try realm?.safeWrite {
                realm?.deleteAll()
                completion?(true)
            }
        } catch {
            completion?(false)
        }
    }

    // MARK: - Migratation Functions

    func migrateStorage() {
        Realm.Configuration.defaultConfiguration.schemaVersion = realmVersion
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        self.createRealmInstance()
    }
}

extension Realm {
    func safeWrite(_ block: () throws -> Void) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
