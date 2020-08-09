//
//  ReportProblemViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-08-06.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit
import MessageUI

class ReportProblemViewController: UIViewController {
    
    // MARK: - Properties
    let descriptionLabel = UILabel()
    let textView = UITextView()
    let sendButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Report a Problem"
        view.backgroundColor = .semanticSettingsBackground
        
        style()
        layout()
    }
    
    // MARK: - Style and Layout
    func style() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Feel free to report bugs or leave any feedback here!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .semanticFilterBorder
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .semanticSettingsTableview
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.clipsToBounds = false
        textView.layer.masksToBounds = false
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1
        textView.layer.shadowOffset = CGSize(width: 3, height: 3)
        textView.delegate = self
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Submit", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sendButton.backgroundColor = .tappedButton
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
    
    func layout() {
        view.addSubview(descriptionLabel)
        view.addSubview(textView)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            
            textView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            sendButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 25),
            sendButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    
    @objc func sendTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["jobtrackfeedback@gmail.com"])
            mail.setSubject("JobTrack Bug Report / Feedback")
            mail.setMessageBody(textView.text, isHTML: true)
            
            present(mail, animated: true)
        } else {
            let ac = UIAlertController(title: "Error", message: "Please try again later", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                 self?.navigationController?.popViewController(animated: true)
            }))
            present(ac, animated: true)
        }
    }
}

// MARK: - UITextViewDelegate, MFMailComposeViewControllerDelegate
extension ReportProblemViewController: UITextViewDelegate, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        
        if result == .sent {
            let ac = UIAlertController(title: "Success", message: "Thank you for your feedback!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                 self?.navigationController?.popViewController(animated: true)
            }))
            present(ac, animated: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 275
    }
    
}
