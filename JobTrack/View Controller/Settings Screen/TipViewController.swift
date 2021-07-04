//
//  TipViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-08-08.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit
import StoreKit

class TipViewController: UIViewController {

    // MARK: - Properties
    let tipTableView = UITableView(frame: .zero, style: .grouped)
    var products = [SKProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Leave a Tip"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        navigationItem.leftBarButtonItem?.tintColor = .white
        view.backgroundColor = .semanticSettingsBackground
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        style()
        layout()
        viewDidSetup()
    }

    // Get products from IAPManager
    func viewDidSetup() {
        IAPManager.shared.getProducts { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let products): self?.products = products
                case .failure(let error): print(error)
                }
                self?.products.reverse()
                self?.tipTableView.reloadData()
            }
        }
    }

    // MARK: - Style and Layout
    func style() {
        tipTableView.translatesAutoresizingMaskIntoConstraints = false
        tipTableView.delegate = self
        tipTableView.dataSource = self
        tipTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tipTableView.backgroundColor = .semanticSettingsBackground
    }

    func layout() {
        view.addSubview(tipTableView)

        NSLayoutConstraint.activate([
            tipTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tipTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tipTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tipTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc func closeTapped() {
        dismiss(animated: true)
    }

    // Purchase a product (tip)
    func purchase(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            IAPManager.shared.buy(product: product) { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.showAlert("Thank you!")
                    case .failure(let error): self?.showAlert(error.localizedDescription)
                    }
                }
            }
            return true
        }
    }

    // Show alert helper
    func showAlert(_ message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TipViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = products[indexPath.row].localizedTitle
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)

        let label = UILabel()
        label.text = String(describing: IAPManager.shared.getPriceFormatted(for: products[indexPath.row])!)
        label.textColor = .link
        label.textAlignment = .center
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 15)

        cell.accessoryView = label

        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return """
                    If you've been enjoying this app and would like to show your support,
                    please consider a tip. Thanks! :)
                    """
        }

        return nil
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "TIP"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.purchase(product: products[indexPath.row]) {
            self.showAlert("In-App Purchases are not allowed in this device.")
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
