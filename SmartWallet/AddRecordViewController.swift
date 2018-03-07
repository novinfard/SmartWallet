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
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var categoryTextField: UITextField!
	@IBOutlet weak var accountTextField: UITextField!
	@IBOutlet weak var reportingSegmentedControl: UISegmentedControl!
	
	var container: NSPersistentContainer!
	var categoryPicker: UIPickerView!
	var accountPicker: UIPickerView!
	var accountsList: [Accounts] = []
	var expenseCategoriesList: [Categories] = []
	var incomeCategoriesList: [Categories] = []
	
	@IBAction func addRecordPressed(_ sender: Any) {
		let record = Records(context: self.container.viewContext)
		if directionSegmentedControl.selectedSegmentIndex == 0 {
			record.direction = -1
			record.relatedCategory = expenseCategoriesList[categoryPicker.selectedRow(inComponent: 0)]
		} else {
			record.direction = 1
			record.relatedCategory = incomeCategoriesList[categoryPicker.selectedRow(inComponent: 0)]
		}
		record.relatedAccount = accountsList[accountPicker.selectedRow(inComponent: 0)]
		record.reported = (reportingSegmentedControl.selectedSegmentIndex == 0) ? true : false
		
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		if let date = formatter.date(from: dateTextField.text!) {
			record.datetime = date
		}
		
		if let amountValue = Double(amountTextField.text!)
		{
			record.amount = amountValue
		} else {
			record.amount = 0
		}
		
		record.uid = UUID().uuidString
		
		saveContext()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// initialise core data
		container = NSPersistentContainer(name: "WalletModel")
		
		container.loadPersistentStores { (storeDescription, error) in
			self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
			
			if let error = error {
				print("Unsolved error \(error.localizedDescription)")
			}
		}
		
		// datePicker
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		dateTextField.text = formatter.string(from: Date())
		
		let datePicker: UIDatePicker = UIDatePicker()
		datePicker.datePickerMode = .date
		dateTextField.inputView = datePicker
		datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
		dateTextField.delegate = self
		
		let frame = self.view.frame
		
		// categoryPicker config
		setupCategoriesList()
		let catFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 200)
		categoryPicker = UIPickerView(frame: catFrame)
		categoryPicker.dataSource = self
		categoryPicker.delegate = self
		categoryTextField.inputView = categoryPicker
		categoryTextField.delegate = self
		categoryTextField.text = (expenseCategoriesList.count > 0) ? expenseCategoriesList[0].name : ""
		
		// directionField config
		directionSegmentedControl.addTarget(self, action: #selector(directionChanged(_:)), for: .valueChanged)
		
		// accountPicker config
		setupAuthorList()
		let accFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 200)
		accountPicker = UIPickerView(frame: accFrame)
		accountPicker.dataSource = self
		accountPicker.delegate = self
		accountTextField.inputView = accountPicker
		accountTextField.delegate = self
		accountTextField.text = (accountsList.count > 0) ? accountsList[0].name : ""
		
    }
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return false
	}
	
	@objc func directionChanged(_ sender: UISegmentedControl) {
		categoryPicker.reloadAllComponents()
		if directionSegmentedControl.selectedSegmentIndex == 0 {
			categoryTextField.text = expenseCategoriesList[categoryPicker.selectedRow(inComponent: 0)].name
		} else {
			categoryTextField.text = incomeCategoriesList[categoryPicker.selectedRow(inComponent: 0)].name
		}
	}
	
	public func setupCategoriesList(){
		do {
			let fetchRequest : NSFetchRequest<Categories> = Categories.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "direction == %d", 1)
			incomeCategoriesList = try container.viewContext.fetch(fetchRequest)
			
			fetchRequest.predicate = NSPredicate(format: "direction == %d", -1)
			expenseCategoriesList = try container.viewContext.fetch(fetchRequest)
		}
		catch {
			print ("fetch task failed", error)
		}
	}
	
	public func setupAuthorList(){
		do {
			let fetchRequest : NSFetchRequest<Accounts> = Accounts.createFetchRequest()
			accountsList = try container.viewContext.fetch(fetchRequest)
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
			if directionSegmentedControl.selectedSegmentIndex == 0 {
				categoryTextField.text = expenseCategoriesList[row].name
			} else {
				categoryTextField.text = incomeCategoriesList[row].name
			}
		} else if pickerView == accountPicker {
			accountTextField.text = accountsList[row].name
		}
	}
	
	@objc public func datePickerValueChanged(sender:UIDatePicker) {
		
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.dateStyle = DateFormatter.Style.medium
		dateFormatter.timeStyle = DateFormatter.Style.none
		
		dateTextField.text = dateFormatter.string(from: sender.date)
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
