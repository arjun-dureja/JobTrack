//
//  ViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let headerVC = HeaderViewController()
    let filterVC = FilterViewController()
    let jobsVC = JobsViewController()
    
    var jobsSortedByDate = [Company]()
    
    let statusPickerView = UIPickerView()
    let statusPickerData = [
        "All",
        ApplicationStatus.applied.rawValue.capitalized,
        ApplicationStatus.phoneScreen.rawValue.capitalized,
        ApplicationStatus.onSite.rawValue.capitalized,
        ApplicationStatus.offer.rawValue.capitalized,
        ApplicationStatus.rejected.rawValue.capitalized
    ]
    let statusFieldColors: [UIColor] = [
        .semanticFilterBorder,
        .appliedBackground,
        .phoneScreenBackground,
        .onSiteBackground,
        .offerBackground,
        .rejectedBackground
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeaderVC()
        addFilterVC()
        addJobsVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            jobsVC.companies = try context.fetch(Company.fetchRequest())
            jobsVC.companies = jobsVC.companies.sorted {
                $0.dateAdded! > $1.dateAdded!
            }
            jobsVC.jobsCollectionView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.jobsSortedByDate = jobsVC.companies
    }
    
    func addHeaderVC() {
        addChild(headerVC)
        view.addSubview(headerVC.view)
        headerVC.didMove(toParent: self)
        setHeaderVCConstraints()
        headerVC.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    func setHeaderVCConstraints() {
        headerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerVC.view.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func addFilterVC() {
        addChild(filterVC)
        view.addSubview(filterVC.view)
        filterVC.didMove(toParent: self)
        setFilterVCConstraints()
        filterVC.searchBar.delegate = self
        
        for button in filterVC.filterButtons {
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        }
        
        setupStatusPicker()
    }
    
    func setupStatusPicker() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneTapped))
        doneButton.tintColor = .tappedButton
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        statusPickerView.delegate = self
        statusPickerView.dataSource = self
        filterVC.statusField.inputAccessoryView = toolBar
        filterVC.statusField.inputView = statusPickerView
    }
    
    @objc func doneTapped() {
        self.filterVC.statusField.resignFirstResponder()
    }
    
    func setFilterVCConstraints() {
        filterVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterVC.view.topAnchor.constraint(equalTo: headerVC.view.bottomAnchor),
            filterVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            filterVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            filterVC.view.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    func addJobsVC() {
        addChild(jobsVC)
        view.addSubview(jobsVC.view)
        jobsVC.didMove(toParent: self)
        setJobsVCConstraints()
        jobsVC.delegate = self
        jobsVC.deleteDelegate = self
        jobsVC.editDelegate = self
    }
    
    func setJobsVCConstraints() {
        jobsVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            jobsVC.view.topAnchor.constraint(equalTo: filterVC.view.bottomAnchor),
            jobsVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            jobsVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            jobsVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: Add Job Delegate
extension HomeViewController: AddJobDelegate {
    
    @objc func addTapped(){
        let vc = AddJobViewController()
        vc.jobDelegate = self
        
        if filterVC.searchBar.isFirstResponder {
            filterVC.searchBar.resignFirstResponder()
            filterVC.searchBar.text = nil
            filterVC.dateButton.sendActions(for: .touchUpInside)
        }
        
        present(vc, animated: true)
    }
    
    func addButtonTapped(companyName: String, jobPosition: String, applicationStatus: ApplicationStatus) {
        let company = Company(context: self.context)
        company.companyName = companyName
        company.jobPosition = jobPosition
        company.applicationStatus = applicationStatus
        company.isFavorite = false
        company.dateAdded = Date()
        
        do {
            try self.context.save()
        }
        catch let error as NSError {
            print(error)
        }
        
        filterVC.dateButton.sendActions(for: .touchUpInside)
        jobsVC.companies = jobsSortedByDate
        
        jobsVC.companies.insert(company, at: 0)
        jobsVC.jobsCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        jobsVC.jobsCollectionView.reloadData()
        
        self.jobsSortedByDate = jobsVC.companies
    }
    
    func saveButtonTapped(company: Company) {
        return
    }
}

// MARK: Search Bar Delegate
extension HomeViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        for button in filterVC.filterButtons {
            button.setTitleColor(.semanticFilterText, for: .normal)
            button.backgroundColor = .systemBackground
            button.isSelected = false
        }
        
        statusPickerView.selectRow(0, inComponent: 0, animated: true)
        filterVC.statusFieldLabel.text = "ALL"
        filterVC.statusFieldLabel.textColor = .semanticFilterText
        filterVC.statusField.layer.borderColor = UIColor.semanticFilterBorder.cgColor
        filterVC.statusFieldDownArrow.textColor = filterVC.statusFieldLabel.textColor
        
        jobsVC.companies = jobsSortedByDate
        jobsVC.jobsCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text == "" {
            filterVC.dateButton.sendActions(for: .touchUpInside)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        jobsVC.companies = jobsSortedByDate.filter {
            $0.companyName!.lowercased().hasPrefix(searchText.lowercased())
        }
        
        jobsVC.jobsCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: Filter Buttons Tapped
extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @objc func filterButtonTapped(_ sender: UIButton) {
        filterVC.searchBar.resignFirstResponder()
        filterVC.searchBar.text = nil
        for button in filterVC.filterButtons {
            button.setTitleColor(.semanticFilterText, for: .normal)
            button.backgroundColor = .systemBackground
            if !sender.isSelected {
                button.isSelected = false
            }
        }
        
        statusPickerView.selectRow(0, inComponent: 0, animated: true)
        filterVC.statusFieldLabel.text = "ALL"
        filterVC.statusFieldLabel.textColor = .semanticFilterText
        filterVC.statusField.layer.borderColor = UIColor.semanticFilterBorder.cgColor
        filterVC.statusFieldDownArrow.textColor = filterVC.statusFieldLabel.textColor
        
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .tappedButton
        
        if !sender.isSelected {
            if sender.titleLabel?.text == "BY DATE" {
                jobsVC.companies = jobsSortedByDate.sorted {
                    $0.dateAdded! > $1.dateAdded!
                }
            }
            else if sender.titleLabel?.text == "BY STATUS" {
                jobsVC.companies = jobsSortedByDate.sorted {
                    $0.applicationStatus < $1.applicationStatus
                }
            }
            else if sender.titleLabel?.text == "A - Z" {
                jobsVC.companies = jobsSortedByDate.sorted {
                    $0.companyName!.lowercased() < $1.companyName!.lowercased()
                }
            }
            else if sender.titleLabel?.text == "FAVORITES" {
                jobsVC.companies = jobsSortedByDate.filter {
                    $0.isFavorite
                }
            }
            sender.isSelected = true
            jobsVC.jobsCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
            jobsVC.jobsCollectionView.reloadData()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        filterVC.searchBar.resignFirstResponder()
        filterVC.searchBar.text = nil
        
        filterVC.statusFieldLabel.text = statusPickerData[row].uppercased()
        filterVC.statusField.layer.borderColor = statusFieldColors[row].cgColor
        if row == 0 {
            filterVC.statusFieldLabel.textColor = .semanticFilterText
        } else {
            filterVC.statusFieldLabel.textColor = statusFieldColors[row]
        }
        filterVC.statusFieldDownArrow.textColor = filterVC.statusFieldLabel.textColor
        
        if row != 0 {
            for button in filterVC.filterButtons {
                button.setTitleColor(.semanticFilterText, for: .normal)
                button.backgroundColor = .systemBackground
                button.isSelected = false
            }
        } else {
            filterVC.dateButton.sendActions(for: .touchUpInside)
        }
        
        switch row {
        case 0:
            jobsVC.companies = jobsSortedByDate
        case 1:
            jobsVC.companies = jobsSortedByDate.filter {
                $0.applicationStatus == .applied
            }
        case 2:
            jobsVC.companies = jobsSortedByDate.filter {
                $0.applicationStatus == .phoneScreen
            }
        case 3:
            jobsVC.companies = jobsSortedByDate.filter {
                $0.applicationStatus == .onSite
            }
        case 4:
            jobsVC.companies = jobsSortedByDate.filter {
                $0.applicationStatus == .offer
            }
        case 5:
            jobsVC.companies = jobsSortedByDate.filter {
                $0.applicationStatus == .rejected
            }
        default:
            break
        }
        jobsVC.jobsCollectionView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusPickerData[row]
    }
    
}

// MARK: Favorite Button Tapped
extension HomeViewController: FavoriteButton {
    func favoriteButtonTapped(at indexPath: IndexPath) {
        self.jobsVC.companies[indexPath.item].isFavorite = true
        for i in 0..<jobsSortedByDate.count {
            if jobsSortedByDate[i].dateAdded == jobsVC.companies[indexPath.item].dateAdded {
                jobsSortedByDate[i].isFavorite = true
                break
            }
        }
    }
    
    func favoriteButtonUnTapped(at indexPath: IndexPath) {
        self.jobsVC.companies[indexPath.item].isFavorite = false
        for i in 0..<jobsSortedByDate.count {
            if jobsSortedByDate[i].dateAdded == jobsVC.companies[indexPath.item].dateAdded {
                jobsSortedByDate[i].isFavorite = false
                break
            }
        }
    }
    
    
}

// MARK: Delete or Edit Button Delegate
extension HomeViewController: DeleteButtonDelegate, EditJobDelegate {
    
    func deleteTapped(at company: Company) {
        self.context.delete(company)
        
        do {
            try self.context.save()
        }
        catch let error as NSError {
            print(error)
        }
        
        for i in 0..<jobsSortedByDate.count {
            if jobsSortedByDate[i].dateAdded == company.dateAdded {
                jobsSortedByDate.remove(at: i)
                break
            }
        }
        
   
    }
    
    func jobEdited(company: Company) {
        for i in 0..<jobsSortedByDate.count {
            if jobsSortedByDate[i].dateAdded == company.dateAdded {
                jobsSortedByDate[i] = company
                break
            }
        }
    }
    
}
