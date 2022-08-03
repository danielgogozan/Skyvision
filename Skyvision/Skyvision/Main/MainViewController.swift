//
//  ViewController.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 08.07.2022.
//

import UIKit
import WeatherKit
import CoreLocation
import Combine
import MapKit

class MainViewController: SwipeableViewController {
    // MARK: - Private properties
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var visibilityIcon: UIImageView!
    @IBOutlet private weak var visibilityLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = MainViewModel()
    private let locationManager = CLLocationManager()
    private var subscriptions: [AnyCancellable] = []
    private var deeplinked = false
    
    // MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search",
           let destination = (segue.destination as? UINavigationController)?.viewControllers.first as? SearchViewController {
            destination.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyGradient(colours: [.darkGray, .blue])
        
        setupLocation()
        setupCollectionView()
        setupSubscription()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateContainerView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if viewModel.autoScrollEnabled {
            collectionView.scrollToItem(at: viewModel.indexToScroll, at: .centeredHorizontally, animated: false)
        }
    }
    
    // MARK: - Public API
    func setWidgetLocation(_ location: CLLocation) {
        viewModel.userLocation = location
        deeplinked = true
    }
    
}

// MARK: - View and ViewModel setup
private extension MainViewController {
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if !deeplinked {
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupCollectionView() {
        collectionView.registerCell(ofType: SegmentedControlCell.self)
        collectionView.registerCell(ofType: ForecastCell.self)
        collectionView.registerCell(ofType: CelestialCell.self)
        collectionView.registerCell(ofType: GeneralDataCell.self)
        collectionView.registerCell(ofType: AlertCell.self)
        
        collectionView.dataSource = self
        collectionView.collectionViewLayout = compositionalLayout()
        
        collectionView.reloadData()
        collectionView.backgroundColor = .clear
    }
    
    func setupSubscription() {
        viewModel.$currentPlacemark
            .receive(on: RunLoop.main)
            .sink { [weak self] placemark in
                self?.locationLabel.text = placemark?.locality ?? "Your location"
            }
            .store(in: &subscriptions)
        
        viewModel.$currentWeather
            .receive(on: RunLoop.main)
            .sink { [weak self] currentWeather in
                guard let self, let currentWeather else { return }
                self.temperatureLabel.text = "\(Int(currentWeather.temperature.value).description)\(currentWeather.temperature.unit.symbol)"
                self.visibilityLabel.text = currentWeather.condition.description
                self.visibilityIcon.image = Resources.shared.contitionIcon(condition: currentWeather.condition)
            }
            .store(in: &subscriptions)
        
        viewModel.$dayForecastData
            .zip(viewModel.$hourForecastData)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .store(in: &subscriptions)
        
        viewModel.$loading
            .receive(on: RunLoop.main)
            .sink { [weak self] loading in
                self?.toggleActivityIndicator(loading)
            }
            .store(in: &subscriptions)
        
        viewModel.$alerts
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            .store(in: &subscriptions)
    }
    
    func toggleActivityIndicator(_ loading: Bool) {
        if loading {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
}

// MARK: - CLLocation manager delegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()
        viewModel.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}

// MARK: - Search Result Handler
extension MainViewController: SearchResultHandler {
    func useCityLocation(_ city: City) {
        viewModel.userLocation = city.location
        locationLabel.text = city.name
    }
    
    func useCurrentLocation() {
        locationManager.requestLocation()
    }
}

// MARK: - Collection Data Source
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = WeatherSection(rawValue: indexPath.section) else { fatalError("Unknown section") }
        
        switch section {
        case .segmentedControl:
            return segmentedControlCell(at: indexPath)
        case .forecast:
            return forecastCell(at: indexPath)
        case .celestial:
            return celestialCell(at: indexPath)
        case .generalData:
            return generalDataCell(at: indexPath)
        case .alert:
            return alertCell(at: indexPath)
        }
    }
}

// MARK: - Cells construction
extension MainViewController {
    func segmentedControlCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: SegmentedControlCell.self, at: indexPath)
        
        cell.configure(selectedIndex: viewModel.forecastType.rawValue)
        cell.$selectedForecastType
            .sink { [weak self] selectedForecastType in
                guard let self, selectedForecastType != self.viewModel.forecastType else { return }
                self.viewModel.forecastType = selectedForecastType
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: WeatherSection.forecast.rawValue))
                }
            }
            .store(in: &subscriptions)
        
        return cell
    }
    
    func forecastCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: ForecastCell.self, at: indexPath)
        let data = viewModel.forecastData(at: indexPath.item)
        cell.configure(with: data)
        return cell
    }
    
    func celestialCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: CelestialCell.self, at: indexPath)
        cell.configure(with: viewModel.celestialData, and: viewModel.userTimezone)
        return cell
    }
    
    func generalDataCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: GeneralDataCell.self, at: indexPath)
        guard let dataSection = GeneralDataSection(rawValue: indexPath.item),
              let data = viewModel.data(for: dataSection) else { return cell }
        cell.configure(with: data)
        return cell
    }
    
    func alertCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: AlertCell.self, at: indexPath)
        guard let data = viewModel.alertData(at: indexPath.item) else { return cell }
        cell.configure(with: data)
        return cell
    }
}

// MARK: - Compositional layout
private extension MainViewController {
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [unowned self] (section, _) -> NSCollectionLayoutSection? in
            guard let sectionType = WeatherSection(rawValue: section) else { return nil }
            switch sectionType {
            case .segmentedControl:
                return self.singleElementSection(groupHeight: 35)
            case .forecast:
                return self.forecastSection()
            case .celestial:
                return self.singleElementSection(groupHeight: 250)
            case .generalData:
                return self.generalDataSection()
            case .alert:
                return self.singleElementSection(groupHeight: 120, isScrollable: true)
            }
        }
    }
    
    func forecastSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.22), heightDimension: .fractionalWidth(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 15, bottom: 15, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 10)
        
        return section
    }
    
    func singleElementSection(groupHeight: CGFloat = 100, isScrollable: Bool = false) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: isScrollable ? .fractionalWidth(0.85) : .fractionalWidth(1), heightDimension: .estimated(groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = isScrollable ? .init(top: 0, leading: 0, bottom: 0, trailing: 10) : .zero
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 10, bottom: 15, trailing: 10)
        
        if isScrollable {
            section.orthogonalScrollingBehavior = .groupPagingCentered
        }
        
        return section
    }
    
    func generalDataSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.55))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 10)
        
        return section
    }
}
