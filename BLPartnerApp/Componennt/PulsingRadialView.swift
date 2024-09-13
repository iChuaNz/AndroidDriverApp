//
//  PulsingRadialView.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 10/09/24.
//

import UIKit

class PulsingView: UIView {
    init() {
        super.init(frame: .zero)
        layer.addSublayer(pulsingLayer)
        layer.addSublayer(mainLayer)
        pulsingLayer.add(animationGroup, forKey: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var animationGroup: CAAnimationGroup = {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [expandingAnimation,
                                     fadingAnimation]
        animationGroup.duration = 1.5
        animationGroup.repeatCount = .infinity
        return animationGroup
    }()
    
    private lazy var fadingAnimation: CABasicAnimation = {
        let fadingAnimation = CABasicAnimation(keyPath: "opacity")
        fadingAnimation.fromValue = 1
        fadingAnimation.toValue = 0
        return fadingAnimation
    }()
    
    private lazy var expandingAnimation: CABasicAnimation = {
        let expandingAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandingAnimation.fromValue = 1
        expandingAnimation.toValue = 1.4
        return expandingAnimation
    }()
    
    private let mainLayer: CAShapeLayer = circleLayer(color: UIColor.gray.cgColor)
    private let pulsingLayer: CAShapeLayer = circleLayer(color: UIColor.darkGray.cgColor)
    
    private static func circleLayer(color: CGColor) -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
        circleLayer.path = Constant.bezierPath.cgPath
        circleLayer.lineWidth = 4
        circleLayer.strokeColor = color
        circleLayer.fillColor = UIColor.clear.cgColor
        return circleLayer
    }
    
    private enum Constant {
        static let bezierPath: UIBezierPath = .init(arcCenter: CGPoint.zero,
                                                    radius: 20,
                                                    startAngle: -(CGFloat.pi / 2),
                                                    endAngle: -(CGFloat.pi / 2) + (2 * CGFloat.pi),
                                                    clockwise: true)
        static let mainColor: CGColor = UIColor(red: 0.12,
                                                green: 0.56,
                                                blue: 1,
                                                alpha: 1).cgColor
        static let pulsingColor: CGColor = UIColor(red: 0,
                                                   green: 0.75,
                                                   blue: 1,
                                                   alpha: 1).cgColor
    }
}
