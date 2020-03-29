//
//  SWIconSelectorViewController.swift
//  SmartWallet
//
//  Created by Soheil on 28/03/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import UIKit
import FontAwesome

protocol IconSelectorDelegate: AnyObject {
	func iconSelected(icon: FontAwesome?)
}

class SWIconSelectorViewController: UIViewController {
	@IBOutlet weak var iconCollectionView: UICollectionView!
	weak var delegate: IconSelectorDelegate?

	let fontStyle = SWIconConfig.style
	let fontColor = SWIconConfig.color
	lazy var fontList = FontAwesome.fontList(style: self.fontStyle)

	let selectedColor = UIColor.green.withAlphaComponent(0.1)
	let deselectedColor = UIColor.white

	var selectedFont: FontAwesome?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.iconCollectionView.delegate = self
		self.iconCollectionView.dataSource = self
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.delegate?.iconSelected(icon: selectedFont)
	}
}

extension SWIconSelectorViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedFont = self.fontList[indexPath.row]
		dismiss(animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		if let cell = collectionView.cellForItem(at: indexPath) {
			cell.contentView.backgroundColor = selectedColor
		}
	}

	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		if let cell = collectionView.cellForItem(at: indexPath) {
			cell.contentView.backgroundColor = deselectedColor
		}
	}

}

extension SWIconSelectorViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return fontList.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = self.iconCollectionView.dequeueReusableCell(withReuseIdentifier: "gallery", for: indexPath) as! SWIconCollectionCell

		let fontItem = self.fontList[indexPath.row]

		cell.iconView.image = UIImage.fontAwesomeIcon(
			name: fontItem,
			style: fontStyle,
			textColor: fontColor,
			size: CGSize(width: 35, height: 35)
		)

		let isSelected = fontItem == selectedFont
		cell.contentView.backgroundColor = isSelected ? selectedColor : deselectedColor

		return cell
	}

}
