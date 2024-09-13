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
    @IBOutlet weak var titleLabel: UILabel!
    var allTrips: [AllTripsData]?
    @IBOutlet weak var vehicleNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(
        jobsData: Point?,
        endPoinnt: Point?,
        codeName: String = "",
        serviceType: String = "",
        vehicleNo: String = "-",
        duration: String = ""
    ) {
        vehicleNumber.text = "Vehicle No: " + vehicleNo
        startPlace.text = jobsData?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "").capitalized
        timeGoLabel.text = jobsData?.time
        finishLabel.text = endPoinnt?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "").capitalized
        arrivedTimeLabel.text = endPoinnt?.time
        if serviceType.lowercased() == "disposal" {
            self.titleLabel.text = codeName + " (\(duration)h \(serviceType))"
        } else {
            if serviceType.isEmpty == true {
                self.titleLabel.text = codeName
            } else {
                self.titleLabel.text = codeName + " (\(serviceType))"
            }
        }
    }
    
}
