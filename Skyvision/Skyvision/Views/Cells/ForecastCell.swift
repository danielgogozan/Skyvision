//
//  ForecastCell.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 11.07.2022.
//

import UIKit

struct ForecastData {
    let date: String
    let icon: UIImage
    let precipitationChance: Double
    let hTemperature: Double?
    let lTemperature: Double?
    let apparentTemperature: Double?
    let isNow: Bool
}

class ForecastCell: UICollectionViewCell {
    // MARK: - Private properties
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var precipitationLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var hTemperatureLabel: UILabel!
    @IBOutlet private weak var lTemperatureLabel: UILabel!
    
    private var gradient: CAGradientLayer?
    private var forecastData: ForecastData?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = contentView.frame.width / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupContentView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        forecastData = nil
        gradient?.removeFromSuperlayer()
    }
    
    // MARK: - Public API
    func configure(with forecastData: ForecastData?) {
        guard let forecastData else { return }
        self.forecastData = forecastData
        forecastData.apparentTemperature == nil ? dayTypeView() : hourTypeView()
        
        if forecastData.isNow {
            setupViewWhenIsNow()
        }
    }
}

// MARK: - Private API
private extension ForecastCell {
    func setupContentView() {
        contentView.addBlurEffect()
    }
    
    func dayTypeView() {
        guard let forecastData else { return }
        dateLabel.text = forecastData.date
        iconImageView.image = forecastData.icon
        precipitationLabel.isHidden = forecastData.precipitationChance == 0
        precipitationLabel.text = "\(forecastData.precipitationChance.percent)"
        lTemperatureLabel.text = "L: \(Int(forecastData.lTemperature?.rounded() ?? 0))°C"
        hTemperatureLabel.text = "H: \(Int(forecastData.hTemperature?.rounded() ?? 0))°C"
        
        temperatureLabel.isHidden = true
        lTemperatureLabel.isHidden = false
        hTemperatureLabel.isHidden = false
    }
    
    func hourTypeView() {
        guard let forecastData else { return }
        dateLabel.text = forecastData.date
        iconImageView.image = forecastData.icon
        precipitationLabel.isHidden = forecastData.precipitationChance == 0
        precipitationLabel.text = "\(forecastData.precipitationChance.percent)"
        temperatureLabel.text = "\(Int(forecastData.apparentTemperature?.rounded() ?? 0).description)°C"
        
        temperatureLabel.isHidden = false
        lTemperatureLabel.isHidden = true
        hTemperatureLabel.isHidden = true
    }
    
    func setupViewWhenIsNow() {
        gradient = contentView.applyGradient(colours: [.blue, .systemPink])
    }
}
