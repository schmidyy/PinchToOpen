//
//  UIViewController+Transitions.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

extension ModalControllerDelegate where Self: UIViewController {
	func presentModal(presentingInteractionController: PinchToPresentInteractionController? = nil, completion: (() -> Void)? = nil) {
		let modalController = ModalController()
		let transitionManager = PinchModalTransitionManager(
			presentingInteractionController: presentingInteractionController,
			dismissalInteractionController: nil /*PinchToDismissInteractionController(
				viewController: modalController
			)*/
		)
		modalController.transitionManager = transitionManager
		modalController.transitioningDelegate = transitionManager
		modalController.delegate = self
		
		modalController.modalPresentationStyle = .custom
		present(modalController, animated: true) {
			modalController.shouldExpandScreen()
		}
	}
}
