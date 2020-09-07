//
//  PrevisionPeriodeCollectionViewCell.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-24.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class PrevisionPeriodeCollectionViewCell: UICollectionViewCell {
  
  //MARK: Properties
  
  @IBOutlet weak var vueIconeMeteo: UIImageView!
  @IBOutlet weak var etiquettePeriode: UILabel!
  @IBOutlet weak var etiquetteTemperature: UILabel!
  
  override var isSelected: Bool {
    didSet {
      if self.isSelected {
        super.isSelected = true
        if #available(iOS 13.0, *) {
          self.contentView.backgroundColor = .secondarySystemGroupedBackground
        } else {
          // Fallback on earlier versions
          self.contentView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:0.7)
        }
      } else {
        super.isSelected = false
        if #available(iOS 13.0, *) {
          self.contentView.backgroundColor = .systemBackground
        } else {
          // Fallback on earlier versions
          self.contentView.backgroundColor = UIColor.white
        }
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  
}
