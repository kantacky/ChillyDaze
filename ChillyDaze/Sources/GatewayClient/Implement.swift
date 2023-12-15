import Foundation
import Gateway
import Models

enum Implement {
    static func registerUser(name: String, avatar: String) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.perform(mutation: RegisterUserMutation(name: name, avatar: avatar)) { result in
                switch result {
                case .success(let data):
                    guard let gatewayUser = data.data?.registerUser else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    let user = User.fromGateway(user: gatewayUser)
                    continuation.resume(returning: user)
                    return

                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    static func getUser() async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.fetch(query: UserQuery()) { result in
                switch result {
                case .success(let data):
                    guard let gatewayUser = data.data?.user else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    let user = User.fromGateway(user: gatewayUser)
                    continuation.resume(returning: user)
                    return

                case .failure(let error):
                    print(error.localizedDescription)
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    static func getChills() async throws -> [Chill] {
        try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.fetch(query: ChillsQuery()) { result in
                switch result {
                case .success(let data):
                    guard let gatewayChills = data.data?.user.chills else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    do {
                        let chills = try gatewayChills.map { try Chill.fromGateway(chill: $0) }
                        continuation.resume(returning: chills)
                    } catch {
                        continuation.resume(throwing: error)
                        return
                    }
                    return

                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    static func getAchievements() async throws -> [Achievement] {
        try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.fetch(query: AchievementsQuery()) { result in
                switch result {
                case .success(let data):
                    guard let gatewayAchievements = data.data?.achievements else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    let achievements = gatewayAchievements.map {
                        Achievement.fromGateway(achievement: $0)
                    }
                    continuation.resume(returning: achievements)
                    return

                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    static func getUserAchievements() async throws -> [Achievement] {
        try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.fetch(query: UserAchievementsQuery()) { result in
                switch result {
                case .success(let data):
                    guard let gatewayAchievements = data.data?.user.achievements else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    let achievements = gatewayAchievements.map {
                        Achievement.fromGateway(achievement: $0)
                    }
                    continuation.resume(returning: achievements)
                    return

                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    static func getAchievementCategories() async throws -> [AchievementCategory] {
        try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.fetch(query: AchievementCategoriesQuery()) { result in
                switch result {
                case .success(let data):
                    guard let gatewayAchievementCategories = data.data?.achievementCategories else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    let achieventCategories = gatewayAchievementCategories.map {
                        AchievementCategory.fromGateway(category: $0)
                    }
                    continuation.resume(returning: achieventCategories)
                    return

                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    static func startChill(
        timestamp: Date,
        latitude: Double,
        longitude: Double
    ) async throws -> Chill {
        try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.perform(
                mutation: StartChillMutation(
                    timestamp: Formatter.iso8601.string(from: timestamp),
                    latitude: latitude,
                    longitude: longitude
                )
            ) { result in
                switch result {
                case .success(let data):
                    guard let gatewayChill = data.data?.startChill else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    do {
                        let chill = try Chill.fromGateway(chill: gatewayChill)
                        continuation.resume(returning: chill)
                    } catch {
                        continuation.resume(throwing: error)
                        return
                    }
                    return

                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    static func endChill(
        id: String,
        tracePoints: [TracePoint],
        photos: [Photo],
        timestamp: Date
    ) async throws -> Chill {
        try await withCheckedThrowingContinuation { continuation in
            let tracePointInputs: [TracePointInput] = tracePoints.map {
                .init(
                    timestamp: Formatter.iso8601.string(from: $0.timestamp),
                    coordinate: .init(
                        latitude: $0.coordinate.latitude,
                        longitude: $0.coordinate.longitude
                    )
                )
            }

            let photoInputs: [PhotoInput] = photos.map {
                .init(
                    url: $0.url.absoluteString,
                    timestamp: Formatter.iso8601.string(
                        from: $0.timestamp
                    )
                )
            }

            Network.shared.apollo.perform(
                mutation: EndChillMutation(
                    id: id,
                    tracePoints: tracePointInputs,
                    photos: photoInputs,
                    timestamp: Formatter.iso8601.string(from: timestamp)
                )
            ) { result in
                switch result {
                case .success(let data):
                    guard let gatewayChill = data.data?.endChill else {
                        continuation.resume(throwing: GatewayClientError.failedToFetchData)
                        return
                    }

                    do {
                        let chill = try Chill.fromGateway(chill: gatewayChill)
                        continuation.resume(returning: chill)
                    } catch {
                        continuation.resume(throwing: error)
                        return
                    }
                    return

                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
}
