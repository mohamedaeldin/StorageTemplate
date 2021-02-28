import Foundation

struct StorageUserDefaultsManagerKeys {
    enum GlobalKeys {
        static let lastConnectionTime = "lastConnectionTime"
        static let versionOfLastRun = "VersionOfLastRun"
        static let currentVersion = "currentVersion"
        static let isUserDimissCoachMarkView = "isUserDimissCoachMarkView"
        static let shouldContactSupportHighlight = "shouldContactSupportHighlight"
    }

    enum LoginKeys {
        static let token = "token"
        static let refreshToken = "refreshToken"
        static let refreshTokenExpirationDate = "refreshTokenExpirationDate"
    }
}
