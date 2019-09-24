//
//  UICollection+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 08/06/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

extension Collection {

	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
