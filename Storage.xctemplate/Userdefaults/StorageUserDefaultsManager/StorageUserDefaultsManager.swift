import Foundation

typealias StorageUserdefaultsCompletionHandler = ((Bool) -> Void)?
typealias StorageCodableType = Codable

private protocol StorageUserdefaultsProtocol {
    func save(value: Any?, forKey key: String, completion: StorageUserdefaultsCompletionHandler)
    func save<T: StorageCodableType>(objects: [T], forKey key: String, completion: StorageUserdefaultsCompletionHandler)
    func save<T: StorageCodableType>(object: T, forKey key: String, completion: StorageUserdefaultsCompletionHandler)

    func get(valueForKey key: String) -> Any?
    func get<T: StorageCodableType>(objectForKey key: String, type: T.Type) -> T?
    func get<T: StorageCodableType>(objectsForKey key: String, type: T.Type) -> [T]?

    func delete(valueForKey key: String, completion: StorageUserdefaultsCompletionHandler)
    func wipeStorage(completion _: StorageUserdefaultsCompletionHandler)
}

class StorageUserDefaultsManager: NSObject, StorageUserdefaultsProtocol {
    // MARK: - Variables

    static let shared = StorageUserDefaultsManager()
    private var currentDefaults: UserDefaults!

    // MARK: - Init

    override init() {
        currentDefaults = UserDefaults.standard
    }

    // MARK: - Save Functions

    func save(value: Any?, forKey key: String, completion: StorageUserdefaultsCompletionHandler) {
        guard let value = value else {
            completion?(false)
            return
        }
        currentDefaults.set(value, forKey: key)
        currentDefaults.synchronize()
        completion?(true)
    }

    func save<T: StorageCodableType>(object: T, forKey key: String, completion: StorageUserdefaultsCompletionHandler) {
        do {
            let data = try JSONEncoder().encode(object)
            currentDefaults.set(data, forKey: key)
            completion?(true)
        } catch {
            completion?(false)
        }
    }

    func save<T: StorageCodableType>(objects: [T], forKey key: String, completion: StorageUserdefaultsCompletionHandler) {
        do {
            let data = try JSONEncoder().encode(objects)
            currentDefaults.set(data, forKey: key)
            completion?(true)
        } catch {
            completion?(false)
        }
    }

    // MARK: - Get Functions

    func get(valueForKey key: String) -> Any? {
        currentDefaults.object(forKey: key)
    }

    func get<T: StorageCodableType>(objectForKey key: String, type: T.Type) -> T? {
        guard let data = currentDefaults.data(forKey: key) else {
            return nil
        }
        let object = try? JSONDecoder().decode(type.self, from: data)
        return object
    }

    func get<T: StorageCodableType>(objectsForKey key: String, type: T.Type) -> [T]? {
        guard let data = currentDefaults.data(forKey: key) else {
            return nil
        }
        let object = try? JSONDecoder().decode(type.self, from: data)
        return object as? [T]
    }

    // MARK: - Delete Functions

    func delete(valueForKey key: String, completion: StorageUserdefaultsCompletionHandler) {
        currentDefaults.removeObject(forKey: key)
        completion?(true)
    }

    func wipeStorage(completion: StorageUserdefaultsCompletionHandler) {
        for key in currentDefaults.dictionaryRepresentation().keys {
            currentDefaults.removeObject(forKey: key.description)
        }
        completion?(true)
    }
}
