//
//  AddJobViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-27.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class AddJobViewController: UIViewController {

    // MARK: - Properties
    let scrollView = UIScrollView()

    let addJobButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    let companyNameField = UITextField()
    let positionField = UITextField()

    let applicationStatusField = UITextField()
    let applicationStatusFieldDownArrow = UILabel()

    let applicationStatusPicker = UIPickerView()
    let applicationStatusPickerData = [
        ApplicationStatus.applied.rawValue.capitalized,
        ApplicationStatus.phoneScreen.rawValue.capitalized,
        ApplicationStatus.onSite.rawValue.capitalized,
        ApplicationStatus.offer.rawValue.capitalized,
        ApplicationStatus.rejected.rawValue.capitalized
    ]

    let applicationStatusFieldColors: [UIColor] = [
        .appliedBackground,
        .phoneScreenBackground,
        .onSiteBackground,
        .offerBackground,
        .rejectedBackground
    ]

    let headerView = UIView()
    let logoImageView = UIImageView()

    let clearbitLink = UIButton(type: .system)

    weak var jobDelegate: AddJobDelegate!

    var isEditingEnabled = false
    var companyToEdit: Company!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Add targets to text fields
        [companyNameField, positionField].forEach({
            $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        })

        companyNameField.addTarget(self, action: #selector(companyEditingFinished), for: .editingDidEnd)

        style()
        layout()

        // Wait 0.25 seconds before showing keyboard
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.companyNameField.becomeFirstResponder()
        }

    }

    // Accomodate landscape mode by enabling a scrollview
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height*2)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)

        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = false
        }

    }

    // Function called only if user is editing a job
    func enableEditing(for company: Company) {
        self.companyToEdit = company
        companyNameField.text = company.companyName
        positionField.text = company.jobPosition
        applicationStatusField.text = company.applicationStatus.rawValue.capitalized

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.companyNameField.resignFirstResponder()
            self.companyNameField.isUserInteractionEnabled = false
        }
    }

    func setupTextField(for textField: UITextField, placeHolder: String) {
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = placeHolder
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.textColor = .systemGray
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 8
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
    }

    func setupButton(for button: UIButton, name: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(name, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
    }

    // MARK: - Style and Layout
    func style() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        headerView.translatesAutoresizingMaskIntoConstraints = false

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.layer.cornerRadius = 50
        logoImageView.clipsToBounds = true
        logoImageView.image = UIImage(
            systemName: "questionmark.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 1)
        )

        logoImageView.tintColor = .black
        logoImageView.backgroundColor = .white
        logoImageView.layer.borderWidth = 2
        logoImageView.layer.borderColor = UIColor.systemGray.cgColor

        setupTextField(for: companyNameField, placeHolder: "Company")
        setupTextField(for: positionField, placeHolder: "Position")
        setupTextField(for: applicationStatusField, placeHolder: "")

        companyNameField.returnKeyType = .next

        applicationStatusPicker.delegate = self
        applicationStatusPicker.dataSource = self

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(
            title: "Done", style: UIBarButtonItem.Style.done,
            target: self, action: #selector(doneTapped)
        )

        doneButton.tintColor = .tappedButton

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        applicationStatusField.inputView = applicationStatusPicker
        applicationStatusField.inputAccessoryView = toolBar
        if !isEditingEnabled {
            headerView.backgroundColor = .appliedBackground
            applicationStatusField.text = ApplicationStatus.applied.rawValue.capitalized
            applicationStatusField.textColor = .appliedBackground
        } else {
            switch companyToEdit.applicationStatus {
            case .applied:
                applicationStatusField.textColor = .appliedBackground
                headerView.backgroundColor = .appliedBackground
            case .offer:
                applicationStatusField.textColor = .offerBackground
                headerView.backgroundColor = .offerBackground
                applicationStatusPicker.selectRow(3, inComponent: 0, animated: false)
            case.onSite:
                applicationStatusField.textColor = .onSiteBackground
                headerView.backgroundColor = .onSiteBackground
                applicationStatusPicker.selectRow(2, inComponent: 0, animated: false)
            case .phoneScreen:
                applicationStatusField.textColor = .phoneScreenBackground
                headerView.backgroundColor = .phoneScreenBackground
                applicationStatusPicker.selectRow(1, inComponent: 0, animated: false)
            case .rejected:
                applicationStatusField.textColor = .rejectedBackground
                headerView.backgroundColor = .rejectedBackground
                applicationStatusPicker.selectRow(4, inComponent: 0, animated: false)
            }
        }
        applicationStatusField.layer.borderWidth = 2
        applicationStatusField.layer.borderColor = applicationStatusField.textColor?.cgColor
        applicationStatusField.tintColor = .clear

        applicationStatusFieldDownArrow.translatesAutoresizingMaskIntoConstraints = false
        applicationStatusFieldDownArrow.textColor = applicationStatusField.textColor
        applicationStatusFieldDownArrow.text = "⌄"
        applicationStatusFieldDownArrow.font = UIFont.boldSystemFont(ofSize: 16)

        setupButton(for: addJobButton, name: "ADD JOB")
        if !isEditingEnabled {
            addJobButton.isEnabled = false
        } else {
            addJobButton.isEnabled = true
            addJobButton.backgroundColor = .tappedButton
            addJobButton.setTitle("SAVE", for: .normal)
        }
        addJobButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        setupButton(for: cancelButton, name: "CANCEL")
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        clearbitLink.translatesAutoresizingMaskIntoConstraints = false
        clearbitLink.setTitle("Logos provided by Clearbit", for: .normal)
        clearbitLink.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        clearbitLink.addTarget(self, action: #selector(clearbitTapped), for: .touchUpInside)
    }

    func layout() {
        view.addSubview(scrollView)
        scrollView.addSubview(headerView)
        scrollView.addSubview((companyNameField))
        scrollView.addSubview(positionField)
        scrollView.addSubview(applicationStatusField)
        scrollView.addSubview(addJobButton)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(clearbitLink)

        headerView.addSubview(logoImageView)
        applicationStatusField.addSubview(applicationStatusFieldDownArrow)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            headerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 150),

            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),

            companyNameField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            companyNameField.leadingAnchor.constraint(
                equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor,
                constant: 10
            ),

            companyNameField.trailingAnchor.constraint(
                equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor,
                constant: -10
            ),

            companyNameField.heightAnchor.constraint(equalToConstant: 40),

            positionField.topAnchor.constraint(equalTo: companyNameField.bottomAnchor, constant: 10),
            positionField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            positionField.trailingAnchor.constraint(
                equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor,
                constant: -10
            ),

            positionField.heightAnchor.constraint(equalToConstant: 40),

            applicationStatusField.topAnchor.constraint(equalTo: positionField.bottomAnchor, constant: 10),
            applicationStatusField.leadingAnchor.constraint(
                equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor,
                constant: 10
            ),

            applicationStatusField.trailingAnchor.constraint(
                equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor,
                constant: -10
            ),

            applicationStatusField.heightAnchor.constraint(equalToConstant: 40),

            applicationStatusFieldDownArrow.centerYAnchor.constraint(
                equalTo: applicationStatusField.centerYAnchor,
                constant: -5
            ),

            applicationStatusFieldDownArrow.trailingAnchor.constraint(
                equalTo: applicationStatusField.trailingAnchor,
                constant: -15
            ),

            addJobButton.topAnchor.constraint(equalTo: applicationStatusField.bottomAnchor, constant: 25),
            addJobButton.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            addJobButton.trailingAnchor.constraint(
                equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor,
                constant: -10
            ),

            addJobButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.topAnchor.constraint(equalTo: addJobButton.bottomAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(
                equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor,
                constant: -10
            ),

            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            clearbitLink.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 25),
            clearbitLink.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)

        ])
    }
}

