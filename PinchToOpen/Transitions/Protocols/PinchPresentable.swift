//
//  PinchPresentable.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

protocol PinchPresentable: UIViewController {
	var transitionManager: UIViewControllerTransitioningDelegate? { get set }
	var dismissalHandlingScrollView: UIScrollView? { get }
	
	/// Update presentation layout
	func resizeIfNeeded(animated: Bool)
}

extension PinchPresentable {
	var dismissalHandlingScrollView: UIScrollView? { nil }

	func resizeIfNeeded(animated: Bool = false) {
		presentationController?.containerView?.setNeedsLayout()
		if animated {
			UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
				self.presentationController?.containerView?.layoutIfNeeded()
			}, completion: nil)
		} else {
			presentationController?.containerView?.layoutIfNeeded()
		}
	}
}
