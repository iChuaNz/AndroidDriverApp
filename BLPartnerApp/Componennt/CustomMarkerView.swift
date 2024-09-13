//
//  CustomMarkerView.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 10/09/24.
//

import Foundation
import UIKit
import GoogleMaps

class CustomMarkerView: UIView {
    private let iconImageView = UIImageView()
    private let label = UILabel()

    init(iconName: String, numberOfPassengers: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        setupView(iconName: iconName, numberOfPassengers: numberOfPassengers)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(iconName: String, numberOfPassengers: String) {
        self.backgroundColor = .clear

        // Set up the icon image view
        if let iconImage = UIImage(named: iconName) {
            iconImageView.image = iconImage
            iconImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            iconImageView.contentMode = .scaleAspectFit
            self.addSubview(iconImageView)
        }

        // Set up the label
        label.text = numberOfPassengers
        label.textColor = .black
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.frame = CGRect(x: 0, y: 0, width: 30, height: 20) // Adjust position as needed
        label.center = CGPoint(x: iconImageView.bounds.midX, y: iconImageView.bounds.midY - 6)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        self.addSubview(label)
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
