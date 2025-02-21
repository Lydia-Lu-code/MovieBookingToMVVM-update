//
//  Models.swift
//  MovieBookingToMVVM
//

import Foundation

// MARK: - Movie Models
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
        return URL(string: "\(APIConfig .imageBaseURL)\(path)")
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}

// MARK: - Movie Data Model
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

// MARK: - ShowTime Models
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

// MARK: - Seat Models
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

enum SeatLayoutStatus {
    case available
    case occupied
    case selected
}

// MARK: - Booking Models
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

// MARK: - Seat Layout Configuration
protocol SeatLayoutConfigurationProtocol {
    var numberOfRows: Int { get }
    var seatsPerRow: Int { get }
    var ticketPrice: Int { get }
}

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
