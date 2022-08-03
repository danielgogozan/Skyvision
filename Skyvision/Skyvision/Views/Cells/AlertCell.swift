//
//  AlertCell.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 19.07.2022.
//

import UIKit
import WeatherKit

class AlertCell: UICollectionViewCell {
    // MARK: - Private properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    @IBOutlet private weak var severityLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    
    private var alert: WeatherAlert?
    
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
        alert = nil
    }
    
    // MARK: - Public API
    func configure(with alert: WeatherAlert) {
        self.alert = alert
        
        titleLabel.text = alert.region ?? "Unknown region alert"
        summaryLabel.text = alert.summary
        severityLabel.text = "\(alert.severity.description) threat to life"
        sourceLabel.text = alert.source
    }
    
    @IBAction
    private func onLearnMoreTapped(_ sender: Any?) {
        guard let alert else { return }
        UIApplication.shared.open(alert.detailsURL)
    }
}
