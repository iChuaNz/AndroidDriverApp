//
//  ScheduledViewCell.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 16/08/24.
//

import UIKit

class ScheduledViewCell: UITableViewCell {
    @IBOutlet weak var timeGoLabel: UILabel!
    @IBOutlet weak var startPlace: UILabel!
    @IBOutlet weak var arrivedTimeLabel: UILabel!
    @IBOutlet weak var finishLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(jobsData: JobsData) {
        
    }
    
}
