import Foundation

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case serverError(Int)
    case connectionError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "無效的 URL"
        case .invalidResponse:
            return "無效的伺服器回應"
        case .noData:
            return "沒有接收到資料"
        case .decodingError:
            return "資料解析錯誤"
        case .serverError(let code):
            return "伺服器錯誤：\(code)"
        case .connectionError:
            return "網路連線錯誤"
        }
    }
}

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "https://api.themoviedb.org/3"
    static let apiKey = "89edb46b4a3f5f980e081e1d9ab7bda5"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
}

// MARK: - API Endpoints
enum APIEndpoint {
    case nowPlaying
    case movieDetail(id: Int)
    case showTimes(movieId: Int)
    case booking
    
    var path: String {
        switch self {
        case .nowPlaying:
            return "/movie/now_playing"
        case .movieDetail(let id):
            return "/movie/\(id)"
        case .showTimes(let movieId):
            return "/movie/\(movieId)/showtimes"
        case .booking:
            return "/booking"
        }
    }
    
    var url: URL? {
        URL(string: "\(APIConfig.baseURL)\(path)?api_key=\(APIConfig.apiKey)")
    }
}

// MARK: - API Service Protocol
protocol APIServiceProtocol {
    func fetchNowPlaying(completion: @escaping (Result<[Movie], Error>) -> Void)
    func fetchMovieDetail(id: Int, completion: @escaping (Result<Movie, Error>) -> Void)
    func fetchShowTimes(movieId: Int, completion: @escaping (Result<[ShowTime], Error>) -> Void)
    func createBooking(_ booking: BookingData, completion: @escaping (Result<Booking, Error>) -> Void)
}

// MARK: - API Service Implementation
final class APIService: APIServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchNowPlaying(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = APIEndpoint.nowPlaying.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        performRequest(with: url, expecting: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovieDetail(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        guard let url = APIEndpoint.movieDetail(id: id).url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        performRequest(with: url, expecting: Movie.self, completion: completion)
    }
    
    func fetchShowTimes(movieId: Int, completion: @escaping (Result<[ShowTime], Error>) -> Void) {
        guard let url = APIEndpoint.showTimes(movieId: movieId).url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        performRequest(with: url, expecting: [ShowTime].self, completion: completion)
    }
    
    func createBooking(_ booking: BookingData, completion: @escaping (Result<Booking, Error>) -> Void) {
        guard let url = APIEndpoint.booking.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // 實作 POST 請求...
    }
    
    private func performRequest<T: Decodable>(
        with url: URL,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(NetworkError.connectionError))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let result = try self.decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }
        
        task.resume()
    }
}
