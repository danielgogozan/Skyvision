//
//  SearchViewController.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 15.07.2022.
//

import UIKit
import MapKit
import Combine

protocol SearchResultHandler: AnyObject {
    func useCityLocation(_ city: City)
    func useCurrentLocation()
}

class SearchViewController: UIViewController {
    
    private var resultSearchController: UISearchController?
    private var subscriptions: [AnyCancellable] = []

    weak var delegate: SearchResultHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(colours: [.white, .blue])
        
        setupSearchController()
        setupSearchBar()
    }
 
    private func setupSearchController() {
        guard let resultsVc = storyboard?.instantiateViewController(withIdentifier: String(describing: SearchResultViewController.self)) as? SearchResultViewController else {
            return
        }
        
        resultsVc.$selectedLocation
            .sink { [weak self] city in
                guard let city else { return }
                self?.delegate?.useCityLocation(city)
                self?.navigationController?.dismiss(animated: true)
            }
            .store(in: &subscriptions)
        
        resultSearchController = UISearchController(searchResultsController: resultsVc)
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.searchResultsUpdater = resultsVc
        resultSearchController?.definesPresentationContext = false
        navigationItem.searchController = resultSearchController
    }
    
    func setupSearchBar() {
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "search locations"
        searchBar.tintColor = .darkGray
        searchBar.searchTextField.tintColor = .darkGray
        searchBar.searchTextField.textColor = .darkGray
    }
    
    @IBAction func onLocationTapped(_ sender: Any?) {
        delegate?.useCurrentLocation()
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func onCloseTapped(_ sender: Any?) {
        navigationController?.dismiss(animated: true)
    }
}
