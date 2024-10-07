import Foundation
import UIKit
import GoogleMaps

class CustomMarkerView: UIView {
    private let iconImageView = UIImageView()
    private let passengerLabel = UILabel()
    private let titleLabel = UILabel() // New label for the title

    init(iconName: String, numberOfPassengers: String = "", title: String = "") {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 80)) // Adjust height to accommodate the new label
        setupView(iconName: iconName, numberOfPassengers: numberOfPassengers, title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(iconName: String, numberOfPassengers: String, title: String) {
        self.backgroundColor = .clear

        // Set up the icon image view
        if let iconImage = UIImage(named: iconName) {
            iconImageView.image = iconImage
            iconImageView.frame = CGRect(x: 0, y: 20, width: 60, height: 60) // Positioning below the title
            iconImageView.contentMode = .scaleAspectFit
            self.addSubview(iconImageView)
        }

        // Set up the title label
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.frame = CGRect(x: 0, y: 0, width: 60, height: 20) // Position above the icon
        titleLabel.layer.cornerRadius = 5
        titleLabel.clipsToBounds = true
        self.addSubview(titleLabel)

        // Set up the passenger label
        passengerLabel.text = numberOfPassengers
        passengerLabel.textColor = .black
        passengerLabel.backgroundColor = .clear
        passengerLabel.textAlignment = .center
        passengerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        passengerLabel.frame = CGRect(x: 0, y: iconImageView.frame.maxY + 5, width: 30, height: 20) // Position below the icon
        passengerLabel.center.x = iconImageView.center.x
        passengerLabel.layer.cornerRadius = 5
        passengerLabel.clipsToBounds = true
        self.addSubview(passengerLabel)
    }

    func asImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}
