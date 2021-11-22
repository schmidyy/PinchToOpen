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
	enum Measurments {
		static let textFieldHeight: CGFloat = 52
		static let verticalPadding: CGFloat = 24
		static let horizontalPadding: CGFloat = 18
	}
	
	var transitionManager: UIViewControllerTransitioningDelegate?
	
	weak var delegate: ModalControllerDelegate?
	var heightConstraint: NSLayoutConstraint!
	
	let textField: UITextField = {
		let textField = UITextField()
		textField.font = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: .current)
		textField.minimumFontSize = 16
		textField.textColor = .white
		textField.clearButtonMode = .whileEditing
		textField.borderStyle = .none
		textField.attributedPlaceholder = NSAttributedString(
			string: "Type a command or keyboard",
			attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
		)
		
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
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
		view.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.99)
		view.layer.cornerRadius = 20
		
		attachPinchGesture(for: .dismissal(host: self))
		
		view.addSubview(textField)
		NSLayoutConstraint.activate([
			textField.topAnchor.constraint(equalTo: view.topAnchor, constant: Measurments.verticalPadding),
			textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(2 * Measurments.horizontalPadding)),
			textField.heightAnchor.constraint(equalToConstant: Measurments.textFieldHeight)
		])
		
		heightConstraint = view.heightAnchor.constraint(equalToConstant: Measurments.textFieldHeight + (2 * Measurments.verticalPadding))
		heightConstraint.isActive = true
		
		textField.becomeFirstResponder()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let bottomLine = CALayer()
		bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 1, width: textField.frame.width, height: 1)
		bottomLine.backgroundColor = UIColor.white.cgColor
		textField.layer.addSublayer(bottomLine)
	}
	
	@objc private func buttonTapped() {
		let generator = UIImpactFeedbackGenerator(style: .heavy)
		generator.impactOccurred()
		
		delegate?.close(self)
	}
	
	func shouldExpandScreen() {
		heightConstraint.isActive = false
		heightConstraint = view.heightAnchor.constraint(equalToConstant: 280)
		heightConstraint.isActive = true
		
		view.addSubview(closeButton)
		NSLayoutConstraint.activate([
			closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Measurments.verticalPadding)
		])
		
		resizeIfNeeded(animated: true)
	}
}
