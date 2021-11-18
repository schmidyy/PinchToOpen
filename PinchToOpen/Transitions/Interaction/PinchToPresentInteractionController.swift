//
//  PinchToPresentInteractionController.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

class PinchToPresentInteractionController: NSObject, InteractionControlling {
	typealias ModalViewControllerDelegate = UIViewController & ModalControllerDelegate
	
	var interactionInProgress = false
	
	private var currentScale: CGFloat = 0
	private var initialFrame: CGRect?
	private var finalFrame: CGRect?
	
	private var cancellationAnimator: UIViewPropertyAnimator?
	
	private weak var parentController: ModalViewControllerDelegate!
	private weak var modalController: PinchPresentable!
	private weak var transitionContext: UIViewControllerContextTransitioning?
	
	init(parentController: ModalViewControllerDelegate, modalController: PinchPresentable) {
		self.parentController = parentController
		self.modalController = modalController
		super.init()
		
		preparePinchGesture(in: parentController.view)
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
		
		print(currentScale)
	}
	
	func gestureBegan() {
		disableOtherTouches()
		cancellationAnimator?.stopAnimation(true)

		if !interactionInProgress {
			interactionInProgress = true
			parentController.presentModal()
		}
	}
	
	func gestureChanged(scale: CGFloat, velocity: CGFloat) {
		let delta = scale - 1
		currentScale += delta
		currentScale = max(0, min(1.05, currentScale))
		// TODO: Adjust progress to ease out when transition is nearing the end
		update(progress: max(0, min(1, currentScale)))
	}
	
	func gestureCancelled(velocity: CGFloat) {
		cancel(initialVelocity: velocity)
	}
	
	func gestureEnded(scale: CGFloat, velocity: CGFloat) {
		if scale <= 1 {
			finish(initialVelocity: velocity)
		} else {
			cancel(initialVelocity: velocity)
		}
	}
	
	// MARK: - Transition controlling
	func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		guard let presentedViewController = transitionContext.viewController(forKey: .to) else { return }
		initialFrame = transitionContext.initialFrame(for: presentedViewController)
		finalFrame = transitionContext.finalFrame(for: presentedViewController)
		self.transitionContext = transitionContext
	}
	
	func update(progress: CGFloat) {
		guard let transitionContext = transitionContext else { return }
		transitionContext.updateInteractiveTransition(progress)
		
		guard let presentedViewController = transitionContext.viewController(forKey: .to) else { return }
		presentedViewController.view.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
		presentedViewController.view.alpha = currentScale
		// TODO: Adjust view's `y` value towards the center of the screen here
		
		if let modalPresentationController = presentedViewController.presentationController as? PinchModalPresentationController {
			modalPresentationController.dimmedView.alpha =  progress
		}
	}
	
	func cancel(initialVelocity: CGFloat) {
		guard let transitionContext = transitionContext, let initialFrame = initialFrame else { return }
		guard let presentedViewController = transitionContext.viewController(forKey: .to) else { return }

		let timingParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: initialVelocity))
		cancellationAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timingParameters)

		cancellationAnimator?.addAnimations {
			presentedViewController.view.frame = initialFrame
			if let modalPresentationController = presentedViewController.presentationController as? PinchModalPresentationController {
				modalPresentationController.dimmedView.alpha = 0
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
		guard let presentedViewController = transitionContext.viewController(forKey: .to) as? PinchPresentable else { return }
		guard let finalFrame = finalFrame else { return }

		let timingParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: initialVelocity))
		let finishAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timingParameters)

		finishAnimator.addAnimations {
			presentedViewController.view.frame = finalFrame
			if let modalPresentationController = presentedViewController.presentationController as? PinchModalPresentationController {
				modalPresentationController.dimmedView.alpha = 1.0
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
		parentController.view.subviews.forEach {
			$0.isUserInteractionEnabled = false
		}
	}

	private func enableOtherTouches() {
		parentController.view.subviews.forEach {
			$0.isUserInteractionEnabled = true
		}
	}
}
