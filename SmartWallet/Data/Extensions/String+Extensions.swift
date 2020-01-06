//
//  String+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 03/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

extension String {
	func getDoubleFromLocal() -> Double {
		var value = 0.0
		let numberFormatter = NumberFormatter()
		let decimalFiltered = self.replacingOccurrences(of: "٫|,", with: ".", options: .regularExpression)
		numberFormatter.locale = Locale(identifier: "EN")
		if let amountValue = numberFormatter.number(from: decimalFiltered) {
			value = amountValue.doubleValue
		}
		return value
	}
}

extension String {

    /// Inner comparison utility to handle same versions with different length. (Ex: "1.0.0" & "1.0")
    private func compare(toVersion targetVersion: String) -> ComparisonResult {

        let versionDelimiter = "."
        var result: ComparisonResult = .orderedSame
        var versionComponents = components(separatedBy: versionDelimiter)
        var targetComponents = targetVersion.components(separatedBy: versionDelimiter)
        let spareCount = versionComponents.count - targetComponents.count

        if spareCount == 0 {
            result = compare(targetVersion, options: .numeric)
        } else {
            let spareZeros = repeatElement("0", count: abs(spareCount))
            if spareCount > 0 {
                targetComponents.append(contentsOf: spareZeros)
            } else {
                versionComponents.append(contentsOf: spareZeros)
            }
            result = versionComponents.joined(separator: versionDelimiter)
                .compare(targetComponents.joined(separator: versionDelimiter), options: .numeric)
        }
        return result
    }

    public func isVersion(equalTo targetVersion: String) -> Bool {
		return compare(toVersion: targetVersion) == .orderedSame
	}

    public func isVersion(greaterThan targetVersion: String) -> Bool {
		return compare(toVersion: targetVersion) == .orderedDescending
	}

    public func isVersion(greaterThanOrEqualTo targetVersion: String) -> Bool {
		return compare(toVersion: targetVersion) != .orderedAscending
	}

    public func isVersion(lessThan targetVersion: String) -> Bool {
		return compare(toVersion: targetVersion) == .orderedAscending
	}

    public func isVersion(lessThanOrEqualTo targetVersion: String) -> Bool {
		return compare(toVersion: targetVersion) != .orderedDescending
	}
}
