//
//  SwipeableViewController.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 11.07.2022.
//

import UIKit

class SwipeableViewController: UIViewController {
    // MARK: - Private properties
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var dragView: UIView!
    @IBOutlet private weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contentBottomConstraint: NSLayoutConstraint!
    
    private let defaultHeight: CGFloat = 300
    private var maxHeight: CGFloat = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // hiding content view
        contentBottomConstraint.constant = -1 * contentHeightConstraint.constant
        setupPanGesture()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateContainerView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        maxHeight = view.safeAreaLayoutGuide.layoutFrame.height
        contentView.layer.cornerRadius = 25
    }
}

// MARK: - Setup UI
private extension SwipeableViewController {
    func setupUI() {
        contentView.addBlurEffect()
    }
}

// MARK: - Gestures
extension SwipeableViewController {
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        dragView.addGestureRecognizer(panGesture)
    }
    
    @objc
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        let newHeight = contentHeightConstraint.constant - translation.y
        
        switch gesture.state {
        case .changed:
            if newHeight < defaultHeight { break }
            
            if newHeight < maxHeight {
                contentHeightConstraint.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < defaultHeight {
                animateContainerHeight(newHeight: defaultHeight)
            } else if newHeight < maxHeight && isDraggingDown {
                animateContainerHeight(newHeight: defaultHeight)
            } else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(newHeight: maxHeight)
            }
        default:
            break
        }
    }
    
    @objc
    func dismissModal() {
        animateDismiss()
    }
}

// MARK: - Animations
extension SwipeableViewController {
    func animateContainerView() {
        UIView.animate(withDuration: 0.3) {
            self.contentBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateContainerHeight(newHeight height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.contentHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismiss() {
        UIView.animate(withDuration: 0.3) {
            self.contentBottomConstraint.constant = -1 * self.contentHeightConstraint.constant
            self.view.layoutIfNeeded()
        }
    }
}
