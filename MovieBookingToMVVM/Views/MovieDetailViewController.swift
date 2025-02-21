
import UIKit

class MovieDetailViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: MovieDetailViewModel
    private let imageLoader: ImageLoaderServiceProtocol
     
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "劇情簡介"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let showTimesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("選擇場次", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: MovieDetailViewModel, imageLoader: ImageLoaderServiceProtocol = ImageLoaderService()) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        self.viewModel = MovieDetailViewModel(movieId: 0)
        self.imageLoader = ImageLoaderService()  // 加入預設值
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        viewModel.fetchMovieDetail()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 基本設置
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        // 添加捲動視圖和內容視圖
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加內容元件到內容視圖
        [posterImageView, titleLabel, releaseDateLabel, durationLabel,
         overviewTitleLabel, overviewLabel].forEach { contentView.addSubview($0) }
        
        // 添加固定元件到主視圖
        view.addSubview(showTimesButton)
        view.addSubview(activityIndicator)
        
        // 設置按鈕動作
        showTimesButton.addTarget(self, action: #selector(showTimesButtonTapped), for: .touchUpInside)
        
        // 設置約束
        setupConstraints()
    }
    
    
    private func setupConstraints() {
       let contentGuide = contentView.layoutMarginsGuide
       
       NSLayoutConstraint.activate([
           // ScrollView - 修改 bottom 約束
           scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
           scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           scrollView.bottomAnchor.constraint(equalTo: showTimesButton.topAnchor, constant: -20),
           
           // ContentView
           contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
           contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
           contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
           contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
           contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
           
           // PosterImageView
           posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
           posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
           posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
           posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 0.6),
           
           // TitleLabel
           titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
           titleLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           titleLabel.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
           
           // ReleaseDateLabel
           releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
           releaseDateLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           
           // DurationLabel
           durationLabel.centerYAnchor.constraint(equalTo: releaseDateLabel.centerYAnchor),
           durationLabel.leadingAnchor.constraint(equalTo: releaseDateLabel.trailingAnchor, constant: 16),
           
           // OverviewTitleLabel
           overviewTitleLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 24),
           overviewTitleLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           overviewTitleLabel.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
           
           // OverviewLabel
           overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: 8),
           overviewLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           overviewLabel.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
           overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),  // 新增
           
           // ShowTimesButton - 移動到主視圖並固定在底部
           showTimesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
           showTimesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           showTimesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
           showTimesButton.heightAnchor.constraint(equalToConstant: 50),
           
           // ActivityIndicator
           activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
       ])
    }
    
    
    // MARK: - UI Updates
    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(with: state)
            }
        }
    }
    
    private func updateUI(with state: MovieDetailViewModel.State) {
        // 處理載入狀態
        state.isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        
        // 處理錯誤
        if let error = state.error {
            AlertHelper.showError(in: self, error: error as! Error)
            return
        }
        
        // 更新文字內容
        titleLabel.text = viewModel.displayTitle
        releaseDateLabel.text = viewModel.displayReleaseDate
        durationLabel.text = viewModel.displayDuration
        overviewLabel.text = viewModel.displayOverview
        
        // 更新圖片
        if let url = state.posterURL {
            imageLoader.loadImage(from: url.absoluteString) { [weak self] image in
                DispatchQueue.main.async {
                    self?.posterImageView.image = image
                }
            }
        }
    }
    

    @objc internal func showTimesButtonTapped() {
        let movieTitle = viewModel.displayTitle
        print("MovieDetail - 傳送電影名稱: \(movieTitle)")

        let showtimeViewModel = ShowtimeSelectionViewModel(movieTitle: movieTitle)
        let showtimeVC = ShowtimeSelectionViewController(viewModel: showtimeViewModel)
        navigationController?.pushViewController(showtimeVC, animated: true)
    }
    


    func configure(with movieId: Int) {
        viewModel = MovieDetailViewModel(movieId: movieId)
    }

}