// MARK: - AddJobDelegate
protocol AddJobDelegate: AnyObject {
    func addButtonTapped(companyName: String, jobPosition: String, applicationStatus: ApplicationStatus)
    func saveButtonTapped(company: Company)
}

// MARK: - Selector functions
extension AddJobViewController {

    // Only enable add job button if fields are filled
    @objc func editingChanged(_ textField: UITextField) {

        guard
            let company = companyNameField.text, !company.isEmpty,
            let position = positionField.text, !position.isEmpty
            else
        {
            self.addJobButton.backgroundColor = .lightGray
            self.addJobButton.isEnabled = false
            return
        }

        addJobButton.backgroundColor = .tappedButton
        addJobButton.isEnabled = true
    }

    // Set logo once user finishes adding company
    @objc func companyEditingFinished(_ sender: UITextField) {
        ImageCache.shared.loadImage(companyName: self.companyNameField.text!) { image, _ in
            guard let image = image else { return }
            UIView.transition(
                with: self.view,
                duration: 0.15,
                options: .transitionCrossDissolve,
                animations: { self.logoImageView.image = image }
            )
        }
    }

    // User taps add job button
    @objc func addTapped() {
        if !isEditingEnabled {
            jobDelegate.addButtonTapped(
                companyName: companyNameField.text!,
                jobPosition: positionField.text!,
                applicationStatus: ApplicationStatus(rawValue: applicationStatusField.text!.uppercased())!
            )
        } else {
            companyToEdit.jobPosition = positionField.text!
            companyToEdit.applicationStatus = ApplicationStatus(rawValue: applicationStatusField.text!.uppercased())!
            jobDelegate.saveButtonTapped(company: companyToEdit)
        }
        dismiss(animated: true)
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    @objc func clearbitTapped() {
        if let url = URL(string: "https://clearbit.com"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func doneTapped() {
        self.applicationStatusField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension AddJobViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == companyNameField {
            positionField.becomeFirstResponder()
        } else {
            positionField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UIPickerViewDelegate
extension AddJobViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return applicationStatusPickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return applicationStatusPickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        applicationStatusField.text = applicationStatusPickerData[row]
        applicationStatusField.layer.borderColor = applicationStatusFieldColors[row].cgColor
        applicationStatusField.textColor = applicationStatusFieldColors[row]
        applicationStatusFieldDownArrow.textColor = applicationStatusField.textColor
        headerView.backgroundColor = applicationStatusFieldColors[row]
    }
}
