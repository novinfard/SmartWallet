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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if freshLaunch == true {
			freshLaunch = false
			self.selectedIndex = 1 // second tab
		}
	}
	
	override func viewDidLayoutSubviews() {
		if !UserDefaults.standard.bool(forKey: "introduced") {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let splashVC = storyboard.instantiateViewController(withIdentifier: "splashController") as! SplashViewController

			present(splashVC, animated: false)
		}
	}
		
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
