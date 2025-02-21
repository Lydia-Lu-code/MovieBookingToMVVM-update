//
//  ShowtimeSelectionViewModel.swift
//  MovieBookingToMVVM
//

import Foundation

class ShowtimeSelectionViewModel {
    // MARK: - Types
    struct State {
        var selectedDate: Date?
        var selectedShowtime: ShowtimeModel?
        var showtimes: [ShowtimeModel]
        var isButtonEnabled: Bool
        var shouldShowAlert: Bool
    }
    
    // MARK: - Properties
    let movieTitle: String
    private let calendar = Calendar.current
    
    private(set) var state: State {
        didSet {
            stateDidChange?(state)
        }
    }
    
    // MARK: - Outputs
    var stateDidChange: ((State) -> Void)?
    
    // MARK: - Initialization
    init(movieTitle: String) {
        self.movieTitle = movieTitle
        self.state = State(
            selectedDate: nil,
            selectedShowtime: nil,
            showtimes: [],
            isButtonEnabled: false,
            shouldShowAlert: false
        )
    }
    
    // MARK: - Calendar Configuration
    var availableDateRange: DateInterval {
        let today = calendar.startOfDay(for: Date())
        let sevenDaysLater = calendar.date(byAdding: .day, value: 7, to: today)!
        return DateInterval(start: today, end: sevenDaysLater)
    }
    
    // MARK: - Public Methods
    func selectDate(_ date: Date) {
        state.selectedDate = date
        state.selectedShowtime = nil
        state.isButtonEnabled = false
        
        // 在實際應用中，這裡可能需要從API獲取該日期的場次
        state.showtimes = createShowtimes(for: date)
    }
    
    func selectShowtime(_ showtime: ShowtimeModel) {
        state.selectedShowtime = showtime
        state.isButtonEnabled = true
    }
    
    
    
    func canProceedToSeatSelection() -> Bool {
        guard state.selectedShowtime != nil else {
            state.shouldShowAlert = true
            stateDidChange?(state)
            state.shouldShowAlert = false  // Reset alert state
            return false
        }
        return true
    }
    
    func createCellViewModel(for showtime: ShowtimeModel) -> ShowtimeCellViewModel {
        ShowtimeCellViewModel(showtime: showtime)
    }
    
    // MARK: - Private Methods
    private func createShowtimes(for date: Date) -> [ShowtimeModel] {
        return [
            ShowtimeModel(period: "早上", time: "10:30", isAvailable: true),
            ShowtimeModel(period: "下午", time: "13:30", isAvailable: true),
            ShowtimeModel(period: "下午", time: "14:50", isAvailable: true),
            ShowtimeModel(period: "下午", time: "16:20", isAvailable: true),
            ShowtimeModel(period: "晚上", time: "19:00", isAvailable: true),
            ShowtimeModel(period: "晚上", time: "21:30", isAvailable: true)
        ]
    }
}
