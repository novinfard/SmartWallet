//
//  AddCategoryViewController.swift
//  SmartWallet
//
//  Created by Soheil on 28/02/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

enum CategoryType {
	case categoryTypeCost
	case categoryTypeIncome
	case categoryTypeAll
}

class AddCategoryViewController: UIViewController {

	@IBOutlet weak var categoryNameInput: UITextField!
	@IBOutlet weak var categoryTypeInput: UISegmentedControl!

	var currentUid = ""
	var category: Categories!

	override func viewDidLoad() {
        super.viewDidLoad()

		category = Facade.share.model.getOrCreateCategory(uid: currentUid)
		var defaultDirection = UserDefaults.standard.integer(forKey: "DirectionInAddCategories")
		if category.uid == "" {
			// default initialisation for new category
		} else {
			// manipulate fields with current object data
			categoryNameInput.text = category.name
			if category.direction == 1 {
				defaultDirection = 1
			} else {
				defaultDirection = 0
			}
		}
		categoryTypeInput.selectedSegmentIndex = defaultDirection

    }

	@IBAction func addCategoryPressed(_ sender: Any) {
		guard categoryNameInput.text != "" else {
			let alert = UIAlertController(title: "Error", message: "You should enter the name", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}

		if category.uid == "" {
			category.uid = Facade.share.model.getNewUID()
		}

		if categoryTypeInput.selectedSegmentIndex == 0 {
			category.direction = -1
		} else {
			category.direction = 1
		}
		category.name = categoryNameInput.text!

		Facade.share.model.saveContext()

		category.sortId = category.getAutoIncremenet()
		Facade.share.model.saveContext()

		navigationController?.popViewController(animated: true)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if category.uid == "" {
			Facade.share.model.container.viewContext.delete(category)
			Facade.share.model.saveContext()
		}
	}
}
