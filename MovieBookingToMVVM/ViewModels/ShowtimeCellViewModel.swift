//
//  ShowtimeCellViewModel.swift
//  MovieBookingToMVVM
//

import Foundation

struct ShowtimeCellViewModel {
    let period: String
    let time: String
    let isAvailable: Bool
    let isSelected: Bool  // 新增此屬性
    
    init(showtime: ShowtimeModel, isSelected: Bool = false) {
        self.period = showtime.period
        self.time = showtime.time
        self.isAvailable = showtime.isAvailable
        self.isSelected = isSelected
    }
}

