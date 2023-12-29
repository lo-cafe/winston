//
//  CGGradient.swift
//  SmoothCGGradient
//
//  Created by Jansel Valentin on 5/13/16.
//  Copyright © 2016 Jansel Valentin. All rights reserved.
//

import UIKit

extension CGGradient{
    
    class func with(_ colors:[UIColor],_ locations:[CGFloat]) -> CGGradient{
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map{$0.cgColor} as CFArray, locations: locations)!
    }
    
    private class func with(_ colors:[CGColor],_ locations:[CGFloat]) -> CGGradient{
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)!
    }
    
    class func with(easing: Easing, from c1: UIColor, to c2: UIColor) -> CGGradient{
        var colors    = [CGColor]()
        var locations = [CGFloat]()
        let samples = 24
        
        func interpolateColor(at percent:CGFloat) -> CGColor {
            var r1:CGFloat = 0.0, g1:CGFloat = 0.0, b1:CGFloat = 0.0, a1:CGFloat = 0.0
            var r2:CGFloat = 0.0, g2:CGFloat = 0.0, b2:CGFloat = 0.0, a2:CGFloat = 0.0
            
            if 4 == c1.cgColor.components?.count{
                c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            }else{
                c1.getWhite(&r1, alpha: &a1)
                b1 = r1; g1 = r1
            }
            
            if 4 == c2.cgColor.components?.count{
                c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
            }else{
                c2.getWhite(&r2, alpha: &a2)
                b2 = r2; g2 = r2
            }
            
            let r = BezierCurve(t: percent, p0: r1, p1: r2)
            let g = BezierCurve(t: percent, p0: g1, p1: g2)
            let b = BezierCurve(t: percent, p0: b1, p1: b2)
            let a = BezierCurve(t: percent, p0: a1, p1: a2)
            
            return UIColor(red: r, green: g, blue: b, alpha: a).cgColor
        }
        
        
        for i in 0...samples {
            let tt = CGFloat(i)/CGFloat(samples)
            
            // calculate t based on easing function provided
            let t = easing.invoke(tt, 0.0, 1, 1)
            
            locations.append(tt)
            colors.append(interpolateColor(at: t))
        }
        return with(colors, locations)
    }
}

fileprivate func BezierCurve(t:CGFloat, p0:CGFloat, p1:CGFloat) -> CGFloat{
    return (1.0 - t) * p0 + t * p1;
}


