//
//  UIView+Extensions.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-13.
//

import UIKit

extension UIView {
	static func activate(constraints: [NSLayoutConstraint]) {
		constraints.forEach {
			($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
		}
		NSLayoutConstraint.activate(constraints)
	}
	
	func center(in view: UIView, offset: UIOffset = .zero) {
		UIView.activate(constraints: [
			centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.horizontal),
			centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.vertical)
		])
	}
	
	func fill(_ view: UIView, padding: UIEdgeInsets = .zero) {
		UIView.activate(constraints: [
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
			topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
			trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: padding.right),
			bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding.bottom)
		])
	}
}

enum ButtonStyle {
	case standard
	case outline
}

extension UIButton {
	static func make(
		image: UIImage? = nil,
		contentColor: UIColor? = nil,
		backgroundColor: UIColor = .clear,
		title: String? = nil,
		textFormat: (size: CGFloat, weight: UIFont.Weight)? = nil,
		width: CGFloat? = nil,
		height: CGFloat? = nil,
		cornerRadius: CGFloat = 0.0,
		padding: CGFloat = 0,
		style: ButtonStyle = .standard,
		targetSelector: (target: Any, action: Selector)? = nil
	) -> UIButton {
		
		let button = UIButton(type: .system)
		var configuration = UIButton.Configuration.plain()
		
		button.translatesAutoresizingMaskIntoConstraints = false
		if let image = image { button.setImage(image, for: .normal) }
		if let contentColor = contentColor {
			button.tintColor = contentColor
			button.setTitleColor(contentColor, for: .normal)
		}
		button.backgroundColor = backgroundColor
		if let title = title { button.setTitle(title, for: .normal) }
		if let textFormat = textFormat {
			button.titleLabel?.font = UIFont.systemFont(ofSize: textFormat.size, weight: textFormat.weight)
		}
		
		if let width = width { button.widthAnchor.constraint(equalToConstant: width).isActive = true }
		if let height = height { button.heightAnchor.constraint(equalToConstant: height).isActive = true }
		button.layer.cornerRadius = cornerRadius
		configuration.contentInsets = .init(top: 0.0, leading: padding, bottom: 0.0, trailing: padding)
		if let targetSelector = targetSelector { button.addTarget(targetSelector.target, action: targetSelector.action, for: .touchUpInside) }
		
		if image != nil && title != nil {
			configuration.contentInsets = .init(top: 0, leading: configuration.contentInsets.leading + 4, bottom: 0, trailing: configuration.contentInsets.trailing + 8)
			configuration.titlePadding = 4
		}
		
		if style == .outline {
			button.layer.borderColor = contentColor?.cgColor
			button.layer.borderWidth = 2.0
		}
		
		button.configuration = configuration
		return button
	}
}

extension UIView {
	static func make(
		backgroundColor: UIColor = .clear,
		alpha: CGFloat = 1.0,
		borderColor: UIColor = .clear,
		borderWidth: CGFloat = 0.0,
		height: CGFloat? = nil,
		width: CGFloat? = nil,
		cornerRadius: CGFloat = 0.0
	) -> UIView {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = backgroundColor
		view.alpha = alpha
		view.layer.borderColor = borderColor.cgColor
		view.layer.borderWidth = borderWidth
		view.layer.cornerRadius = cornerRadius
		if let height = height { view.heightAnchor.constraint(equalToConstant: height).isActive = true }
		if let width = width { view.widthAnchor.constraint(equalToConstant: width).isActive = true }
		return view
	}
}

