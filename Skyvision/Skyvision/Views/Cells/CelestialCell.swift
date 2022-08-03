//
//  AirCell.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 11.07.2022.
//

import UIKit
import WeatherKit

class CelestialCell: UICollectionViewCell {
    typealias CelestialData = (sun: SunEvents, moon: MoonEvents)
    
    // MARK: - Private properties
    @IBOutlet private weak var moonPhaseLabel: UILabel!
    @IBOutlet private weak var moonriseLabel: UILabel!
    @IBOutlet private weak var moonsetLabel: UILabel!
    @IBOutlet private weak var moonPhaseIcon: UIImageView!
    @IBOutlet private weak var sunriseLabel: UILabel!
    @IBOutlet private weak var sunsetLabel: UILabel!
    @IBOutlet private weak var solarMidnightLabel: UILabel!
    @IBOutlet private weak var solarNoonLabel: UILabel!
    
    private var celestialData: CelestialData?
    private var timeZone: TimeZone = .current
    
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
        celestialData = nil
    }
    
    // MARK: - Public API
    func configure(with celestialData: CelestialData?, and timeZone: TimeZone) {
        self.celestialData = celestialData
        self.timeZone = timeZone
        setupViews()
    }
}

// MARK: - Private API
private extension CelestialCell {
    func setupViews() {
        guard let celestialData else { return }
        sunriseLabel.text = "Sunrise: \(celestialData.sun.sunrise?.hourAndMinutes(in: timeZone) ?? "--")"
        sunsetLabel.text = "Sunset: \(celestialData.sun.sunset?.hourAndMinutes(in: timeZone) ?? "--")"
        solarNoonLabel.text = "solar noon: \(celestialData.sun.solarNoon?.hourAndMinutes(in: timeZone) ?? "--")"
        solarMidnightLabel.text = "solar midnight: \(celestialData.sun.solarMidnight?.hourAndMinutes(in: timeZone) ?? "--")"
        
        moonPhaseLabel.text = celestialData.moon.phase.description
        moonPhaseIcon.image = Resources.shared.moonIcon(moonPhase: celestialData.moon.phase)
        moonriseLabel.text = "Moonrise: \(celestialData.moon.moonrise?.hourAndMinutes(in: timeZone) ?? "--")"
        moonsetLabel.text = "Moonset: \(celestialData.moon.moonset?.hourAndMinutes(in: timeZone) ?? "--")"
    }
}
