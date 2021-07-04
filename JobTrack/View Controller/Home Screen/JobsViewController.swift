//
//  JobsViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class JobsViewController: UIViewController {

    // MARK: - Properties
    var selectIndex: Int = -1
    var jobsCollectionView: UICollectionView!
    let cvLayout = UICollectionViewFlowLayout()
    let reuseIdentifier = "Cell"
    var companies = [Company]()
    weak var delegate: FavoriteButton!
    weak var deleteDelegate: DeleteButtonDelegate!
    weak var editDelegate: EditJobDelegate!

    static var animatedCells = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // If portrait orientation else landscape
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            cvLayout.itemSize = CGSize(width: view.frame.width - 45, height: 110)
        } else {
            cvLayout.itemSize = CGSize(width: view.frame.width/2 - 45, height: 110)
        }

        jobsCollectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Style and Layout
extension JobsViewController {
    func style() {
        cvLayout.sectionInset = UIEdgeInsets(top: 2, left: 22.5, bottom: 15, right: 22.5)
        jobsCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: cvLayout)
        jobsCollectionView.register(JobCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        jobsCollectionView.delegate = self
        jobsCollectionView.dataSource = self
        jobsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        jobsCollectionView.backgroundColor = .systemBackground
    }

    func layout() {
        view.addSubview(jobsCollectionView)

        NSLayoutConstraint.activate([
            jobsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            jobsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            jobsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            jobsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UIColletionViewDelegate, UICollectionViewDataSource
extension JobsViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout,
                              FavoriteButtonDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        companies.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as? JobCollectionViewCell else { fatalError("Unable to dequeue cells") }

        cell.setCompany(companies[indexPath.item])
        cell.indexPath = indexPath
        cell.favoriteDelegate = self
        return cell
    }

    func favoriteButtonTapped(at indexPath: IndexPath) {
        delegate.favoriteButtonTapped(at: indexPath)
    }

    func favoriteButtonUnTapped(at indexPath: IndexPath) {
        delegate.favoriteButtonUnTapped(at: indexPath)
    }

    // Add delete and edit contextual buttons
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            // Edit button
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
                guard let self = self else { return }
                let vc = AddJobViewController()
                vc.enableEditing(for: self.companies[indexPath.item])
                vc.isEditingEnabled = true
                vc.jobDelegate = self
                self.present(vc, animated: true)
            }

            // Delete button
            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                let ac = UIAlertController(
                    title: "Are you sure you want to delete this job?",
                    message: nil,
                    preferredStyle: .alert
                )

                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                    return
                }))

                ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.deleteDelegate.deleteTapped(at: self.companies[indexPath.item])
                    self.companies.remove(at: indexPath.item)
                    collectionView.reloadData()
                }))

                self?.present(ac, animated: true)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        // Animate jobs when user starts app

        // Only animate the ones that fit on screen to avoid issues
        let jobsToAnimate = Int(collectionView.frame.height / cell.frame.height)

        if collectionView.numberOfItems(inSection: 0) < jobsToAnimate {
            JobsViewController.animatedCells = Int.max
            return
        }

        if JobsViewController.animatedCells < jobsToAnimate {
            JobsViewController.animatedCells += 1
            let cellRect = cell.frame
            cell.frame = CGRect(
                x: cell.frame.origin.x-view.frame.width,
                y: cell.frame.origin.y,
                width: cell.frame.size.width,
                height: cell.frame.size.height
            )

            let value = Double(indexPath.row)*0.05
            UIView.animate(withDuration: 0.8, delay: value, options: .curveEaseInOut, animations: {
                cell.frame = cellRect
            })
        }
    }
}

// MARK: - AddJobDelegate
extension JobsViewController: AddJobDelegate {
    func addButtonTapped(
        companyName: String,
        jobPosition: String,
        dateAdded: Date,
        applicationStatus: ApplicationStatus
    ) {
        return
    }

    func saveButtonTapped(company: Company) {
        for i in 0..<companies.count where companies[i].dateAdded == company.dateAdded {
            companies[i] = company
            jobsCollectionView.reloadData()
            break
        }
        self.editDelegate.jobEdited(company: company)
    }
}

// MARK: - Protocols
protocol FavoriteButton: AnyObject {
    func favoriteButtonTapped(at indexPath: IndexPath)
    func favoriteButtonUnTapped(at indexPath: IndexPath)
}

protocol DeleteButtonDelegate: AnyObject {
    func deleteTapped(at company: Company)
}

protocol EditJobDelegate: AnyObject {
    func jobEdited(company: Company)
}
