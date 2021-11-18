//
//  PinchModalAnimator.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

class PinchModalAnimator: NSObject {
	private let presenting: Bool
	
	init(presenting: Bool) {
		self.presenting = presenting
		super.init()
	}
}

extension PinchModalAnimator: UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.5
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if presenting {
			animatePresentation(using: transitionContext)
		} else {
			animateDismissal(using: transitionContext)
		}
	}
	
	private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
		guard let presentedViewController = transitionContext.viewController(forKey: .to) else { return }
		transitionContext.containerView.addSubview(presentedViewController.view)
		
		let presentedFrame = transitionContext.finalFrame(for: presentedViewController)
		let dismissedFrame = CGRect(
			x: transitionContext.containerView.bounds.width / 2,
			y: transitionContext.containerView.bounds.height / 2,
			width: 0,
			height: 0
		)
		
//		let dismissedFrame = CGRect(
//			x: presentedFrame.minX,
//			y: transitionContext.containerView.bounds.height,
//			width: presentedFrame.width,
//			height: presentedFrame.height
//		)
		
		presentedViewController.view.frame = dismissedFrame
		presentedViewController.view.alpha = 0
		let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), dampingRatio: 1.0) {
			presentedViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
			presentedViewController.view.frame = presentedFrame
			presentedViewController.view.alpha = 1
		}

		animator.addCompletion { _ in
			presentedViewController.view.transform = CGAffineTransform.identity
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}

		animator.startAnimation()
	}
	
	private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
		let presentedViewController = transitionContext.viewController(forKey: .from)!
		
		let dismissedFrame = CGRect(
			x: transitionContext.containerView.bounds.width / 2,
			y: transitionContext.containerView.bounds.height / 2,
			width: 0,
			height: 0
		)
		
		presentedViewController.view.alpha = 1
		let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), dampingRatio: 1.0) {
			presentedViewController.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
			presentedViewController.view.frame = dismissedFrame
			presentedViewController.view.alpha = 0
		}

		animator.addCompletion { _ in
			presentedViewController.view.transform = .identity
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}

		animator.startAnimation()
	}
}
