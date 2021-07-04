//
//  FilterView.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    // MARK: - Properties
    let searchBar = UISearchBar()

    let topFilterStackView = UIStackView()
    let dateButton = UIButton(type: .custom)
    let byStatusButton = UIButton(type: .custom)

    let bottomFilterStackView = UIStackView()
    let aToZButton = UIButton(type: .custom)
    let statusField = UITextField()
    let statusFieldLabel = UILabel()
    let statusFieldDownArrow = UILabel()
    let favoritesButton = UIButton(type: .custom)

    var filterButtons = [UIButton]()

    let separatorLine = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Filter buttons array to easily access all of them
        filterButtons = [
            dateButton,
            byStatusButton,
            aToZButton,
            favoritesButton
        ]

        style()
        layout()
    }

}

extension FilterViewController {

    // Fix colors when user activates or deactivated dark mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        for button in filterButtons {
            button.layer.borderColor = UIColor.semanticFilterBorder.cgColor
        }

        if statusFieldLabel.text == "ALL" {
            statusField.layer.borderColor = UIColor.semanticFilterBorder.cgColor
        }

        searchBar.layer.borderColor = UIColor.semanticFilterBorder.cgColor
    }

    func setupFilterButton(for button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.semanticFilterText, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.semanticFilterBorder.cgColor
        button.layer.cornerRadius = 8
    }

    func style() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none

        guard let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField else { return }
        searchBarTextField.layer.borderWidth = 1.5
        searchBarTextField.layer.cornerRadius = 8
        searchBarTextField.layer.borderColor = UIColor.semanticFilterBorder.cgColor
        searchBarTextField.enablesReturnKeyAutomatically = false

        setupFilterButton(for: dateButton, title: "BY DATE")
        setupFilterButton(for: byStatusButton, title: "BY STATUS")

        dateButton.backgroundColor = .tappedButton
        dateButton.setTitleColor(.white, for: .normal)

        setupFilterButton(for: aToZButton, title: "A - Z")
        setupFilterButton(for: favoritesButton, title: "FAVORITES")

        statusField.tintColor = .clear
        statusField.textAlignment = .center
        statusField.layer.borderWidth = 1.5
        statusField.layer.borderColor = UIColor.semanticFilterBorder.cgColor
        statusField.layer.cornerRadius = 8

        statusFieldLabel.translatesAutoresizingMaskIntoConstraints = false
        statusFieldLabel.text = "ALL"
        statusFieldLabel.textColor = .semanticFilterText
        statusFieldLabel.textAlignment = .center
        statusFieldLabel.font = UIFont.boldSystemFont(ofSize: 14)

        statusFieldDownArrow.translatesAutoresizingMaskIntoConstraints = false
        statusFieldDownArrow.textColor = statusFieldLabel.textColor
        statusFieldDownArrow.text = "⌄"
        statusFieldDownArrow.font = UIFont.boldSystemFont(ofSize: 16)

        topFilterStackView.translatesAutoresizingMaskIntoConstraints = false
        topFilterStackView.axis = .horizontal
        topFilterStackView.spacing = 8
        topFilterStackView.distribution = .fillEqually
        topFilterStackView.addArrangedSubview(dateButton)
        topFilterStackView.addArrangedSubview(byStatusButton)

        bottomFilterStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomFilterStackView.axis = .horizontal
        bottomFilterStackView.spacing = 8
        bottomFilterStackView.distribution = .fillEqually
        bottomFilterStackView.addArrangedSubview(aToZButton)
        bottomFilterStackView.addArrangedSubview(statusField)
        bottomFilterStackView.addArrangedSubview(favoritesButton)

        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = .lightGray

    }

    func layout() {
        view.addSubview(searchBar)
        view.addSubview(topFilterStackView)
        view.addSubview(bottomFilterStackView)
        view.addSubview(separatorLine)

        statusField.addSubview(statusFieldLabel)
        statusField.addSubview(statusFieldDownArrow)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),

            topFilterStackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            topFilterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            topFilterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            statusFieldLabel.centerYAnchor.constraint(equalTo: statusField.centerYAnchor),
            statusFieldLabel.leadingAnchor.constraint(equalTo: statusField.leadingAnchor, constant: 5),
            statusFieldLabel.trailingAnchor.constraint(equalTo: statusField.trailingAnchor, constant: -17),

            statusFieldDownArrow.centerYAnchor.constraint(equalTo: statusField.centerYAnchor, constant: -5),
            statusFieldDownArrow.trailingAnchor.constraint(equalTo: statusField.trailingAnchor, constant: -10),

            bottomFilterStackView.topAnchor.constraint(equalTo: topFilterStackView.bottomAnchor, constant: 12),
            bottomFilterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomFilterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            separatorLine.topAnchor.constraint(equalTo: bottomFilterStackView.bottomAnchor, constant: 12),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}
