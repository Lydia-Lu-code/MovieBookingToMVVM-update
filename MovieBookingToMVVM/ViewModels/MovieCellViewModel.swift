import Foundation
import UIKit  // 需要保留，因為 ImageLoaderService 回傳 UIImage

class MovieCellViewModel {
    private let movie: Movie
    private let imageLoader: ImageLoaderServiceProtocol
    
    
    // MARK: - Public Methods
    func loadPosterImage(completion: @escaping (UIImage?) -> Void) {
        guard let posterURLString = movie.posterURL?.absoluteString else {
            completion(nil)
            return
        }
        imageLoader.loadImage(from: posterURLString, completion: completion)
    }
    
    var title: String {
        movie.title
    }
    
    var movieId: Int {
        movie.id
    }
    
    var releaseDate: String {
        "上映日期：\(movie.releaseDate)"
    }
    
    var posterURL: URL? {
        movie.posterURL
    }
    
    init(movie: Movie, imageLoader: ImageLoaderServiceProtocol = ImageLoaderService()) {
        self.movie = movie
        self.imageLoader = imageLoader
    }
}

