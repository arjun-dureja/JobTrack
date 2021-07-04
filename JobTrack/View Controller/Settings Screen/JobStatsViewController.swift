//
//  JobStatsViewController.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-08-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit
import Charts
import LinkPresentation

class JobStatsViewController: UIViewController {

    // MARK: - Properties
    var companies: [Company]!
    var offerCount: Int = 0
    var onSiteCount: Int = 0
    var phoneScreenCount: Int = 0
    var appliedCount: Int = 0
    var rejectedCount: Int = 0

    let stackView = UIStackView()

    let pieChartView = UIView()
    let barChartView = UIView()

    let pieChart = PieChartView()
    let pieChartTitle = UILabel()
    let pieChartDownloadBtn = UIButton(type: .system)

    let barChart = BarChartView()
    let barChartTitle = UILabel()
    let barChartDownloadBtn = UIButton(type: .system)

    var chartToShare = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        view.backgroundColor = .semanticSettingsBackground
        style()
        setupData()
        layout()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            stackView.axis = .vertical
        } else {
            print("i am horizontal")
            stackView.axis = .horizontal
        }
    }

    // Called from settings VC
    func setCompanies(companies: [Company]) {
        self.companies = companies

        for company in companies {
            switch company.applicationStatus {
            case .offer:
                self.offerCount += 1
            case .onSite:
                self.onSiteCount += 1
            case .phoneScreen:
                self.phoneScreenCount += 1
            case .applied:
                self.appliedCount += 1
            case .rejected:
                self.rejectedCount += 1
            }
        }
    }

    // MARK: - Style and Layout
    func style() {
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.translatesAutoresizingMaskIntoConstraints = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        pieChart.translatesAutoresizingMaskIntoConstraints = false
        pieChart.centerText = "Application Status"
        pieChart.noDataText = "No data available"
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        pieChart.centerAttributedText = NSAttributedString(
            string: "Total: \(companies.count)",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )

        pieChart.holeColor = .clear
        pieChart.highlightPerTapEnabled = false
        pieChart.legend.enabled = false
        pieChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .easeInOutQuart)

        pieChartTitle.translatesAutoresizingMaskIntoConstraints = false
        pieChartTitle.text = "Pie Chart"
        pieChartTitle.font = UIFont.boldSystemFont(ofSize: 18)

        pieChartDownloadBtn.translatesAutoresizingMaskIntoConstraints = false
        pieChartDownloadBtn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        pieChartDownloadBtn.tintColor = .tappedButton
        pieChartDownloadBtn.addTarget(self, action: #selector(pieChartDownloadTapped), for: .touchUpInside)

        barChart.translatesAutoresizingMaskIntoConstraints = false
        let xAxisLabels = ["Offer", "On Site", "Phone\nScreen", "Applied", "Rejected"]
        barChart.leftAxis.enabled = false
        barChart.rightAxis.enabled = false
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        barChart.xAxis.granularity = 1
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .easeInOutQuart)

        barChartTitle.translatesAutoresizingMaskIntoConstraints = false
        barChartTitle.text = "Bar Chart"
        barChartTitle.font = UIFont.boldSystemFont(ofSize: 18)

        barChartDownloadBtn.translatesAutoresizingMaskIntoConstraints = false
        barChartDownloadBtn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        barChartDownloadBtn.tintColor = .tappedButton
        barChartDownloadBtn.addTarget(self, action: #selector(barChartDownloadTapped), for: .touchUpInside)
    }

    func setupData() {
        let values = [self.offerCount, self.onSiteCount, self.phoneScreenCount, self.appliedCount, self.rejectedCount]
        let colors: [UIColor] = [.offerBackground,
                              .onSiteBackground,
                              .phoneScreenBackground,
                              .appliedBackground,
                              .rejectedBackground]

        var entries = [PieChartDataEntry]()
        let pieChartLabels = ["Offer", "On Site", "Phone\nScreen", "Applied", "Rejected"]
        var dataSetColors: [UIColor] = []

        for i in 0..<values.count where values[i] != 0 {
            entries.append(PieChartDataEntry(value: Double(values[i]), label: pieChartLabels[i]))
            dataSetColors.append(colors[i])
        }

        let dataSet = PieChartDataSet(entries: entries, label: nil)
        dataSet.colors = dataSetColors

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        dataSet.valueFormatter = (DefaultValueFormatter(formatter: formatter))
        dataSet.entryLabelFont = UIFont.boldSystemFont(ofSize: 12)
        dataSet.valueFont = UIFont.boldSystemFont(ofSize: 12)
        pieChart.data = PieChartData(dataSet: dataSet)

        var barChartEntries = [BarChartDataEntry]()
        for i in 0..<values.count {
            barChartEntries.append(BarChartDataEntry(x: Double(i), y: Double(values[i])))
        }

        let data = BarChartDataSet(entries: barChartEntries, label: "Total: \(companies.count)")
        data.colors = colors
        data.valueFormatter = (DefaultValueFormatter(formatter: formatter))

        barChart.data = BarChartData(dataSet: data)

    }

    func layout() {
        pieChartView.addSubview(pieChart)
        pieChartView.addSubview(pieChartTitle)
        pieChartView.addSubview(pieChartDownloadBtn)

        barChartView.addSubview(barChart)
        barChartView.addSubview(barChartTitle)
        barChartView.addSubview(barChartDownloadBtn)

        stackView.addArrangedSubview(pieChartView)
        stackView.addArrangedSubview(barChartView)

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            pieChart.topAnchor.constraint(equalTo: pieChartView.topAnchor, constant: 32),
            pieChart.leadingAnchor.constraint(equalTo: pieChartView.leadingAnchor, constant: 8),
            pieChart.trailingAnchor.constraint(equalTo: pieChartView.trailingAnchor, constant: -8),
            pieChart.bottomAnchor.constraint(equalTo: pieChartView.bottomAnchor),

            pieChartTitle.bottomAnchor.constraint(equalTo: pieChart.topAnchor, constant: 8),
            pieChartTitle.leadingAnchor.constraint(equalTo: pieChart.leadingAnchor, constant: 16),

            pieChartDownloadBtn.bottomAnchor.constraint(equalTo: pieChart.topAnchor, constant: 8),
            pieChartDownloadBtn.trailingAnchor.constraint(equalTo: pieChart.trailingAnchor, constant: -16),

            barChart.topAnchor.constraint(equalTo: barChartView.topAnchor, constant: 40),
            barChart.leadingAnchor.constraint(equalTo: barChartView.leadingAnchor, constant: 32),
            barChart.trailingAnchor.constraint(equalTo: barChartView.trailingAnchor, constant: -32),
            barChart.bottomAnchor.constraint(equalTo: barChartView.bottomAnchor),

            barChartTitle.bottomAnchor.constraint(equalTo: barChart.topAnchor),
            barChartTitle.leadingAnchor.constraint(equalTo: barChartView.leadingAnchor, constant: 24),

            barChartDownloadBtn.bottomAnchor.constraint(equalTo: barChart.topAnchor),
            barChartDownloadBtn.trailingAnchor.constraint(equalTo: barChart.trailingAnchor, constant: 8)
        ])
    }

    // Chart download tapped
    @objc func pieChartDownloadTapped() {
        chartToShare = 0
        let renderer = UIGraphicsImageRenderer(size: self.pieChart.bounds.size)
        let image = renderer.image { [weak self] _ in
            guard let self = self else { return }
            self.pieChart.drawHierarchy(in: self.pieChart.bounds, afterScreenUpdates: true)
        }

        let ac = UIActivityViewController(activityItems: [image, self], applicationActivities: nil)
        present(ac, animated: true)

        if let popOver = ac.popoverPresentationController {
            popOver.sourceView = pieChartDownloadBtn
        }
    }

    @objc func barChartDownloadTapped() {
        chartToShare = 1
        let renderer = UIGraphicsImageRenderer(size: self.barChart.bounds.size)
        let image = renderer.image { [weak self] _ in
            guard let self = self else { return }
            self.barChart.drawHierarchy(in: self.barChart.bounds, afterScreenUpdates: true)
        }

        let ac = UIActivityViewController(activityItems: [image, self], applicationActivities: nil)
        present(ac, animated: true)

        if let popOver = ac.popoverPresentationController {
            popOver.sourceView = barChartDownloadBtn
        }
    }

}

// MARK: - UIActivityItemSource
extension JobStatsViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        return nil
    }

    // Show chart as image in share thumbnail
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        var chartImage = UIImage()
        if chartToShare == 0 {
            let renderer = UIGraphicsImageRenderer(size: self.pieChart.bounds.size)
            chartImage = renderer.image { [weak self] _ in
                guard let self = self else { return }
                self.pieChart.drawHierarchy(in: self.pieChart.bounds, afterScreenUpdates: true)
            }

            metadata.title = "Pie Chart"
        } else {
            let renderer = UIGraphicsImageRenderer(size: self.barChart.bounds.size)
            chartImage = renderer.image { [weak self] _ in
                guard let self = self else { return }
                self.barChart.drawHierarchy(in: self.barChart.bounds, afterScreenUpdates: true)
            }

            metadata.title = "Bar Chart"
        }

        let image = chartImage
        let imageProvider = NSItemProvider(object: image)
        metadata.imageProvider = imageProvider
        return metadata
    }
}
