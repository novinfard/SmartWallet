//
//  Style+MyApp.swift
//  SmartWallet
//
//  Created by Soheil on 09/03/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

extension Style {
	static var myApp: Style {
		return Style(
			backgroundColor: .white,
			preferredStatusBarStyle: .lightContent,
			attributesForStyle: { $0.myAppAttributes }
		)
	}
}

private extension Style.TextStyle {
	var myAppAttributes: Style.TextAttributes {
		switch self {
		case .navigationBar:
			return Style.TextAttributes(font: .myAppTitle, color: .white, backgroundColor: .white)
		case .title:
			return Style.TextAttributes(font: .myAppTitle, color: .myAppGreen)
		case .subtitle:
			return Style.TextAttributes(font: .myAppSubtitle, color: .myAppBlue)
		case .body:
			return Style.TextAttributes(font: .myAppBody, color: .black, backgroundColor: .white)
		case .button:
			return Style.TextAttributes(font: .myAppSubtitle, color: .white, backgroundColor: .myAppBlack)
		}
	}
}

extension UIColor {
	static var myAppRed: UIColor {
		return UIColor(red: 1, green: 0.1, blue: 0.1, alpha: 1)
	}
	static var myAppGreen: UIColor {
		return UIColor(red: 10/255, green: 105/255, blue: 68/255, alpha: 1)
	}
	static var myAppBlue: UIColor {
		return UIColor(red: 0, green: 0.2, blue: 0.9, alpha: 1)
	}
	static var myAppLightGreen: UIColor {
		return UIColor(red: 0.880, green: 1.000, blue: 0.892, alpha: 1.0)
	}
	static var myAppLightOrange: UIColor {
		return UIColor(red: 1.000, green: 0.924, blue: 0.804, alpha: 1.0)
	}

	static var myAppBlack: UIColor {
		return .black
	}
}

extension UIFont {
	static var myAppTitle: UIFont {
		return UIFont.systemFont(ofSize: 17)
	}
	static var myAppSubtitle: UIFont {
		return UIFont.systemFont(ofSize: 15)
	}
	static var myAppBody: UIFont {
		return UIFont.systemFont(ofSize: 14)
	}
}
