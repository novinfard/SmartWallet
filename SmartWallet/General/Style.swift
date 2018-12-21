//
//  Style.swift
//  SmartWallet
//
//  Created by Soheil on 09/03/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

class Style {
	enum TextStyle {
		case navigationBar
		case title
		case subtitle
		case body
		case button
	}

	struct TextAttributes {
		let font: UIFont
		let color: UIColor
		let backgroundColor: UIColor?

		init(font: UIFont, color: UIColor, backgroundColor: UIColor? = nil) {
			self.font = font
			self.color = color
			self.backgroundColor = backgroundColor
		}
	}

	// MARK: - General Properties
	let backgroundColor: UIColor
	let preferredStatusBarStyle: UIStatusBarStyle

	let attributesForStyle: (_ style: TextStyle) -> TextAttributes

	init(backgroundColor: UIColor,
		 preferredStatusBarStyle: UIStatusBarStyle = .default,
		 attributesForStyle: @escaping (_ style: TextStyle) -> TextAttributes) {
		self.backgroundColor = backgroundColor
		self.preferredStatusBarStyle = preferredStatusBarStyle
		self.attributesForStyle = attributesForStyle
	}

	// MARK: - Convenience Getters
	func font(for style: TextStyle) -> UIFont {
		return attributesForStyle(style).font
	}

	func color(for style: TextStyle) -> UIColor {
		return attributesForStyle(style).color
	}

	func backgroundColor(for style: TextStyle) -> UIColor? {
		return attributesForStyle(style).backgroundColor
	}

	// MARK: - Apply Styles to UI Elements
	func apply(textStyle: TextStyle, to label: UILabel) {
		let attributes = attributesForStyle(textStyle)
		label.font = attributes.font
		label.textColor = attributes.color
		label.backgroundColor = attributes.backgroundColor
	}

	func apply(textStyle: TextStyle = .button, to button: UIButton) {
		let attributes = attributesForStyle(textStyle)
		button.setTitleColor(attributes.color, for: .normal)
		button.titleLabel?.font = attributes.font
		button.backgroundColor = attributes.backgroundColor
	}

	func apply(textStyle: TextStyle = .navigationBar, to navigationBar: UINavigationBar) {
		let attributes = attributesForStyle(textStyle)
		navigationBar.titleTextAttributes = [
			NSAttributedString.Key.font: attributes.font,
			NSAttributedString.Key.foregroundColor: attributes.color
		]

		if let color = attributes.backgroundColor {
			navigationBar.barTintColor = color
		}

		navigationBar.tintColor = attributes.color
		navigationBar.barStyle = preferredStatusBarStyle == .default ? .default : .black
	}
}
