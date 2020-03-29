//
//  MainTabBarViewController.swift
//  SmartWallet
//
//  Created by Soheil on 23/01/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

	var freshLaunch = true

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if freshLaunch == true {
			freshLaunch = false
			self.selectedIndex = 1 // second tab
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.showSplashScreen()
	}

	private func showSplashScreen() {
		guard UserDefaults.standard.bool(forKey: "introduced") == false ||
			SWAppConfig.isSnapshot else {
				return
		}
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		guard let splashVC = storyboard.instantiateViewController(
			withIdentifier: "splashController"
			) as? SplashViewController else {
			return
		}
		if SWAppConfig.isSnapshot {
			Facade.share.model.addSampleData()
		}
		present(splashVC, animated: false)
	}
}
