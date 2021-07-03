//
//  JobCollectionViewCell.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class JobCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    let logoView = UIView()
    let logoImageView = UIImageView()
    let companyNameLabel = UILabel()
    let jobPositionLabel = UILabel()
    let applicationStatusLabel = UILabel()
    let jobDetailsStackView = UIStackView()
    let favoriteButton = UIButton()
    let dateAdded = UILabel()

    var company: Company?
    var indexPath: IndexPath!
    weak var favoriteDelegate: FavoriteButtonDelegate!

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2.5
        style()
        layout()
    }

    // Set colors for all UI
    func updateColors(for company: Company) {
        switch company.applicationStatus {

        case .applied:
            backgroundColor = .semanticApplied
            applicationStatusLabel.textColor = .semanticAppliedText
            logoImageView.layer.borderColor = UIColor.semanticAppliedBorder.cgColor
            self.layer.borderColor = UIColor.semanticAppliedBorder.cgColor

        case .phoneScreen:
            backgroundColor = .semanticPhoneScreen
            applicationStatusLabel.textColor = .semanticPhoneScreenText
            logoImageView.layer.borderColor = UIColor.semanticPhoneScreenBorder.cgColor
            self.layer.borderColor = UIColor.semanticPhoneScreenBorder.cgColor

        case .onSite:
            backgroundColor = .semanticOnSite
            applicationStatusLabel.textColor = .semanticOnSiteText
            logoImageView.layer.borderColor = UIColor.semanticOnSiteBorder.cgColor
            self.layer.borderColor = UIColor.semanticOnSiteBorder.cgColor

        case .offer:
            backgroundColor = .semanticOffer
            applicationStatusLabel.textColor = .semanticOfferText
            logoImageView.layer.borderColor = UIColor.semanticOfferBorder.cgColor
            self.layer.borderColor = UIColor.semanticOfferBorder.cgColor

        case .rejected:
            backgroundColor = .semanticRejected
            applicationStatusLabel.textColor = .semanticRejectedText
            logoImageView.layer.borderColor = UIColor.semanticRejectedBorder.cgColor
            self.layer.borderColor = UIColor.semanticRejectedBorder.cgColor
        }
    }

    // If user changed to dark mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors(for: company!)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.logoImageView.image = nil
    }

    // Function called from parent VC
    func setCompany(_ company: Company) {
        self.company = company

        if let cachedImage = ImageCache.shared.cache.object(
            forKey: company.companyName! as NSString
        ) {
            print("Using a cached image for item: \(company.companyName!)")
            self.logoImageView.image = cachedImage
        } else {
            ImageCache.shared.loadImage(companyName: company.companyName!, addToCache: true) { (image) in
                guard let image = image else { return }
                UIView.transition(
                    with: self,
                    duration: 0.15,
                    options: .transitionCrossDissolve,
                    animations: { self.logoImageView.image = image }
                )

                self.logoImageView.tintColor = .black
            }
        }

        companyNameLabel.text = company.companyName
        jobPositionLabel.text = company.jobPosition
        applicationStatusLabel.text = company.applicationStatus.rawValue

        if company.isFavorite {
            favoriteButton.tintColor = .tappedButton
        } else {
            favoriteButton.tintColor = .unfilledHeart
        }

        updateColors(for: company)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateAdded.text = "added on \(dateFormatter.string(from: company.dateAdded!))"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Style and Layout

extension JobCollectionViewCell {

    func style() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.backgroundColor = .white
        logoImageView.layer.cornerRadius = 32.5
        logoImageView.clipsToBounds = true
        logoImageView.layer.borderWidth = 2.5

        logoView.addSubview(logoImageView)

        companyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        companyNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        companyNameLabel.textColor = .white

        jobPositionLabel.font = UIFont.systemFont(ofSize: 16)
        jobPositionLabel.textColor = .white

        applicationStatusLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)

        jobDetailsStackView.translatesAutoresizingMaskIntoConstraints = false
        jobDetailsStackView.axis = .vertical
        jobDetailsStackView.spacing = 2

        jobDetailsStackView.addArrangedSubview(companyNameLabel)
        jobDetailsStackView.addArrangedSubview(jobPositionLabel)
        jobDetailsStackView.addArrangedSubview(applicationStatusLabel)

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(
            UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34)),
            for: .normal
        )

        favoriteButton.addTarget(self, action: #selector(favoriteTapped(_:)), for: .touchUpInside)

        dateAdded.translatesAutoresizingMaskIntoConstraints = false
        dateAdded.font = UIFont.italicSystemFont(ofSize: 12)
        dateAdded.textColor = .semanticDateAdded
    }

    func layout() {
        addSubview(logoView)
        addSubview(jobDetailsStackView)
        addSubview(favoriteButton)
        addSubview(dateAdded)

        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logoImageView.heightAnchor.constraint(equalToConstant: 65),
            logoImageView.widthAnchor.constraint(equalToConstant: 65),

            jobDetailsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            jobDetailsStackView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 16),
            jobDetailsStackView.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),

            favoriteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            favoriteButton.leadingAnchor.constraint(equalTo: jobDetailsStackView.trailingAnchor, constant: 10),

            dateAdded.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            dateAdded.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])

        jobDetailsStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        favoriteButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        favoriteButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        logoView.frame = CGRect(x: 16, y: 25, width: 65, height: 65)
        logoView.clipsToBounds = false
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 0.5
        logoView.layer.shadowOffset = CGSize.zero
        logoView.layer.shadowRadius = 2
        logoView.layer.shadowPath = UIBezierPath(roundedRect: logoView.bounds, cornerRadius: 32.5).cgPath

    }

    // Favorite button tapped
    @objc func favoriteTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 5,
            options: .curveEaseInOut,
            animations: {
                if sender.tintColor == .unfilledHeart {
                    sender.tintColor = .tappedButton
                    self.favoriteDelegate.favoriteButtonTapped(at: self.indexPath)
                } else {
                    sender.tintColor = .unfilledHeart
                    self.favoriteDelegate.favoriteButtonUnTapped(at: self.indexPath)
                }
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                sender.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        )

    }
}

// MARK: - Favorite Button Tapped Protocol

protocol FavoriteButtonDelegate: AnyObject {
    func favoriteButtonTapped(at indexPath: IndexPath)
    func favoriteButtonUnTapped(at indexPath: IndexPath)
}
