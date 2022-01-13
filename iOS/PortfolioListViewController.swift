//
//  PortfolioListViewController.swift
//  Exfoler (iOS)
//
//  Created by Григорий Кривякин on 13.01.2022.
//

import UIKit
import CoreData

class PortfolioListViewController: UIViewController {
    //
    // MARK: - Properties
    //
    // Data
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
        let portfolio = Portfolio(context: context)
        portfolio.name = "New portfolio"
        try? context.save()
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
        let request = NSFetchRequest<Portfolio>(entityName: "Portfolio")
        guard let result = try? context.fetch(request) else { return }
        portfolios = Array(result)
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = portfolios[indexPath.row].name
        return cell
    }
    
    // Delete on swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(portfolios[indexPath.row])
            try? context.save()
            updateView()
        }
    }
}
