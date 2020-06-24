//
//  PrevisionSourceTableViewCell.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-05.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class PrevisionSourceTableViewCell: UITableViewCell {
  
  //MARK: Properties
  
  @IBOutlet weak var vueIconeMeteo: UIImageView!
  @IBOutlet weak var etiquetteSource: UILabel!
  @IBOutlet weak var etiquetteTemperature: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
