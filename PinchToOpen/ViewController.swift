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
		label.textColor = .white
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
		view.backgroundColor = UIColor(white: 0.05, alpha: 1)
		setNeedsStatusBarAppearanceUpdate()
		
		let stackView = UIStackView(arrangedSubviews: [infoLabel, infoButton])
		stackView.axis = .vertical
		stackView.spacing = 40
		
		view.addSubview(stackView)
		stackView.center(in: view)
		
//		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//		pinchGesture.delegate = self
//		view.addGestureRecognizer(pinchGesture)
//
//		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//		panGesture.delegate = self
//		view.addGestureRecognizer(panGesture)
	}
	
	@objc private func buttonTapped() {
		presentModal()
	}
	
	@objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
		switch gestureRecognizer.state {
		case .began:
			let modalController = ModalController()
			pinchToPresent = PinchToPresentInteractionController(parentController: self, modalController: modalController)
			presentModal(presentingInteractionController: pinchToPresent)
			
			pinchToPresent?.gestureBegan()
			print("Pinch began: \(gestureRecognizer.scale)")
		case .changed:
			pinchToPresent?.gestureChanged(scale: gestureRecognizer.scale, velocity: gestureRecognizer.velocity)
			print("Pinch changed: \(gestureRecognizer.scale)")
		case .cancelled:
			pinchToPresent?.gestureCancelled(velocity: gestureRecognizer.velocity)
			pinchToPresent = nil
			print("Pinch cancelled: \(gestureRecognizer.scale)")
		case .ended:
			pinchToPresent?.gestureEnded(scale: gestureRecognizer.scale, velocity: gestureRecognizer.velocity)
			pinchToPresent = nil
			print("Pinch ended: \(gestureRecognizer.scale)")
		default:
			break
		}
		
		print("Pinch \(gestureRecognizer.state): \(gestureRecognizer.scale)")
	}
	
	@objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
		switch gestureRecognizer.state {
		case .began:
			print("Pan began: \(gestureRecognizer.translation(in: view))")
		case .changed:
			print("Pan changed: \(gestureRecognizer.translation(in: view))")
		case .ended:
			print("Pan ended: \(gestureRecognizer.translation(in: view))")
		default:
			break
		}
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
