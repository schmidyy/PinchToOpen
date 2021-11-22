//
//  UIViewController+Pinch.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-22.
//

import UIKit

class PinchModalGesture: UIPinchGestureRecognizer {
	enum PresentationType {
		case presentation(parent: UIViewController & ModalControllerDelegate)
		case dismissal(host: PinchPresentable)
	}
	
	let presentationType: PresentationType
	var didDetectGesture = false
	
	init(presentationType: PresentationType, target: AnyObject, action: Selector) {
		self.presentationType = presentationType
		super.init(target: target, action: action)
	}
}

extension UIViewController {
	func attachPinchGesture(for presentationType: PinchModalGesture.PresentationType) {
		let pinchGesture = PinchModalGesture(presentationType: presentationType, target: self, action: #selector(handlePinch(_:)))
		view.addGestureRecognizer(pinchGesture)
	}
	
	@objc private func handlePinch(_ pinchGesture: PinchModalGesture) {
//		guard !pinchGesture.didDetectGesture else { return }
		
		switch pinchGesture.state {
		case .began, .changed:
			switch pinchGesture.presentationType {
			case .presentation(let parent):
				guard pinchGesture.scale > 1, !pinchGesture.didDetectGesture else { return }
				pinchGesture.didDetectGesture = true
				
				let generator = UIImpactFeedbackGenerator(style: .heavy)
				generator.impactOccurred()
				
				parent.presentModal()
			case .dismissal(let host):
				guard pinchGesture.scale < 1, !pinchGesture.didDetectGesture else { return }
				pinchGesture.didDetectGesture = true
				
				let generator = UIImpactFeedbackGenerator(style: .heavy)
				generator.impactOccurred()
				
				host.dismiss(animated: true)
			}
		case .ended, .cancelled:
			pinchGesture.didDetectGesture = false
		default:
			break
		}
	}
}
