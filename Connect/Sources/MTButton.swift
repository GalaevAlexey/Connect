//
//  MTButton.swift
//  Connect
//
//  Created by Alexey Galaev on 11/17/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public class MTButton: UIButton {
    
    // MARK: Public interface
    /// Corner radius of the background rectangle
    public var roundRectCornerRadius: CGFloat = 2 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var activeColor: UIColor = uicolorFromHex(rgbValue: 0xfcb022) {
        didSet {
            self.setNeedsLayout()
        }
    }
    public var highlitenColor: UIColor = uicolorFromHex(rgbValue: 0xffc949) {
        didSet {
            self.setNeedsLayout()
        }
    }
    public var disabledColor: UIColor = uicolorFromHex(rgbValue: 0x454545) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: Overrides
    override public func layoutSubviews() {
        self.adjustsImageWhenHighlighted = false
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    // MARK: Private
    private var roundRectLayer: CAShapeLayer?
    
    private func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).cgPath
        shapeLayer.fillColor = self.isEnabled ? activeColor.cgColor : disabledColor.cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }
}

