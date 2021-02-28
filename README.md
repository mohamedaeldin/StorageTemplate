# StorageTemplate
Template to generate Storage classes on Xcode.

## Swift Version
Swift 5.0

## About Storage
Storage includes three types as follows:
- `Database` (Realm, Coredata, SQLlite, ..etc).
- `Userdefaults`
- `Keychain`


## Installation
- [Download Storage Template](https://github.com/mohamedaeldin/StorageTemplate/archive/main.zip) or clone the project.
- Copy the `Storage.xctemplate` folder.
- Go to Application folder, browse to the Xcode application icon. Right-click it and choose 'Show Package Contents'. 
- Browse to: Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/Project Templates/iOS/Application
- Paste the `Storage.xctemplate` folder.

## Using the template
- Start Xcode and Create a new file (`File > New > File` or `⌘N`).
- Choose `VIPER`.
- Type in the name of the module you want to create.
- Choose form the drop down list (`Database(Realm)` or `Database(CoreData)` or `Database(SQLlite)`) or `Userdefaults`) or `Keychain`).
- *Not required*: To create Xcode groups, remove the references to the newly created files and add them back to the project

## Created Files
If you choosed from the drop down list:
* **Database**
  *  `StorageDatabaseManager` (Single Interface "High level" You just need to use this manager) 
  *  `StorageRealmDatabaseManager`

* **Userdefaults**
  *  `StorageUserDefaultsManager`
  *  `StorageUserDefaultsManagerKeys`
  
* **Keychain**
  *  `StorageKeychainManager` 
  *  `StorageKeychainManagerKeys`


## Documentation
Will be added soon.

## Contact
[Mohamed Alaa El-Din](https://github.com/mohamedaeldin)
