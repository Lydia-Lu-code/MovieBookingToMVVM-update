//
//  Models.swift
//  MovieBookingToMVVM
//

import Foundation

// 電影相關模型
struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let duration: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case duration = "runtime"
    }
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

// 電影資料模型
struct MovieData {
    let name: String
    let date: Date
    let time: String
    
    static let empty = MovieData(
        name: "",
        date: Date(),
        time: ""
    )
}

// 場次相關模型
struct ShowTime: Codable {
    let id: Int
    let movieId: Int
    let startTime: Date
    let theater: String
    let price: Decimal
    var availableSeats: [Seat]
}

struct ShowtimeModel {
    let period: String
    let time: String
    let isAvailable: Bool
}

struct ShowtimeDateModel {
    let date: Date
    let showtimes: [ShowtimeModel]
}

// 座位相關模型
struct Seat: Codable {
    let row: String
    let number: Int
    var isAvailable: Bool
}

struct SeatLayout {
    let row: Int
    let column: Int
    var status: SeatLayoutStatus
    
    var displayName: String {
        let rowLabel = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(row))!)
        return "\(rowLabel)\(column + 1)"
    }
}

// 訂票相關模型
struct Booking: Codable {
    let id: Int
    let showTimeId: Int
    let selectedSeats: [Seat]
    let totalPrice: Decimal
    let bookingTime: Date
}

struct BookingData: Codable {
    let movieName: String
    let showDate: Date
    let showTime: String
    let peopleCount: Int
    let ticketType: String
    let notes: String
    
    enum CodingKeys: String, CodingKey {
        case movieName = "movie_name"
        case showDate = "show_date"
        case showTime = "show_time"
        case peopleCount = "people_count"
        case ticketType = "ticket_type"
        case notes
    }
}

// MARK: - Enums
enum SeatLayoutStatus {
    case available
    case occupied
    case selected
}

// MARK: - Protocols
// 座位版面配置協議
protocol SeatLayoutConfigurationProtocol {
    var numberOfRows: Int { get }
    var seatsPerRow: Int { get }
    var ticketPrice: Int { get }
}

// MARK: - Configurations
struct SeatLayoutConfiguration: SeatLayoutConfigurationProtocol {
    let numberOfRows: Int
    let seatsPerRow: Int
    let ticketPrice: Int
    
    static let standard = SeatLayoutConfiguration(
        numberOfRows: 8,
        seatsPerRow: 10,
        ticketPrice: 280
    )
}

// MARK: - API Response Models
struct MovieResponse: Codable {
    let results: [Movie]
}
