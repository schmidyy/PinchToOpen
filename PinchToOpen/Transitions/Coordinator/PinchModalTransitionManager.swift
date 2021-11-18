//
//  PinchModalTransitionManager.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

class PinchModalTransitionManager: NSObject {
	private var presentingInteractionController: InteractionControlling?
	private var dismissalInteractionController: InteractionControlling?

	init(presentingInteractionController: InteractionControlling?, dismissalInteractionController: InteractionControlling?) {
		self.presentingInteractionController = presentingInteractionController
		self.dismissalInteractionController = dismissalInteractionController
	}
}

extension PinchModalTransitionManager: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		PinchModalPresentationController(presentedViewController: presented, presenting: presenting)
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		PinchModalAnimator(presenting: true)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		PinchModalAnimator(presenting: false)
	}
	
	func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		guard let presentingInteractionController = presentingInteractionController, presentingInteractionController.interactionInProgress else {
			return nil
		}
		return presentingInteractionController
		// TODO: Implement
//		return nil
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		guard let dismissalInteractionController = dismissalInteractionController, dismissalInteractionController.interactionInProgress else {
			return nil
		}
		return dismissalInteractionController
	}
}
