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
    
    let tipTableView = UITableView(frame: .zero, style: .grouped)
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Leave a Tip"
        view.backgroundColor = .semanticSettingsBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        style()
        layout()
        viewDidSetup()
    }
    
    func viewDidSetup() {
     
        IAPManager.shared.getProducts { (result) in

            DispatchQueue.main.async {
     
                switch result {
                case .success(let products): self.products = products
                case .failure(let error): print(error)
                }
                self.products.reverse()
                self.tipTableView.reloadData()
            }
        }
        
    }
    
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

}

extension TipViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = products[indexPath.row].localizedTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "If you've been enjoying this app and would like to show your support, please consider a tip. Thanks! :)"
        }
        return nil
    }
    
    
    
}
