//
//  SearchViewController.swift
//  Exfoler (iOS)
//
//  Created by Григорий Кривякин on 13.01.2022.
//

import UIKit

class SearchViewController: UIViewController {
    //
    // MARK: - Properties
    //
    // Data
    private var provider: AssetsProvider = PolygonAPI.shared
    private var searchResults = [TickerInfo]()
    
    // Views & View logic
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var activityView: UIActivityIndicatorView?
    private var isSearching = false
    //
    // MARK: Prepare subviews
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // SearchBar
        searchBar.delegate = self
        
        // Table
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        
        // Activity indicator view
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = view.center
        activityView?.hidesWhenStopped = true
        view.addSubview(activityView!)
        
    }
    //
    // MARK: Methods
    //
    private func updateView() {
        self.table.reloadData()
        isSearching ? activityView?.startAnimating() : activityView?.stopAnimating()
    }
}
//
// MARK: - SearchBar support
//
extension SearchViewController: UISearchBarDelegate {
    // Start search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults.removeAll()
        isSearching = true
        updateView()
        let text = searchBar.text ?? ""
        provider.tickers(search: text) { [weak self] tickers, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let tickers = tickers else { return }
            
            // Update data and views
            DispatchQueue.main.async {
                self?.searchResults.append(contentsOf: tickers)
                self?.isSearching = false
                self?.updateView()
            }
        }
    }
}
//
// MARK: - Table support
//
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = searchResults[indexPath.row].name
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tickerViewController = TickerViewController(searchResults[indexPath.row])
        navigationController?.pushViewController(tickerViewController, animated: true)

    }
}
