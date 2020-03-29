//
//  AddCategoryViewController.swift
//  SmartWallet
//
//  Created by Soheil on 28/02/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import FontAwesome

enum CategoryType {
	case categoryTypeCost
	case categoryTypeIncome
	case categoryTypeAll
}

class AddCategoryViewController: UIViewController {

	@IBOutlet weak var categoryNameInput: UITextField!
	@IBOutlet weak var categoryTypeInput: UISegmentedControl!

	@IBOutlet private var iconCoverView: UIView? {
		didSet {
			self.iconCoverView?.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
			self.iconCoverView?.layer.borderColor = UIColor.gray.cgColor
			self.iconCoverView?.layer.borderWidth = 2
		}
	}

	@IBOutlet private var iconView: UIImageView?

	var currentIcon: FontAwesome? {
		didSet {
			guard let currentIcon = currentIcon else { return }
			self.iconView?.image = UIImage.SWFontIcon(name: currentIcon)
		}
	}

	var currentUid = ""
	var category: Categories!

	override func viewDidLoad() {
        super.viewDidLoad()

		category = Facade.share.model.getOrCreateCategory(uid: currentUid)
		var defaultDirection = UserDefaults.standard.integer(forKey: "DirectionInAddCategories")
		if category.uid == "" {
			// default initialisation for new category
			self.currentIcon = FontAwesome.stream
		} else {
			// manipulate fields with current object data
			self.currentIcon = FontAwesome(rawValue: category.icon)
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
		category.icon = currentIcon?.rawValue ?? ""

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

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let iconSelectorVC = segue.destination as? SWIconSelectorViewController else { return }
		iconSelectorVC.delegate = self
		iconSelectorVC.selectedFont = currentIcon
	}
}

extension AddCategoryViewController: IconSelectorDelegate {
	func iconSelected(icon: FontAwesome?) {
		self.currentIcon = icon
	}
}
