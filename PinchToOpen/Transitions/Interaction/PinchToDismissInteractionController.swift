//
//  PinchToDismissInteractionController.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

class PinchToDismissInteractionController: NSObject, InteractionControlling {
	var interactionInProgress = false
	
	private var currentScale: CGFloat = 1 {
		didSet {
			currentScale = currentScale.bounded(within: 0...1)
		}
	}
	private var initialFrame: CGRect?
	private var cancellationAnimator: UIViewPropertyAnimator?
	
	private weak var viewController: PinchPresentable!
	private weak var transitionContext: UIViewControllerContextTransitioning?
	
	init(viewController: PinchPresentable) {
		self.viewController = viewController
		super.init()
		
		preparePinchGesture(in: viewController.view)
		// TODO: Add pan gesture
		// TODO: Handle scroll view
	}
	
	private func preparePinchGesture(in view: UIView) {
		let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
		view.addGestureRecognizer(gesture)
	}
	
	@objc private func handlePinch(_ gestureRecognizer : UIPinchGestureRecognizer) {
		switch gestureRecognizer.state {
		case .began:
			gestureBegan()
			gestureRecognizer.scale = 1
		case .changed:
			gestureChanged(scale: gestureRecognizer.scale, velocity: gestureRecognizer.velocity)
			gestureRecognizer.scale = 1
		case .cancelled:
			gestureCancelled(velocity: gestureRecognizer.velocity)
		case .ended:
			gestureEnded(scale: gestureRecognizer.scale, velocity: gestureRecognizer.velocity)
		default:
			break
		}
	}
	
	private func gestureBegan() {
		disableOtherTouches()
		cancellationAnimator?.stopAnimation(true)

		if !interactionInProgress {
			interactionInProgress = true
			viewController.dismiss(animated: true)
		}
	}
	
	private func gestureChanged(scale: CGFloat, velocity: CGFloat) {
		let delta = 1 - scale
		currentScale -= delta
		let progress = 1 - currentScale
		update(progress: progress.bounded(within: 0...1))
		// TODO: Adjust progress to ease out when transition is nearing the end
	}
	
	private func gestureCancelled(velocity: CGFloat) {
		cancel(initialVelocity: velocity)
	}
	
	private func gestureEnded(scale: CGFloat, velocity: CGFloat) {
		if scale <= 1 {
			finish(initialVelocity: velocity)
		} else {
			cancel(initialVelocity: velocity)
		}
	}
	
	// MARK: - Transition controlling
	func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		guard let presentedViewController = transitionContext.viewController(forKey: .from) else { return }
		initialFrame = transitionContext.initialFrame(for: presentedViewController)
		self.transitionContext = transitionContext
	}
	
	func update(progress: CGFloat) {
		guard let transitionContext = transitionContext, let initialFrame = initialFrame else { return }
		transitionContext.updateInteractiveTransition(progress)
		guard let presentedViewController = transitionContext.viewController(forKey: .from) else { return }
		presentedViewController.view.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
		presentedViewController.view.alpha = currentScale
		presentedViewController.view.frame.origin.y = yOfsetOfFrameFor(
			progress: progress,
			initialFrame: initialFrame,
			containerView: transitionContext.containerView
		)
		
		if let modalPresentationController = presentedViewController.presentationController as? PinchModalPresentationController {
			modalPresentationController.dimmedView.alpha = 1.0 - progress
		}
	}
	
	func cancel(initialVelocity: CGFloat) {
		guard let transitionContext = transitionContext, let initialFrame = initialFrame else { return }
		guard let presentedViewController = transitionContext.viewController(forKey: .from) else { return }
		
		let timingParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: initialVelocity))
		cancellationAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timingParameters)

		cancellationAnimator?.addAnimations {
			presentedViewController.view.frame = initialFrame
			if let modalPresentationController = presentedViewController.presentationController as? PinchModalPresentationController {
				modalPresentationController.dimmedView.alpha = 1.0
			}
		}

		cancellationAnimator?.addCompletion { _ in
			transitionContext.cancelInteractiveTransition()
			transitionContext.completeTransition(false)
			self.interactionInProgress = false
			self.enableOtherTouches()
		}

		cancellationAnimator?.startAnimation()
	}
	
	func finish(initialVelocity: CGFloat) {
		guard let transitionContext = transitionContext else { return }
		guard let presentedViewController = transitionContext.viewController(forKey: .from) as? PinchPresentable else { return }
		
		let dismissedFrame = CGRect(
			x: transitionContext.containerView.bounds.width / 2,
			y: transitionContext.containerView.bounds.height / 2,
			width: 0,
			height: 0
		)

		let timingParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: initialVelocity))
		let finishAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timingParameters)

		finishAnimator.addAnimations {
			presentedViewController.view.frame = dismissedFrame
			if let modalPresentationController = presentedViewController.presentationController as? PinchModalPresentationController {
				modalPresentationController.dimmedView.alpha = 0.0
			}
		}

		finishAnimator.addCompletion { _ in
			transitionContext.finishInteractiveTransition()
			transitionContext.completeTransition(true)
			self.interactionInProgress = false
		}

		finishAnimator.startAnimation()
	}
	
	// MARK: - Helpers
	private func disableOtherTouches() {
		viewController.view.subviews.forEach {
			$0.isUserInteractionEnabled = false
		}
	}

	private func enableOtherTouches() {
		viewController.view.subviews.forEach {
			$0.isUserInteractionEnabled = true
		}
	}
	
	private func yOfsetOfFrameFor(progress: CGFloat, initialFrame: CGRect, containerView: UIView) -> CGFloat {
		let yDistanceBetweenInitialFrameAndEndFrame = (containerView.bounds.height / 2) - initialFrame.origin.y
		let distance = progress * yDistanceBetweenInitialFrameAndEndFrame
		return initialFrame.origin.y + distance
	}
}

extension CGFloat {
	func bounded(within range: ClosedRange<CGFloat>) -> CGFloat {
		if self > range.upperBound { return range.upperBound }
		if self < range.lowerBound { return range.lowerBound }
		return self
	}
}
