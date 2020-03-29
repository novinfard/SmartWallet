//
//  Categories+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 05/01/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import CoreData
import UIKit
import FontAwesome

enum SWIconConfig {
	static let style: FontAwesomeStyle = .solid
	static let color: UIColor = .black
	static let defaultSize = CGSize(width: 128, height: 128)
}

extension UIImage {
	static func SWFontIcon(
		name: FontAwesome,
		size: CGSize = SWIconConfig.defaultSize) -> UIImage {

		return UIImage.fontAwesomeIcon(
			name: name,
			style: SWIconConfig.style,
			textColor: SWIconConfig.color,
			size: size
		)
	}
}

extension Categories {
	func iconImage(size: CGSize = SWIconConfig.defaultSize) -> UIImage? {
		guard !self.icon.isEmpty,
			let font = FontAwesome(rawValue: self.icon) else {
			let defaultIcon = self.direction > 0 ? "UpIcon" : "DownIcon"
			return UIImage(named: defaultIcon)
		}

		return UIImage.SWFontIcon(
			name: font,
			size: size
		)
	}
}
