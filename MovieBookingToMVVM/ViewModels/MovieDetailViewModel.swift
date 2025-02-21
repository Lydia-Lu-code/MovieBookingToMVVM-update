import Foundation
import UIKit

class MovieDetailViewModel {
    // MARK: - Types
    struct State {
        var movie: Movie?
        var isLoading: Bool
        var error: String?
        var posterURL: URL?
    }
    
    // MARK: - Properties
    private let movieId: Int
    private let apiService: APIServiceProtocol
    private let imageLoader: ImageLoaderServiceProtocol
        
    
    private var state: State {
        didSet {
            stateDidChange?(state)
        }
    }
    
    // MARK: - Outputs
    var stateDidChange: ((State) -> Void)?
    
    var displayTitle: String {
        state.movie?.title ?? "電影詳情"
    }
    
    var displayReleaseDate: String {
        guard let date = state.movie?.releaseDate else { return "" }
        return "上映日期：\(date)"  // 直接使用原始日期字串
    }
    
    var displayDuration: String {
        guard let duration = state.movie?.duration else { return "時長未知" }
        return "\(duration) 分鐘"
    }
    
    var displayOverview: String {
        state.movie?.overview ?? ""
    }
    
    // MARK: - Initialization
    init(movieId: Int,
         apiService: APIServiceProtocol = APIService(),
         imageLoader: ImageLoaderServiceProtocol = ImageLoaderService()) {  // 新增參數
        self.movieId = movieId
        self.apiService = apiService
        self.imageLoader = imageLoader  // 新增這行
        self.state = State(movie: nil, isLoading: false, error: nil, posterURL: nil)
    }
    
    func fetchMovieDetail() {
        state.isLoading = true
        
        apiService.fetchMovieDetail(id: movieId) { [weak self] result in
            guard let self = self else { return }
            self.state.isLoading = false
            
            switch result {
            case .success(let movie):
                self.state.movie = movie
                self.state.posterURL = movie.posterURL
            case .failure(let error):
                self.state.error = error.localizedDescription
            }
        }
    }
    
    func loadPosterImage(completion: @escaping (UIImage?) -> Void) {
        guard let url = state.posterURL else {
            completion(nil)
            return
        }
        imageLoader.loadImage(from: url.absoluteString, completion: completion)
    }
    
}

