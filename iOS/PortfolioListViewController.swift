//
//  PortfolioListViewController.swift
//  Exfoler (iOS)
//
//  Created by Григорий Кривякин on 13.01.2022.
//

import UIKit
import CoreData

class PortfolioListViewController: UIViewController {
    private let cellID = "portfolioCell"
    //
    // MARK: - Properties
    //
    // Data
    private let dataStore: DataStore = PersistenceController.shared
    private let context = PersistenceController.shared.container.viewContext
    private var portfolios = [Portfolio]()
    
    // Views
    @IBOutlet weak var table: UITableView!
    //
    // MARK: Prepare subviews
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        
        updateView()
    }
    //
    // MARK: - User intents
    //
    @IBAction func createPortfolio(_ sender: UIBarButtonItem) {
        // Create new portfolio
        dataStore.newPortfolio(name: "New portfolio \(portfolios.count)")
        updateView()
    }
    //
    // MARK: - Methods
    //
    func updateView() {
        refetchPortfolios()
        table.reloadData()
    }
    
    func refetchPortfolios() {
        // Fetch portfolios from database
        portfolios = PersistenceController.shared.allPortfolios()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//
// MARK: - Table support
//
extension PortfolioListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        portfolios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = table.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
            cell?.accessoryType = .disclosureIndicator
        }
                
        var config = UIListContentConfiguration.valueCell()
        config.text = portfolios[indexPath.row].name
        cell?.contentConfiguration = config
        return cell!
    }
    
    // Delete on swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataStore.delete(portfolios[indexPath.row])
            refetchPortfolios()
            table.deleteRows(at: [indexPath], with: .automatic)
            updateView()
        }
    }
}
