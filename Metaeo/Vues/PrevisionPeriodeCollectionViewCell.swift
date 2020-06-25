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
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
}
