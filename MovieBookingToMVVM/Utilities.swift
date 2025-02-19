//
//  Utilities.swift
//  MovieBookingToMVVM
//

import UIKit

// MARK: - UI Helpers
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

// MARK: - UI Component Extensions
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

// MARK: - Date Formatting
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

// MARK: - String Extensions
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

