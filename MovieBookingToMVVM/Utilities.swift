//
//  Utilities.swift
//  MovieBookingToMVVM
//

import UIKit

// MARK: - Alert Helper
enum AlertHelper {
    static func showAlert(
        in viewController: UIViewController,
        title: String = "提示",
        message: String,
        handler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "確定",
                style: .default
            ) { _ in
                handler?()
            }
        )
        viewController.present(alert, animated: true)
    }
    
    static func showError(
        in viewController: UIViewController,
        error: Error,
        handler: (() -> Void)? = nil
    ) {
        showAlert(
            in: viewController,
            title: "錯誤",
            message: error.localizedDescription,
            handler: handler
        )
    }
}

// MARK: - Loading Indicator
enum LoadingIndicator {
    private static var activityIndicator: UIActivityIndicatorView?
    
    static func show(in view: UIView) {
        hide()  // 確保不會重複顯示
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
        activityIndicator = indicator
    }
    
    static func hide() {
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
}

// MARK: - UIStackView Extension
extension UIStackView {
    static func createVertical(
        spacing: CGFloat,
        distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = spacing
        stack.distribution = distribution
        return stack
    }
    
    static func createHorizontal(
        spacing: CGFloat,
        distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.distribution = distribution
        return stack
    }
}

// MARK: - Date Extension
extension Date {
    func formatted(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var movieDisplayFormat: String {
        formatted(with: "yyyy/MM/dd")
    }
    
    var timeDisplayFormat: String {
        formatted(with: "HH:mm")
    }
}

// MARK: - String Extension
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

enum PriceCalculator {
    static func calculateTotalAmount(
        ticketType: String,
        peopleCount: Int
    ) -> Int {
        let basePrice = 280
        let packageExtra = 120
        let isPackage = ticketType == "套餐票"
        return peopleCount * (basePrice + (isPackage ? packageExtra : 0))
    }
}

class RateLimiter {
    private let queue = DispatchQueue(label: "com.moviebooking.ratelimiter")
    private var lastRequestTime: Date?
    private let minimumInterval: TimeInterval
    
    init(minimumInterval: TimeInterval = 1.0) {
        self.minimumInterval = minimumInterval
    }
    
    func throttle(block: @escaping () -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let now = Date()
            if let lastTime = self.lastRequestTime,
               now.timeIntervalSince(lastTime) < self.minimumInterval {
                Thread.sleep(forTimeInterval: self.minimumInterval)
            }
            
            DispatchQueue.main.async {
                block()
                self.lastRequestTime = Date()
            }
        }
    }
}
