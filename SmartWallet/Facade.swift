//
//  Facade.swift
//  SmartWallet
//
//  Created by Soheil on 04/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import Foundation

class Facade {
	static let share = Facade()
	let model = PersistentModel()

	private init() {
//		print("Facade - init")
	}
}
