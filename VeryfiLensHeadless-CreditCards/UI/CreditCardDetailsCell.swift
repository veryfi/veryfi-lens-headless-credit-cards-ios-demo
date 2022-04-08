//
//  CreditCardDetailsCellTableViewCell.swift
//  Lens-Demo
//
//  Created by Alex Levnikov on 4/4/22.
//  Copyright © 2022 Veryfi. All rights reserved.
//

import UIKit

class CreditCardDetailsCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var text: String = "" {
        didSet {
            textField.text = text
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        text = ""
        title = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
