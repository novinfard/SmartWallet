//
//  AppDelegate.swift
//  SmartWallet
//
//  Created by Soheil on 21/01/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		_ = Facade.share
		Fabric.with([Crashlytics.self])
		
		StoreReviewHelper.incrementAppOpenedCount()
		self.afterUpdateProcess()

		return true
	}

	private func afterUpdateProcess() {
		switch SWAppUpdate.status {
		case .updated(_, let current):
			if current.isVersion(lessThanOrEqualTo: "1.1") {
				PersistentModel.sharedInstance.updateGeneralCategoriesIfNeeded()
			}
		default:
			break
		}
	}

}
