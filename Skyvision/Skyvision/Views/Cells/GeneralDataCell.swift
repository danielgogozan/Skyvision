//
//  GeneralDataCell.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 11.07.2022.
//

import UIKit
import WeatherKit

enum GeneralDataInfo {
    case temperature(temperature: Measurement<UnitTemperature>, condition: WeatherCondition)
    case uv(uvIndex: UVIndex)
    case precipitation(precipitation: Precipitation, precipitationChance: Double)
    case wind(wind: Wind)
    case air(visibility: Measurement<UnitLength>, dewPoint: Measurement<UnitTemperature>, humidity: Double)
    case pressure(pressure: Measurement<UnitPressure>, pressureTrend: PressureTrend)
}

class GeneralDataCell: UICollectionViewCell {
    // MARK: - Private properties
    @IBOutlet private weak var titleStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleIcon: UIImageView!
    @IBOutlet private weak var emphasizedImageView: UIImageView!
    @IBOutlet private weak var emphasizedValueLabel: UILabel!
    @IBOutlet private weak var emphasizedDescriptionLabel: UILabel!
    @IBOutlet private weak var extraInfoLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 20
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addBlurEffect()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        emphasizedImageView.isHidden = true
        emphasizedValueLabel.isHidden = false
        emphasizedDescriptionLabel.isHidden = false
        extraInfoLabel.isHidden = false
    }
    
    private var data: GeneralDataInfo?
    
    // MARK: - Public API
    func configure(with info: GeneralDataInfo) {
        self.data = info
        
        switch info {
        case .temperature(let temperature, let condition):
            temperatureView(temperature, condition)
        case .uv(let uvIndex):
            uvView(uvIndex)
        case .precipitation(let precipitation, let precipitationChance):
            precipitationView(precipitation, precipitationChance)
        case .wind(let wind):
            windView(wind)
        case .air(let visibility, let dewPoint, let humidity):
            airView(visibility, dewPoint, humidity)
        case .pressure(let pressure, let pressureTrend):
            pressureView(pressure, pressureTrend)
        }
    }
}

// MARK: - View setup
private extension GeneralDataCell {
    func temperatureView(_ temperature: Measurement<UnitTemperature>, _ condition: WeatherCondition) {
        titleLabel.text = "Apparent temperature"
        titleIcon.image = GeneralDataSection.temperature.icon
        emphasizedImageView.image = Resources.shared.contitionIcon(condition: condition)
        emphasizedValueLabel.text = temperature.value.fancy + temperature.unit.symbol
        emphasizedDescriptionLabel.text = condition.description
        
        emphasizedImageView.isHidden = false
        extraInfoLabel.isHidden = true
    }
    
    func uvView(_ uvIndex: UVIndex) {
        titleLabel.text = "UV"
        titleIcon.image = GeneralDataSection.uv.icon
        emphasizedValueLabel.text = uvIndex.value.description
        emphasizedDescriptionLabel.text = uvIndex.category.description
        extraInfoLabel.isHidden = true
    }
    
    func precipitationView(_ precipitation: Precipitation, _ precipitationChance: Double) {
        titleLabel.text = "Precipitations"
        titleIcon.image = GeneralDataSection.precipitation.icon
        emphasizedImageView.image = Resources.shared.precipitationIcon(precipitation: precipitation)
        emphasizedDescriptionLabel.text = precipitation.description
        extraInfoLabel.text = precipitationChance == 0 ? "No precipitation chances" : "\(precipitationChance.percent) precipitation chances"
        
        emphasizedImageView.isHidden = false
        emphasizedValueLabel.isHidden = true
    }
    
    func windView(_ wind: Wind) {
        titleLabel.text = "Wind"
        titleIcon.image = GeneralDataSection.wind.icon
        emphasizedValueLabel.text = Int(wind.direction.value).description + wind.direction.unit.symbol + " " + wind.compassDirection.abbreviation
        emphasizedDescriptionLabel.text = wind.speed.converted(to: .kilometersPerHour).description
        
        if let gust = wind.gust {
            extraInfoLabel.text = "Gust of \(gust.converted(to: .kilometersPerHour).description)"
        }
    }
    
    func airView(_ visibility: Measurement<UnitLength>, _ dewPoint: Measurement<UnitTemperature>, _ humidity: Double) {
        titleLabel.text = "Air humidity"
        titleIcon.image = GeneralDataSection.air.icon
        emphasizedValueLabel.text = humidity.percent
        emphasizedDescriptionLabel.text = "Visibility up to \(visibility.converted(to: .kilometers).value.fancy) km"
        extraInfoLabel.text = "Dewpoint is \(dewPoint.description)"
    }
    
    func pressureView(_ pressure: Measurement<UnitPressure>, _ pressureTrend: PressureTrend) {
        titleLabel.text = "Pressure"
        titleIcon.image = GeneralDataSection.pressure.icon
        emphasizedValueLabel.text = Int(pressure.value).description
        emphasizedDescriptionLabel.text = pressure.unit.symbol
        extraInfoLabel.text = pressureTrend.description.description
    }
}
