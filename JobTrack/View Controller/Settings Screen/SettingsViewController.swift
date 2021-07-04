//
//  SettingsViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit
import StoreKit

class SettingsViewController: UIViewController {

    // MARK: - Properties
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var companies = [Company]()
    let jobsTableView = UITableView()
    var jobsTableViewTitle = UILabel()

    // Data for jobs tableview
    let jobsTableViewSettings = ["View Stats", "Export Jobs to CSV", "Delete All Jobs"]
    let jobsTableViewImages = ["chart.pie.fill", "table.fill", "trash.fill"]
    let jobsTableViewColors: [UIColor] = [.onSiteBackground, .csvGreen, .red]

    let supportTableView = UITableView()
    var supportTableViewTitle = UILabel()

    // Data for support tableview
    let supportTableViewSettings = ["Report a Problem", "Privacy Policy", "Rate", "Leave a Tip"]
    let supportTableViewImages = ["text.bubble.fill", "lock.shield.fill", "star.fill", "dollarsign.circle.fill"]
    let supportTableViewColors: [UIColor] = [.phoneScreenBackground, .darkGray, .offerBackground, .csvGreen]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Get companies from core data
        do {
            companies = try context.fetch(Company.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        companies.reverse()
        jobsTableViewTitle.text = "Jobs (Total: \(companies.count))"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        view.backgroundColor = .semanticSettingsBackground

        // Disable job cell animation if user taps settings before animation is finished
        JobsViewController.animatedCells = Int.max

        style()
        layout()
    }

    // MARK: - Style and Layout
    func styleTableView(for tableView: UITableView) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.isScrollEnabled = false
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = false
        tableView.layer.shadowOpacity = 0.2
        tableView.layer.shadowRadius = 1
        tableView.layer.shadowOffset = CGSize(width: 3, height: 3)

    }

    func style() {
        navigationController?.navigationBar.barTintColor = .tappedButton
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .white

        styleTableView(for: jobsTableView)
        jobsTableView.tag = 0

        jobsTableViewTitle.translatesAutoresizingMaskIntoConstraints = false

        styleTableView(for: supportTableView)
        supportTableView.tag = 1

        supportTableViewTitle.translatesAutoresizingMaskIntoConstraints = false
        supportTableViewTitle.text = "Support"
    }

    func layout() {
        view.addSubview(jobsTableView)
        view.addSubview(jobsTableViewTitle)
        view.addSubview(supportTableView)
        view.addSubview(supportTableViewTitle)

        NSLayoutConstraint.activate([
            jobsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            jobsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            jobsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            jobsTableView.heightAnchor.constraint(equalToConstant: CGFloat(55 * jobsTableViewSettings.count)),

            jobsTableViewTitle.bottomAnchor.constraint(equalTo: jobsTableView.topAnchor, constant: -8),
            jobsTableViewTitle.leadingAnchor.constraint(equalTo: jobsTableView.leadingAnchor, constant: 8),

            supportTableView.topAnchor.constraint(equalTo: jobsTableView.bottomAnchor, constant: 64),
            supportTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            supportTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            supportTableView.heightAnchor.constraint(equalToConstant: CGFloat(55 * supportTableViewSettings.count)),

            supportTableViewTitle.bottomAnchor.constraint(equalTo: supportTableView.topAnchor, constant: -8),
            supportTableViewTitle.leadingAnchor.constraint(equalTo: supportTableView.leadingAnchor, constant: 8)
        ])
    }

    // View stats button pressed
    func viewStats() {
        let vc = JobStatsViewController()
        vc.setCompanies(companies: companies)
        navigationController?.pushViewController(vc, animated: true)
    }

    // Export to CSV button pressed
    func exportToCSV() {
        let vc = CSVExportViewController()
        vc.setCompanies(companies: companies)
        navigationController?.pushViewController(vc, animated: true)
    }

    // Delete all data button pressed
    func deleteAllData() {
        let ac = UIAlertController(
            title: "Are you sure you want to delete all data? This cannot be undone.",
            message: nil,
            preferredStyle: .alert
        )

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            return
        }))

        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            for i in 0..<self.companies.count {
                self.context.delete(self.companies[i])
            }

            self.companies.removeAll()

            do {
                try self.context.save()
            } catch let error as NSError {
                print(error)
            }
        }))

        present(ac, animated: true)
    }

}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return jobsTableViewSettings.count
        } else {
            return supportTableViewSettings.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = .semanticSettingsTableview
        cell.accessoryType = .disclosureIndicator

        // Jobs tableview cells
        if tableView.tag == 0 {
            cell.textLabel?.text = jobsTableViewSettings[indexPath.row]
            cell.imageView?.image = UIImage(systemName: jobsTableViewImages[indexPath.row])
            cell.imageView?.tintColor = jobsTableViewColors[indexPath.row]
            if indexPath.row == 0 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 10
                cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
            if indexPath.row == 2 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 10
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
        // Support tableview cells
        else {
            cell.textLabel?.text = supportTableViewSettings[indexPath.row]
            cell.imageView?.image = UIImage(systemName: supportTableViewImages[indexPath.row])
            cell.imageView?.tintColor = supportTableViewColors[indexPath.row]
            if indexPath.row == 0 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 10
                cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
            if indexPath.row == 3 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 10
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.detailTextLabel?.text = "Thank you for your support!"
            }

        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Jobs tableview cell tapped
        if tableView.tag == 0 {
            var acTitle: String!
            var acMessage: String!

            // View Stats Cell
            if indexPath.row == 0 {
                if companies.count == 0 {
                    acTitle = "No jobs to view"
                    acMessage = "Add a job before viewing stats"
                } else {
                    viewStats()
                    return
                }
            }
            // Export to CSV Cell
            else if indexPath.row == 1 {
                if companies.count == 0 {
                    acTitle = "No jobs to export"
                    acMessage = "Add a job before exporting to CSV"
                } else {
                    exportToCSV()
                    return
                }
            }
            // Delete Data Cell
            else if indexPath.row == 2 {
                if companies.count == 0 {
                    acTitle = "No jobs to delete"
                    acMessage = ""
                } else {
                    deleteAllData()
                    return
                }
            }
            let ac = UIAlertController(title: acTitle, message: acMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        // Support tableview cell tapped
        else {
            // Report a Problem Cell
            if indexPath.row == 0 {
                let vc = ReportProblemViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
            // Privacy Policy Cell
            else if indexPath.row == 1 {
                if let url = URL(string: "https://jobtrack.flycricket.io/privacy.html") {
                    UIApplication.shared.open(url)
                }
            }
            // Rate Cell
            else if indexPath.row == 2 {
                SKStoreReviewController.requestReview()
            }
            // Leave a Tip Cell
            else if indexPath.row == 3 {
                let vc = TipViewController()
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .automatic
                navigationController.navigationBar.barTintColor = .tappedButton
                navigationController.navigationBar.isTranslucent = false
                navigationController.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ]

                present(navigationController, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

}
