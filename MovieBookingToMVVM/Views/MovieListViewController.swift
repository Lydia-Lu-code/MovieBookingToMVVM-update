import UIKit

class MovieListViewController: UIViewController {
    private let viewModel: MovieListViewModel
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: MovieListViewModel = MovieListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MovieListViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchNowPlaying()
    }
    
    private func setupUI() {
        title = "電影"
        view.backgroundColor = .systemBackground
        
        // TableView setup
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        // Activity indicator setup
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupBindings() {
        // 使用新的 state 綁定方式
        viewModel.stateDidChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(with: state)
            }
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    private func updateUI(with state: MovieListViewModel.State) {
        // 處理載入狀態
        if state.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
        
        // 處理錯誤
        if let error = state.error {
            let alert = UIAlertController(title: "錯誤", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
        }
        
        // 重新載入資料
        tableView.reloadData()
    }
    
    @objc private func refreshData() {
        viewModel.fetchNowPlaying()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension MovieListViewController: UITableViewDelegate, UITableViewDataSource, MovieCell.MovieCellDelegate {
    
    func movieCell(_ cell: MovieCell, didTapDetailButtonFor movieId: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
        
        DispatchQueue.main.async { [weak self] in
            let detailViewModel = MovieDetailViewModel(movieId: movieId)
            let detailVC = MovieDetailViewController(viewModel: detailViewModel)
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
        cell.configure(with: cellViewModel)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMovies
    }
}
