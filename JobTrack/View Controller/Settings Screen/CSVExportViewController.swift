//
//  CSVExportViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-08-02.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit
import WebKit
import SwiftCSVExport


class CSVExportViewController: UIViewController, UINavigationBarDelegate {

    //MARK: - Properties
    var webView = WKWebView()
    var companies: [Company]!
    var filePath: String!
    
    // Called from settings VC
    func setCompanies(companies: [Company]) {
        self.companies = companies.sorted {
            $0.applicationStatus < $1.applicationStatus
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Export to CSV"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.rightBarButtonItem?.tintColor = .white

        // Setup webview
        webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height))

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.delegate = self
        webView.backgroundColor = .semanticSettingsBackground
        
        view.addSubview(webView)

        // SwiftCSVExport
        let data:NSMutableArray = NSMutableArray()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        var count = 1
        for company in companies {
            let job: NSMutableDictionary = NSMutableDictionary()
            job.setObject(count, forKey: "Entry" as NSCopying)
            job.setObject(company.companyName!, forKey: "Company" as NSCopying)
            job.setObject(company.jobPosition!, forKey: "Position" as NSCopying)
            job.setObject(company.applicationStatus.rawValue, forKey: "Status" as NSCopying)
            job.setObject(dateFormatter.string(from: company.dateAdded!), forKey: "Date Added" as NSCopying)
            data.add(job)
            count += 1
        }
        
        let header = ["Entry", "Company", "Position", "Status", "Date Added"]
        
        let writeCSVObj = CSV()
        writeCSVObj.rows = data
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        writeCSVObj.name = "Job_Tracker_\(dateFormatter.string(from: Date()))"
        
        let output = CSVExport.export(writeCSVObj)
        if output.result.isSuccess {
            guard let filePath = output.filePath else {
                print("Export Error: \(String(describing: output.message))")
                return
            }
            webView.load(URLRequest(url: URL(fileURLWithPath: filePath)))
            self.filePath = filePath
        }
    }

    // Zoom webview in
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.setZoomScale(0.82, animated: false)
        webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func shareTapped() {
        let items = [URL(fileURLWithPath: filePath)]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
        
        if let popOver = ac.popoverPresentationController {
            popOver.barButtonItem = navigationItem.rightBarButtonItem
        }
    }
}

// MARK: - UIScrollViewDelegate
extension CSVExportViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}
