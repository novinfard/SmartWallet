//
//  AddRecordViewController.swift
//  SmartWallet
//
//  Created by Soheil on 03/03/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import CoreData

class AddRecordViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

	@IBOutlet weak var directionSegmentedControl: UISegmentedControl!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var dateTextField: PickerBasedTextField!
	@IBOutlet weak var categoryTextField: PickerBasedTextField!
	@IBOutlet weak var accountTextField: UITextField!
	@IBOutlet weak var reportingSegmentedControl: UISegmentedControl!
	@IBOutlet weak var prefixLabel: UILabel!
	
	var container: NSPersistentContainer!
	var categoryPicker: UIPickerView!
	var accountPicker: UIPickerView!
	var accountsList: [Accounts] = []
	var expenseCategoriesList: [Categories] = []
	var incomeCategoriesList: [Categories] = []
	var record: Records!
	var currentUid = ""
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setupCategoriesList()
		setupAuthorList()
		
		
		record = Facade.share.model.getOrCreateRecord(uid: currentUid)
		var defaultDirection = UserDefaults.standard.integer(forKey: "DirectionInAddRecords")
		if record.uid == "" {
			if defaultDirection == 0 {
				record.relatedCategory = expenseCategoriesList[UserDefaults.standard.integer(forKey: "ExpenseInAddRecords")]
			} else {
				record.relatedCategory = incomeCategoriesList[UserDefaults.standard.integer(forKey: "IncomeInAddRecords")]
			}
			record.datetime = getDateOnlyFromDatetime(Date())
			
			record.relatedAccount = accountsList[UserDefaults.standard.integer(forKey: "AccountInAddRecords")]
		} else {
			amountTextField.text = String("\(record.amount.format(f: ".2"))")
			if record.direction == 1 {
				defaultDirection = 1
			} else {
				defaultDirection = 0
			}
		}
		
		// datePicker
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		dateTextField.text = formatter.string(from: record.datetime) 
		
		let datePicker: UIDatePicker = UIDatePicker()
		datePicker.datePickerMode = .date
		datePicker.backgroundColor = UIColor.white
		dateTextField.inputView = datePicker
		datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
		dateTextField.delegate = self
		
		let toolBar2 = UIToolbar()
		toolBar2.barStyle = UIBarStyle.default
		toolBar2.isTranslucent = true
		toolBar2.tintColor = UIColor.black
		toolBar2.sizeToFit()
		
		let doneButton2 = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddRecordViewController.donePicker))
		let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		toolBar2.setItems([spaceButton2, spaceButton2, doneButton2], animated: false)
		toolBar2.isUserInteractionEnabled = true
		dateTextField.inputAccessoryView = toolBar2
		
		let frame = self.view.frame
		
		// categoryPicker config
		let catFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 216)
		categoryPicker = UIPickerView(frame: catFrame)
		categoryPicker.backgroundColor = UIColor.white
		categoryPicker.dataSource = self
		categoryPicker.delegate = self
		categoryTextField.inputView = categoryPicker
		categoryTextField.delegate = self
		
		// directionField config
		directionSegmentedControl.addTarget(self, action: #selector(directionChanged(_:)), for: .valueChanged)
		directionSegmentedControl.selectedSegmentIndex = defaultDirection
		
		if directionSegmentedControl.selectedSegmentIndex == 0 {
			let defaultExpenseCategory = UserDefaults.standard.integer(forKey: "ExpenseInAddRecords")
			categoryTextField.text = (expenseCategoriesList.count > 0) ? record.relatedCategory.name : ""
			if defaultExpenseCategory <= categoryPicker.numberOfRows(inComponent: 0) {
				categoryPicker.selectRow(defaultExpenseCategory, inComponent: 0, animated: false)
			}
			prefixLabel.text = "-" + getCurrencyLabel()
			prefixLabel.textColor = UIColor.myAppRed
		} else {
			let defaultIncomeCategory = UserDefaults.standard.integer(forKey: "IncomeInAddRecords")
			categoryTextField.text = (incomeCategoriesList.count > 0) ? incomeCategoriesList[defaultIncomeCategory].name : ""
			if defaultIncomeCategory <= categoryPicker.numberOfRows(inComponent: 0) {
				categoryPicker.selectRow(defaultIncomeCategory, inComponent: 0, animated: false)
			}
			prefixLabel.text = "+" + getCurrencyLabel()
			prefixLabel.textColor = UIColor.myAppGreen
		}
		
		let toolBar = UIToolbar()
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = true
		toolBar.tintColor = UIColor.black
		toolBar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddRecordViewController.donePicker))
		let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		categoryTextField.inputAccessoryView = toolBar
		
		// accountPicker config
		let accFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 216)
		accountPicker = UIPickerView(frame: accFrame)
		accountPicker.dataSource = self
		accountPicker.delegate = self
		accountTextField.inputView = accountPicker
		accountTextField.delegate = self
		accountTextField.text = (accountsList.count > 0) ? accountsList[0].name : ""
		
		amountTextField.becomeFirstResponder()
		
    }
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return false
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField is PickerBasedTextField {
			let textField2 = textField as! PickerBasedTextField
			textField2.border.borderColor = UIColor.myAppBlue.cgColor
			textField2.textColor = UIColor.myAppBlue
		}
		
	}
	
	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
		if textField is PickerBasedTextField {
			let textField2 = textField as! PickerBasedTextField
			textField2.border.borderColor = UIColor.black.cgColor
			textField2.textColor = UIColor.black
		}

	}
	
	@IBAction func addRecordPressed(_ sender: Any) {
		// validation
		guard amountTextField.text != "" && amountTextField.text != "0" else {
			let alert = UIAlertController(title: "Error", message: "You should enter the amount", preferredStyle:.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
		
		if record.uid == "" {
			record.uid = Facade.share.model.getNewUID()
		}
		
		if directionSegmentedControl.selectedSegmentIndex == 0 {
			record.direction = -1
		} else {
			record.direction = 1
		}
		record.reported = (reportingSegmentedControl.selectedSegmentIndex == 0) ? true : false
		
//		let formatter = DateFormatter()
//		formatter.dateStyle = .medium
//		if let date = formatter.date(from: dateTextField.text!) {
//			record.datetime = date
//		}
		
		if let amountValue = Double(amountTextField.text!)
		{
			record.amount = amountValue
		} else {
			record.amount = 0
		}
		
		Facade.share.model.saveContext()
		
		navigationController?.popViewController(animated: true)
	}
	
	@objc func donePicker() {
		amountTextField.becomeFirstResponder()
	}
	
	@objc func directionChanged(_ sender: UISegmentedControl) {
		categoryPicker.reloadAllComponents()
		if directionSegmentedControl.selectedSegmentIndex == 0 {
			record.relatedCategory = expenseCategoriesList[categoryPicker.selectedRow(inComponent: 0)]
			categoryTextField.text = record.relatedCategory.name
			prefixLabel.text = "-" + getCurrencyLabel()
			prefixLabel.textColor = UIColor.myAppRed
		} else {
			record.relatedCategory = incomeCategoriesList[categoryPicker.selectedRow(inComponent: 0)]
			categoryTextField.text = record.relatedCategory.name
			prefixLabel.text = "+" + getCurrencyLabel()
			prefixLabel.textColor = UIColor.myAppGreen
		}
		
		UserDefaults.standard.set(directionSegmentedControl.selectedSegmentIndex, forKey: "DirectionInAddRecords")
	}
	
	public func setupCategoriesList(){
		do {
			let fetchRequest : NSFetchRequest<Categories> = Categories.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "direction == %d", 1)
			incomeCategoriesList = try Facade.share.model.container.viewContext.fetch(fetchRequest)
			
			fetchRequest.predicate = NSPredicate(format: "direction == %d", -1)
			expenseCategoriesList = try Facade.share.model.container.viewContext.fetch(fetchRequest)
		}
		catch {
			print ("fetch task failed", error)
		}
	}
	
	public func setupAuthorList(){
		do {
			let fetchRequest : NSFetchRequest<Accounts> = Accounts.createFetchRequest()
			accountsList = try Facade.share.model.container.viewContext.fetch(fetchRequest)
		}
		catch {
			print ("fetch task failed", error)
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == categoryPicker {
			if directionSegmentedControl.selectedSegmentIndex == 0 {
				return expenseCategoriesList.count
			} else {
				return incomeCategoriesList.count
			}
		} else if pickerView == accountPicker {
			return accountsList.count
		}
		
		return 0
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == categoryPicker {
			if directionSegmentedControl.selectedSegmentIndex == 0 {
				return expenseCategoriesList[row].name
			} else {
				return incomeCategoriesList[row].name
			}
		} else if pickerView == accountPicker {
			return accountsList[row].name
		}
		return ""
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == categoryPicker {
			record.direction = Int16(directionSegmentedControl.selectedSegmentIndex)
			if record.direction == 0 {
				record.relatedCategory = expenseCategoriesList[row]
				UserDefaults.standard.set(row, forKey: "ExpenseInAddRecords")
			} else {
				record.relatedCategory = incomeCategoriesList[row]
				UserDefaults.standard.set(row, forKey: "IncomeInAddRecords")
			}
			categoryTextField.text = record.relatedCategory.name
		}
		else if pickerView == accountPicker {
			record.relatedAccount = accountsList[row]
			accountTextField.text = record.relatedAccount.name
		}
	}
	
	@objc public func datePickerValueChanged(sender:UIDatePicker) {
		
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.dateStyle = DateFormatter.Style.medium
		dateFormatter.timeStyle = DateFormatter.Style.none
		record.datetime = getDateOnlyFromDatetime(sender.date)
		
		
		dateTextField.text = dateFormatter.string(from: record.datetime)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func saveContext() {
		if container.viewContext.hasChanges {
			do {
				try container.viewContext.save()
			} catch {
				print("An error occurred while saving: \(error)")
			}
		}
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
