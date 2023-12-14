import Foundation
import Models

public struct GatewayClient {
    public var registerUser: @Sendable (String, String) async throws -> User

    public var getUser: @Sendable () async throws -> User
    public var getChills: @Sendable () async throws -> [Chill]
    public var getAchievements: @Sendable () async throws -> [Achievement]
    public var getUserAchievements: @Sendable () async throws -> [Achievement]

    public var startChill: @Sendable (Date, Double, Double) async throws -> Chill
    public var endChill: @Sendable (String, [TracePoint], [Photo], Date) async throws -> Chill

    public init(
        registerUser: @escaping @Sendable (String, String) async throws -> User,
        getUser: @escaping @Sendable () async throws -> User,
        getChills: @escaping @Sendable () async throws -> [Chill],
        getAchievements: @escaping @Sendable () async throws -> [Achievement],
        getUserAchievements: @escaping @Sendable () async throws -> [Achievement],
        startChill: @escaping @Sendable (Date, Double, Double) async throws -> Chill,
        endChill: @escaping @Sendable (String, [TracePoint], [Photo], Date) async throws -> Chill
    ) {
        self.registerUser = registerUser
        self.getUser = getUser
        self.getChills = getChills
        self.getAchievements = getAchievements
        self.getUserAchievements = getUserAchievements
        self.startChill = startChill
        self.endChill = endChill
    }
}
