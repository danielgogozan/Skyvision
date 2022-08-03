//
//  SearchResultViewController.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 15.07.2022.
//

import UIKit
import MapKit

class SearchResultViewController: UITableViewController {
    
    private var locations: [City] = []
    
    @Published var selectedLocation: City?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    private func location(at index: Int) -> City? {
        guard index >= 0 && index < locations.count else { return nil }
        return locations[index]
    }
}

extension SearchResultViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") else { fatalError("Could not dequeue LocationCell.") }
        guard let city = location(at: indexPath.item) else { return UITableViewCell() }
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = "\(city.name), \(city.country)"
        contentConfig.textProperties.font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        contentConfig.textProperties.color = .darkGray
        
        contentConfig.image = UIImage(systemName: "location.viewfinder")
        contentConfig.imageToTextPadding = 20
        contentConfig.imageProperties.tintColor = .systemPink
        
        cell.contentConfiguration = contentConfig
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let city = location(at: indexPath.item) else { return }
        selectedLocation = city
    }
}

extension SearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        Task {
            do {
                let response = try await search.start()
                locations = response.mapItems.map {
                    let location = CLLocation(latitude: $0.placemark.coordinate.latitude, longitude: $0.placemark.coordinate.longitude)
                    return City(name: $0.placemark.locality ?? "Unknown city", country: $0.placemark.country ?? "Unkwnown country", location: location)
                }.unique
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error fetching locations with query \(query): \(error)")
            }
        }
        
    }
}

