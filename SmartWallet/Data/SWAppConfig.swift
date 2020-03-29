//
//  SWAppConfig.swift
//  SmartWallet
//
//  Created by Soheil on 29/03/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import Foundation

enum SWAppConfig {
	static var isSnapshot: Bool {
		return UserDefaults.standard.bool(forKey: UserDefaults.snapshotKey)
	}
}
