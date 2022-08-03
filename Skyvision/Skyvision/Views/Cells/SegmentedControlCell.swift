//
//  SegmentedControlCell.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 11.07.2022.
//

import UIKit

class SegmentedControlCell: UICollectionViewCell {
    // MARK: - Private properties
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var underlineView: UIView!
    @IBOutlet private var underlineWidth: NSLayoutConstraint!
    
    private var underlineXPosition: CGFloat {
        return (segmentedControl.bounds.width / CGFloat(segmentedControl.numberOfSegments)) * CGFloat(segmentedControl.selectedSegmentIndex) + 15
    }
    
    // MARK: - Public properties
    @Published var selectedForecastType: ForecastType = .daily
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSegmentedControl()
    }
    
    func configure(selectedIndex: Int) {
        segmentedControl.selectedSegmentIndex = selectedIndex
        segmentedValueChanged(segmentedControl)
    }
}

// MARK: - Segmented control setup
private extension SegmentedControlCell {
    private func setupSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                 NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 14)!], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                                                 NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 14)!], for: .selected)
        
        let tintColorImage = UIImage(color: .clear, size: CGSize(width: 1, height: 32))
        segmentedControl.setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        segmentedControl.selectedSegmentIndex = 0
        underlineWidth.constant = contentView.bounds.size.width / CGFloat(segmentedControl.numberOfSegments)
        underlineView.frame.origin.x = underlineXPosition
    }
    
    @objc private func segmentedValueChanged(_ sender: UISegmentedControl!) {
        UIView.animate(withDuration: 0.35, animations: {
            self.underlineView.frame.origin.x = self.underlineXPosition
        })
        
        switch sender.selectedSegmentIndex {
        case 0:
            selectedForecastType = .daily
        default:
            selectedForecastType = .hourly
        }
    }
}
