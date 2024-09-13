//
//  PulseAnimationView.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 10/09/24.
//

import Foundation
import UIKit

class PulseAnimationView: UIView {

    private let pulseLayer = CAShapeLayer()

    
    private let waveLayer = CAShapeLayer()
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        setupWave(color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWave(color: UIColor) {
        self.backgroundColor = .clear
        
        let radius = self.bounds.width / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius),
                                radius: radius,
                                startAngle: 0,
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        
        waveLayer.path = path.cgPath
        waveLayer.fillColor = color.cgColor
        waveLayer.opacity = 0.5
        self.layer.addSublayer(waveLayer)
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 2.0
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        waveLayer.add(animation, forKey: "wave")
    }
}

extension UIImageView {
    
    // Method to start a pulsing animation
    func startPulsatingAnimation(duration: CFTimeInterval = 1.5, scale: CGFloat = 1.2) {
        // Remove any existing animations
        self.layer.removeAllAnimations()
        
        // Create the scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = scale
        scaleAnimation.duration = duration
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        
        // Create the opacity animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = duration / 2
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        
        // Group both animations
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        animationGroup.duration = duration
        animationGroup.repeatCount = .infinity
        
        // Add the animation to the layer
        self.layer.add(animationGroup, forKey: "pulseAnimation")
    }
    
    // Method to stop the pulsating animation
    func stopPulsatingAnimation() {
        self.layer.removeAnimation(forKey: "pulseAnimation")
    }
}
