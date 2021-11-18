//
//  ModalController.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-13.
//

import UIKit

protocol ModalControllerDelegate: AnyObject {
	func close(_ viewController: ModalController)
}

class ModalController: UIViewController, PinchPresentable {
	var transitionManager: UIViewControllerTransitioningDelegate?
	
	weak var delegate: ModalControllerDelegate?
	
	let closeButton: UIButton = .make(
		contentColor: .white,
		backgroundColor: .clear,
		title: "Tap to close",
		textFormat: (17, .bold),
		height: 50,
		cornerRadius: 25,
		padding: 16,
		style: .outline,
		targetSelector: (self, #selector(buttonTapped))
	)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemCyan
		view.layer.cornerRadius = 20
		
		view.addSubview(closeButton)
		closeButton.center(in: view)
		
		view.heightAnchor.constraint(equalToConstant: 200).isActive = true
	}
	
	@objc private func buttonTapped() {
		delegate?.close(self)
	}
}
