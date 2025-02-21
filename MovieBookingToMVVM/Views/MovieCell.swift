import UIKit

class MovieCell: UITableViewCell {
    // MARK: - Protocols
    protocol MovieCellDelegate: AnyObject {
        func movieCell(_ cell: MovieCell, didTapDetailButtonFor movieId: Int)
    }
    
    // MARK: - UI Components
    private let detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("查看詳情", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 8
        return label
    }()
    
    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Properties
    weak var delegate: MovieCellDelegate?
    private var viewModel: MovieCellViewModel?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        [movieImageView, titleLabel, releaseDateLabel, detailButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        detailButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            movieImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            movieImageView.widthAnchor.constraint(equalToConstant: 60),
            
            detailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            detailButton.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: detailButton.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            releaseDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Actions
    @objc private func detailButtonTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.movieCell(self, didTapDetailButtonFor: viewModel.movieId)
    }
    
    // MARK: - Configuration
    func configure(with viewModel: MovieCellViewModel) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        releaseDateLabel.text = viewModel.releaseDate
        
        viewModel.loadPosterImage { [weak self] image in
            self?.movieImageView.image = image
        }
    }
}
