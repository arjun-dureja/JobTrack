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

    final func loadImage(companyName: String, completion: @escaping (UIImage?) -> Swift.Void) {
        utilityQueue.async {
            if let cachedImage = ImageCache.shared.cache.object(forKey: companyName as NSString) {
                DispatchQueue.main.async {
                    print("Using a cached image for item: \(companyName)")
                    completion(cachedImage)
                }
            }

            let key = companyName.lowercased() as NSString
            let companyNameWithoutFormatting = companyName.replacingOccurrences(of: " ", with: "").lowercased()
            let urlString = "https://logo.clearbit.com/\(companyNameWithoutFormatting)"
            var domains = [".com", ".org", ".ca", ".net", ".io", ".co", ".uk", ".tech", ".network"]

            // If user enters a website instead of a company name
            if companyName.contains(".") { domains = [""] }

            for domain in domains {
                if let imageUrl = URL(string: urlString.appending(domain)),
                   let imageData = try? Data(contentsOf: imageUrl) {
                    guard let image = UIImage(data: imageData) else { break }
                    DispatchQueue.main.async {
                        self.cache.setObject(image, forKey: key)
                        completion(image)
                    }

                    return
                }
            }

            DispatchQueue.main.async {
                guard let image = UIImage(
                    systemName: "questionmark.circle.fill",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 1)
                ) else { return }

                self.cache.setObject(image, forKey: key)
                completion(image)
            }
        }
    }
}
