//
//  AddCategoryViewController.swift
//  SmartWallet
//
//  Created by Soheil on 28/02/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

class AddCategoryViewController: UIViewController {

	@IBOutlet weak var categoryNameInput: UITextField!
	
	@IBOutlet weak var categoryTypeInput: UISegmentedControl!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func addCategoryPressed(_ sender: Any) {
		let cvc: CategoriesViewController = CategoriesViewController()
		let categoryName = categoryNameInput.text!
		let categoryType: Int16
		if categoryTypeInput.selectedSegmentIndex == 0 {
			categoryType = -1
		} else {
			categoryType = 1
		}
		
		cvc.addCategory(name: categoryName, direction: categoryType)
		
		navigationController?.popViewController(animated: true)
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
