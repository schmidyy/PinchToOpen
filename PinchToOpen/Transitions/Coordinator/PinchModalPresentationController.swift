//
//  PinchModalPresentationController.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

class PinchModalPresentationController: UIPresentationController {
	lazy var dimmedView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		view.alpha = 0.3
		return view
	}()
	
	override func presentationTransitionWillBegin() {
		guard let containerView = containerView else { return }
		containerView.insertSubview(dimmedView, at: 0)
		dimmedView.fill(containerView)
		
		guard let coordinator = presentedViewController.transitionCoordinator else {
			dimmedView.alpha = 1.0
			return
		}

		coordinator.animate(alongsideTransition: { _ in
			self.dimmedView.alpha = 1.0
		})
	}
	
	override func dismissalTransitionWillBegin() {
		guard let coordinator = presentedViewController.transitionCoordinator else {
			dimmedView.alpha = 0.0
			return
		}

		if coordinator.isInteractive == false {
			coordinator.animate(alongsideTransition: { _ in
				self.dimmedView.alpha = 0.0
			})
		}
	}
	
	override func containerViewWillLayoutSubviews() {
		presentedView?.frame = frameOfPresentedViewInContainerView
	}
	
	override var frameOfPresentedViewInContainerView: CGRect {
		guard let containerView = containerView, let presentedView = presentedView else { return .zero }

		let inset: CGFloat = 16
		let safeAreaFrame = containerView.bounds.inset(by: containerView.safeAreaInsets)

		let targetWidth = safeAreaFrame.width - (2 * inset)
		let fittingSize = CGSize(
			width: targetWidth,
			height: UIView.layoutFittingCompressedSize.height
		)
		
		let targetHeight = presentedView.systemLayoutSizeFitting(
			fittingSize,
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .defaultLow
		).height

		var frame = safeAreaFrame
		frame.origin.x += inset
		frame.origin.y += 8.0
		frame.size.width = targetWidth
		frame.size.height = targetHeight

		return frame
	}
}
