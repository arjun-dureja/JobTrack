//
//  HeaderView.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class HeaderViewController: UIViewController {
    
    // MARK: - Properties
    let briefcaseImage = UIImageView()
    let titleLabel = UILabel()
    let addButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
}

extension HeaderViewController {
    func style() {
        briefcaseImage.translatesAutoresizingMaskIntoConstraints = false
        briefcaseImage.image = UIImage(systemName: "briefcase.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26))
        briefcaseImage.tintColor = .label
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        titleLabel.text = "JobTrack"
        titleLabel.sizeToFit()
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32)), for: .normal)
        addButton.tintColor = .tappedButton
    }
    
    func layout() {
        view.addSubview(briefcaseImage)
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            briefcaseImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            briefcaseImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            titleLabel.leadingAnchor.constraint(equalTo: briefcaseImage.trailingAnchor, constant: 4),
            
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}
