//
//  SWAppStatus.swift
//  SmartWallet
//
//  Created by Soheil on 05/01/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import Foundation

enum SWAppUpdate {
	case unknown
	case noUpdate(current: String)
	case updated(old: String, current: String)

	static var status: SWAppUpdate {
		let defaults = UserDefaults.standard

		guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
			return .unknown
		}

		let previousVersionMayNil = defaults.string(forKey: "appVersion")
		defaults.set(currentVersion, forKey: "appVersion")

		guard let previousVersion = previousVersionMayNil else {
			return .updated(old: "0", current: currentVersion)
		}

		if previousVersion == currentVersion {
			return .noUpdate(current: currentVersion)
		} else {
			return .updated(old: previousVersion, current: currentVersion)
		}
	}
}
