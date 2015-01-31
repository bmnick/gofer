//
//  FlatButton.swift
//  Gofer
//
//  Created by Ben Nicholas on 1/30/15.
//  Copyright (c) 2015 Ben Nicholas. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class FlatButton: UIButton {
    
    // MARK: - configuration
    @IBInspectable var topColor: UIColor = UIColor(red: 0.365, green: 0.251, blue: 0.216, alpha: 1.0)
    @IBInspectable var bottomColor: UIColor = UIColor(red: 0.243, green: 0.153, blue: 0.137, alpha: 1.0)
    
    // MARK: - Sublayers
    var _topLayer: CAShapeLayer?
    var topLayer: CAShapeLayer {
        get {
            if let layer = _topLayer {
                return layer
            } else {
                let layer = CAShapeLayer()
                
                layer.path = CGPathCreateWithRoundedRect(CGRectOffset(CGRectInset(bounds, 0, 5), 0, -5), 6.0, 6.0, nil)
                layer.fillColor = topColor.CGColor
                
                _topLayer = layer
                
                return layer
            }
        }
    }
    
    var _shadowLayer: CAShapeLayer?
    var shadowLayer: CAShapeLayer {
        get {
            if let layer = _shadowLayer {
                return layer
            } else {
                let layer = CAShapeLayer()
                
                layer.path = CGPathCreateWithRoundedRect(CGRectOffset(CGRectInset(bounds, 0, 30), 0, 30), 6.0, 6.0, nil)
                layer.fillColor = bottomColor.CGColor
                
                _shadowLayer = layer
                
                return layer
            }
        }
    }
    
    var _textLayer: CATextLayer?
    var textLayer: CATextLayer {
        get {
            if let layer = _textLayer {
                return layer
            } else {
                let layer = CATextLayer()
                
                layer.string = currentTitle
                layer.font = CGFontCreateWithFontName("Futura-CondensedExtraBold")
                layer.fontSize = 35.0
                layer.foregroundColor = UIColor.whiteColor().CGColor
                layer.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                
                _textLayer = layer
                
                return layer
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        shadowLayer.path = CGPathCreateWithRoundedRect(CGRectOffset(CGRectInset(bounds, 0, 30), 0, 30), 6.0, 6.0, nil)
        topLayer.path = CGPathCreateWithRoundedRect(CGRectOffset(CGRectInset(bounds, 0, 5), 0, -5), 6.0, 6.0, nil)
        textLayer.position = CGPoint(
            x: (CGRectGetWidth(bounds)) / 2,
            y: (CGRectGetHeight(bounds) - CGRectGetHeight(textLayer.frame)) / 2)
//        textLayer.frame = bounds

    }

    // MARK: -
    override func awakeFromNib() {
        layer.addSublayer(shadowLayer)
        layer.addSublayer(topLayer)
        layer.addSublayer(textLayer)
        titleLabel?.removeFromSuperview()
    }
    
    override func prepareForInterfaceBuilder() {
        layer.addSublayer(shadowLayer)
        layer.addSublayer(topLayer)
        layer.addSublayer(textLayer)
    }
    
    override var highlighted: Bool {
        didSet {
            var translation: CGAffineTransform
            
            if highlighted {
                translation = CGAffineTransformMakeTranslation(0, 10)
            } else {
                translation = CGAffineTransformIdentity
            }
            
            topLayer.setAffineTransform(translation)
            textLayer.setAffineTransform(translation)
            textLayer.foregroundColor = UIColor(white: 1.0, alpha: highlighted ? 0.5 : 1.0).CGColor
        }
    }
}
