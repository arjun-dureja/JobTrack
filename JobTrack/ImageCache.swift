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
    private let logoDevToken = "pk_QxcYtVpuTg-wQQPQsuT22w"

    final func loadImage(companyName: String, completion: @escaping (UIImage?, Bool) -> Swift.Void) {
        utilityQueue.async {
            let trimmedCompanyName = companyName.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = trimmedCompanyName.lowercased() as NSString
            // Check if image exists in cache first
            if let cachedImage = ImageCache.shared.cache.object(forKey: key) {
                DispatchQueue.main.async {
                    completion(cachedImage, true)
                }

                return
            }

            for imageUrl in self.logoURLs(for: trimmedCompanyName) {
                if let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
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

    private func logoURLs(for companyName: String) -> [URL] {
        var urls = [URL]()

        if let domain = normalizedDomain(from: companyName),
           let domainURL = URL(string: "https://img.logo.dev/\(domain)?token=\(logoDevToken)&format=png&fallback=404") {
            urls.append(domainURL)
        }

        if let encodedCompanyName = companyName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
           let nameURL = URL(
            string: "https://img.logo.dev/name/\(encodedCompanyName)?token=\(logoDevToken)&format=png&fallback=404"
           ) {
            urls.append(nameURL)
        }

        return urls
    }

    private func normalizedDomain(from companyName: String) -> String? {
        let trimmedCompanyName = companyName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmedCompanyName.contains(".") else { return nil }

        if let url = URL(string: trimmedCompanyName),
           let host = url.host?.trimmingCharacters(in: CharacterSet(charactersIn: "/")) {
            return host.replacingOccurrences(of: "www.", with: "")
        }

        let strippedDomain = trimmedCompanyName
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .components(separatedBy: "/")
            .first?
            .replacingOccurrences(of: "www.", with: "")

        return strippedDomain?.isEmpty == false ? strippedDomain : nil
    }
}
