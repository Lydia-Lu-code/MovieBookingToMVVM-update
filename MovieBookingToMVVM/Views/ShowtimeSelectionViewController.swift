//
//  ShowtimeSelectionViewController.swift
//  MovieBookingToMVVM
//

import UIKit

class ShowtimeSelectionViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ShowtimeSelectionViewModel
    
    // MARK: - UI Components
    private lazy var calendarView: UICalendarView = {
        let view = UICalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.calendar = .current
        view.fontDesign = .rounded
        view.delegate = self
        view.tintColor = .systemBlue
        
        let today = Calendar.current.startOfDay(for: Date())
        let threeMonthsLater = Calendar.current.date(byAdding: .month, value: 3, to: today)!
        view.availableDateRange = DateInterval(start: today, end: threeMonthsLater)
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        view.selectionBehavior = dateSelection
        
        return view
    }()
    
    private lazy var showtimeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShowtimeCell.self, forCellWithReuseIdentifier: "ShowtimeCell")
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private lazy var selectSeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("選擇座位", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(selectSeatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: ShowtimeSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.movieTitle
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 設定日曆可選擇範圍
        let today = Calendar.current.startOfDay(for: Date())
        let threeMonthsLater = Calendar.current.date(byAdding: .month, value: 3, to: today)!
        calendarView.availableDateRange = DateInterval(start: today, end: threeMonthsLater)
        
        view.addSubview(calendarView)
        view.addSubview(showtimeCollectionView)
        view.addSubview(selectSeatButton)
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            showtimeCollectionView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            showtimeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            showtimeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectSeatButton.topAnchor.constraint(equalTo: showtimeCollectionView.bottomAnchor, constant: 20),
            selectSeatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectSeatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectSeatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectSeatButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let collectionViewHeight = showtimeCollectionView.heightAnchor.constraint(equalToConstant: 200)
        collectionViewHeight.isActive = true
        collectionViewHeight.priority = .defaultHigh
    }
    
    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(with: state)
            }
        }
    }
    
    private func updateUI(with state: ShowtimeSelectionViewModel.State) {
        showtimeCollectionView.reloadData()
        selectSeatButton.isEnabled = state.isButtonEnabled
        
        if state.shouldShowAlert {
            showTimeSelectionAlert()
        }
    }
    
    // MARK: - Actions
    @objc private func selectSeatButtonTapped() {
        if viewModel.canProceedToSeatSelection() {
            let seatVC = SeatLayoutViewController()
            
            if let selectedDate = viewModel.state.selectedDate,
               let selectedShowtime = viewModel.state.selectedShowtime {
                seatVC.setupBookingData(
                    movieName: viewModel.movieTitle,
                    showDate: selectedDate,
                    showTime: selectedShowtime.time
                )
            }
            
            navigationController?.pushViewController(seatVC, animated: true)
        }
    }
    
    private func showTimeSelectionAlert() {
        let alert = UIAlertController(
            title: "提醒",
            message: "請選擇觀影時段",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICalendarViewDelegate
extension ShowtimeSelectionViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return nil
    }
}

// MARK: - UICalendarSelectionSingleDateDelegate
extension ShowtimeSelectionViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return }
        viewModel.selectDate(date)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ShowtimeSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.state.showtimes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowtimeCell", for: indexPath) as! ShowtimeCell
        let showtime = viewModel.state.showtimes[indexPath.item]
        let isSelected = (showtime.time == viewModel.state.selectedShowtime?.time)
        let cellViewModel = ShowtimeCellViewModel(showtime: showtime, isSelected: isSelected)
        cell.configure(with: cellViewModel)
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let showtime = viewModel.state.showtimes[indexPath.item]
        viewModel.selectShowtime(showtime)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShowtimeSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 10) / 2
        return CGSize(width: width, height: 60)
    }
}

