//
//  RadialAnimationView.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 10/09/24.
//

import Foundation
import UIKit

class RadialWaveAnimationView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let waveLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupWave()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.blue.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.addSublayer(gradientLayer)
    }
    
    private func setupWave() {
        let radius = self.bounds.width / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius),
                                radius: radius,
                                startAngle: 0,
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        
        waveLayer.path = path.cgPath
        waveLayer.fillColor = UIColor.clear.cgColor
        waveLayer.strokeColor = UIColor.blue.cgColor
        waveLayer.lineWidth = 2
        waveLayer.opacity = 0.5
        self.layer.addSublayer(waveLayer)
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 1.5
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        waveLayer.add(animation, forKey: "wave")
    }
}
