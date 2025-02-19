import Foundation


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
    init(movieId: Int, apiService: APIServiceProtocol = APIService()) {
        self.movieId = movieId
        self.apiService = apiService
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
}

//// MARK: - ImageLoaderServiceProtocol
//protocol ImageLoaderServiceProtocol {
//    func loadImageData(from urlString: String, completion: @escaping (Data?) -> Void)
//}

//import Foundation
//
//class MovieDetailViewModel {
//    let movieId: Int
//    private let apiService: APIServiceProtocol
//    private var movie: Movie?
//    
//    private(set) var movieTitle: String?
//    
//    var updateUI: ((Movie) -> Void)?
//    var showError: ((String) -> Void)?
//    
//    init(movieId: Int, movieTitle: String? = nil, apiService: APIServiceProtocol = APIService()) {
//        self.movieId = movieId
//        self.movieTitle = movieTitle
//        self.apiService = apiService
//    }
//    
//    func fetchMovieDetail() {
//        apiService.fetchMovieDetail(id: movieId) { [weak self] result in
//            switch result {
//            case .success(let movie):
//                self?.movie = movie
//                self?.movieTitle = movie.title
//                self?.updateUI?(movie)
//            case .failure(let error):
//                self?.showError?(error.localizedDescription)
//            }
//        }
//    }
//    // 取得電影名稱的方法
//    func getMovieTitle() -> String {
//        return movieTitle ?? "預設電影名稱"
//    }
//    
// 
//}
