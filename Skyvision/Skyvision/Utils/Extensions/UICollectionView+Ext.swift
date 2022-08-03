//
//  UICollectionView+Ext.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 11.07.2022.
//

import UIKit

// MARK: - Register/dequeue cells/supplymentary views
extension UICollectionView {
    
    func registerCell<T: UICollectionViewCell>(ofType type: T.Type) {
        let reuseIdentifier = reuseIdentifier(ofType: type)
        register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func dequeueCell<T: UICollectionViewCell>(ofType type: T.Type, at indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier(ofType: type), for: indexPath) as? T else {
            fatalError("Couldn't dequeue cell with \(reuseIdentifier(ofType: type))")
        }
        return cell
    }
    
    func dequeueSupplementaryView<T: UICollectionReusableView>(ofType type: T.Type, kind: String, at indexPath: IndexPath) -> T {
        guard let header = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier(ofType: type), for: indexPath) as? T else {
            fatalError("Couldn't dequeue reusable view with identifier: \(reuseIdentifier(ofType: type))")
        }
        return header
    }
    
    func registerHeader<T: UICollectionReusableView>(ofType type: T.Type) {
        let reuseIdentifier = reuseIdentifier(ofType: type)
        register(UINib.init(nibName: reuseIdentifier, bundle: nil),
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: reuseIdentifier)
    }
    
    func reuseIdentifier<T>(ofType type: T.Type) -> String {
        return String(describing: type)
    }
    
}
