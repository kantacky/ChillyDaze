import Foundation
import Gateway

public struct Photo: Identifiable, Equatable {
    public let id: String
    public let timestamp: Date
    public let url: String

    public init(
        id: String,
        timestamp: Date,
        url: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.url = url
    }
}

public extension Photo {
    static func fromGateway(photo: Gateway.ChillsQuery.Data.User.Chill.Photo?) throws -> Self? {
        guard let photo = photo else { return nil }
        guard let timestamp = Formatter.iso8601.date(from: photo.timestamp) else {
            throw ModelsError.invalidDateStringFormat
        }

        return .init(
            id: photo.id,
            timestamp: timestamp,
            url: photo.url
        )
    }

    static func fromGateway(photo: EndChillMutation.Data.EndChill.Photo?) throws -> Self? {
        guard let photo = photo else { return nil }
        guard let timestamp = Formatter.iso8601.date(from: photo.timestamp) else {
            throw ModelsError.invalidDateStringFormat
        }

        guard let url = URL(string: photo.url) else {
            throw ModelsError.invalidURLString
        }

        return .init(
            id: photo.id,
            timestamp: timestamp,
            url: photo.url
        )
    }
}

public extension Photo {
    static let samples: [Self] = [
        .init(
            id: UUID().uuidString,
            timestamp: Formatter.iso8601.date(from: "2023-12-01T09:00:00+09")!,
            url: "https://lh3.googleusercontent.com/p/AF1QipPKN3tLkBVnAxUOisz-vA1qhF0RIDV1Bj_PK1xn=s1360-w1360-h1020"
        ),
        .init(
            id: UUID().uuidString,
            timestamp: Formatter.iso8601.date(from: "2023-12-01T09:00:07+09")!,
            url: "https://rtlimages.apple.com/cmc/dieter/store/16_9/R718.png"
        )
    ]
}
