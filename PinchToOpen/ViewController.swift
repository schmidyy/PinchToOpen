//
//  ViewController.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-13.
//

import UIKit

class ViewController: UIViewController {
	let infoLabel: UILabel = {
		let label = UILabel()
		label.text = "Try pinching out!"
		return label
	}()
	
	let infoButton: UIButton = {
		let button = UIButton(configuration: .plain(), primaryAction: nil)
		button.setTitle("Or tap to open", for: .normal)
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		return button
	}()
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
	var pinchToPresent: PinchToPresentInteractionController?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(white: 0.95, alpha: 1)
		setNeedsStatusBarAppearanceUpdate()
		
		title = "Pinch to open"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		let stackView = UIStackView(arrangedSubviews: [infoLabel, infoButton])
		stackView.axis = .vertical
		stackView.spacing = 40
		
		view.addSubview(stackView)
		stackView.center(in: view)
		
		attachPinchGesture(for: .presentation(parent: self))
	}
	
	@objc private func buttonTapped() {
		let generator = UIImpactFeedbackGenerator(style: .heavy)
		generator.impactOccurred()
		presentModal()
	}
}

extension ViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

extension ViewController: ModalControllerDelegate {
	func close(_ viewController: ModalController) {
		viewController.dismiss(animated: true)
	}
}
