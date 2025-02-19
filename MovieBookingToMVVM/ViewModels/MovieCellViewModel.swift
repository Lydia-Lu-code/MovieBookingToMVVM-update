//
//  MovieCellViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2025/2/19.
//

import Foundation
import UIKit

class MovieCellViewModel {
    private let movie: Movie
    private let imageLoader: ImageLoaderServiceProtocol
    
    var title: String {
        movie.title
    }
    
    var movieId: Int {
        movie.id
    }
    
    var releaseDate: String {
        "上映日期：\(formatDate(movie.releaseDate))"
    }
    
    var posterPath: String? {
        movie.posterPath
    }
    
    init(movie: Movie, imageLoader: ImageLoaderServiceProtocol = ImageLoaderService()) {
        self.movie = movie
        self.imageLoader = imageLoader
    }
    
    func loadPosterImage(completion: @escaping (UIImage?) -> Void) {
        guard let posterPath = movie.posterPath else {
            completion(nil)
            return
        }
        
        let baseURL = "https://image.tmdb.org/t/p/w200"
        let fullPath = baseURL + posterPath
        imageLoader.loadImage(from: fullPath, completion: completion)
    }
    
    private func formatDate(_ dateString: String) -> String {
        // 這裡可以加入日期格式化邏輯
        return dateString
    }
}
