//
//  ImageCache.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2021-07-03.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import UIKit
import Foundation
public class ImageCache {

    public static let shared = ImageCache()
    public let cache = NSCache<NSString, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)

    final func loadImage(companyName: String, completion: @escaping (UIImage?, Bool) -> Swift.Void) {
        utilityQueue.async {
            let key = companyName.replacingOccurrences(of: " ", with: "").lowercased() as NSString
            // Check if image exists in cache first
            if let cachedImage = ImageCache.shared.cache.object(forKey: key) {
                DispatchQueue.main.async {
                    completion(cachedImage, true)
                }

                return
            }

            let urlString = "https://logo.clearbit.com/\(key as String)"
            var domains = [".com", ".org", ".ca", ".net", ".io", ".co", ".uk", ".tech", ".network"]
            // If user enters a website instead of a company name
            if companyName.contains(".") { domains = [""] }

            for domain in domains {
                if let imageUrl = URL(string: urlString.appending(domain)),
                   let imageData = try? Data(contentsOf: imageUrl) {
                    guard let image = UIImage(data: imageData) else { break }
                    DispatchQueue.main.async {
                        self.cache.setObject(image, forKey: key)
                        completion(image, false)
                    }

                    return
                }
            }

            // Image doesn't exist, return placeholder
            DispatchQueue.main.async {
                guard let image = UIImage(
                    systemName: "questionmark.circle.fill",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 1)
                ) else { return }

                self.cache.setObject(image, forKey: key)
                completion(image, false)
            }
        }
    }
}
