//
//  TickerViewController.swift
//  Exfoler (iOS)
//
//  Created by Григорий Кривякин on 14.01.2022.
//

import UIKit
import CoreData

class TickerViewController: UIViewController {
    //
    // MARK: - Properties
    //
    // Data
    var ticker: TickerInfo?
    private var currentPrice: Double?

    private let priceProvider: AssetsProvider = PolygonAPI.shared
    
    private let dataStore: DataStore = PersistenceController.shared

    // Views
    private var label: UILabel?
    private var table: UITableView?
    var tableRows = ["Ticker", "Market", "Locale", "Type", "Price", "Currency"]
    //
    // MARK: - Initialization
    //
    init(_ ticker: TickerInfo) {
        self.ticker = ticker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
    }
    //
    // MARK: - Prepare views
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // General
        self.title = ticker?.name
        self.view.backgroundColor = .systemBackground
        
        // Table
        table = UITableView()
        table?.dataSource = self
        table?.delegate = self
        table?.frame = self.view.bounds
        self.view.addSubview(table!)
        
        updatePrice()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Handle rotation
        table?.frame = CGRect(origin: .zero, size: view.bounds.size)

    }
    //
    // MARK: - Methods
    //
    
    // UI blocks and logic
    private func updatePrice() {
        priceProvider.previousClose(ticker: ticker?.ticker ?? "") { [weak self] price, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self?.currentPrice = price
                self?.table?.reloadData()
            }
        }
    }
        
    private func addToPortfolioSheet() -> UIAlertController {
        let sheet = UIAlertController(title: "Add to", message: nil, preferredStyle: .actionSheet)
        
        // Portfolios section
        dataStore.allPortfolios().forEach { portfolio in
            let action = UIAlertAction(title: portfolio.name, style: .default) { [weak self] _ in
                guard let ticker = self?.ticker else { return }
                self?.dataStore.add(ticker, to: portfolio)
            }
            sheet.addAction(action)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancelAction)
        
        return sheet
    }
    
}
//
// MARK: - Table support
//
extension TickerViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: Configure sections
    func numberOfSections(in tableView: UITableView) -> Int {
        // First section contains all ticker info.
        // Second section contains only interaction button
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? tableRows.count : 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Ticker details" : " "
    }

    // MARK: Configure cellss
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell
        let cell = UITableViewCell()
        var config = UIListContentConfiguration.valueCell()
                
        if indexPath.section == 0 {
            // Configure ticker info cells
            let text = tableRows[indexPath.row]
            var secondaryText: String?

            switch text {
            case "Ticker": secondaryText = ticker?.ticker
            case "Locale": secondaryText = ticker?.locale
            case "Market": secondaryText = ticker?.market
            case "Type": secondaryText = ticker?.type
            case "Price": secondaryText = currentPrice?.toString()
            case "Currency": secondaryText = ticker?.currency
            default: break
            }
                    
            config.text = text
            config.secondaryText = secondaryText ?? "-"
            cell.contentConfiguration = config
            return cell
        }
        
        // Or configure "Add to portfolio" button
        config.textProperties.color = .systemBlue
        config.text = "Add to portfolio"
        config.image = UIImage(systemName: "plus")
        cell.contentConfiguration = config
        return cell
    }
    
    // MARK: User interaction
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1 { return }
        
        // Handle button tap
        let sheet = addToPortfolioSheet()
        present(sheet, animated: true)
        table?.deselectRow(at: indexPath, animated: true)
    }
    
    
}
