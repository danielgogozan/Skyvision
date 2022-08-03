//
//  UIView+Ext.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 12.07.2022.
//

import UIKit

// MARK: - Customization
extension UIView {
    func addBlurEffect(blurEffectStyle: UIBlurEffect.Style = .light) {
        self.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: blurEffectStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurView, at: 0)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]? = nil) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}
