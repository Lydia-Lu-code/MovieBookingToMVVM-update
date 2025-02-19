

import Foundation
class MovieListViewModel {
    // MARK: - Types
    struct State {
        var movies: [Movie]
        var isLoading: Bool
        var error: String?
    }
    
    // MARK: - Properties
    private let apiService: APIServiceProtocol
    private let imageLoader: ImageLoaderServiceProtocol
    
    private var state: State {
        didSet {
            stateDidChange?(state)
        }
    }
    
    // MARK: - Outputs
    var stateDidChange: ((State) -> Void)?
    
    var numberOfMovies: Int {
        state.movies.count
    }
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService(),
         imageLoader: ImageLoaderServiceProtocol = ImageLoaderService()) {
        self.apiService = apiService
        self.imageLoader = imageLoader
        self.state = State(movies: [], isLoading: false, error: nil)
    }
    
    // MARK: - Public Methods
    func cellViewModel(at index: Int) -> MovieCellViewModel {
        let movie = state.movies[index]
        return MovieCellViewModel(movie: movie, imageLoader: imageLoader)
    }
    
    func fetchNowPlaying() {
        state.isLoading = true
        state.error = nil
        
        apiService.fetchNowPlaying { [weak self] result in
            guard let self = self else { return }
            
            self.state.isLoading = false
            
            switch result {
            case .success(let movies):
                self.state.movies = movies
            case .failure(let error):
                self.state.error = error.localizedDescription
            }
        }
    }
}

