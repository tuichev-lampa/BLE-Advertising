//
//  TestTableViewCell.swift
//  BLE test
//
//  Created by Novotarskii Oleksiy on 11/26/20.
//

import UIKit

class TestTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
    }
    
}
