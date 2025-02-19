//
//  MovieListViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2025/2/19.
//

import Foundation
import UIKit

// MARK: - ImageLoader Service
protocol ImageLoaderServiceProtocol {
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void)
}

class ImageLoaderService: ImageLoaderServiceProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the image
            self?.cache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
