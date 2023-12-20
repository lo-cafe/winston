//
//  EaseFunction.swift
//  EaseFunction
//
//  Created by Jansel Valentin on 5/13/16.
//  Copyright © 2016 Jansel Valentin. All rights reserved.
//

import Foundation
import UIKit

protocol EaseFunction {
    func invoke(_ t:CGFloat, _ b:CGFloat, _ c:CGFloat, _ d:CGFloat) -> CGFloat
}

typealias LerpFunction = (_ t:CGFloat, _ b:CGFloat, _ c:CGFloat, _ d:CGFloat) -> CGFloat

struct Easing : EaseFunction {
    
    private let lerp: LerpFunction
    
    init(_ lerp: @escaping LerpFunction){
        self.lerp = lerp
    }
    
    func invoke(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> CGFloat {
        return lerp(t, b, c, d)
    }
    
    // linear
    static let easeInLinear    = Easing { (t,b,c,d) -> CGFloat in
        return c*(t/d)+b
    }
    static let easeOutLinear   = Easing { (t,b,c,d) -> CGFloat in
        return c*(t/d)+b
    }
    static let easeInOutLinear = Easing { (t,b,c,d) -> CGFloat in
        return c*(t/d)+b
    }
    
    // quad
    static let easeInQuad   = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d
        return c*t*t + b
    }
    static let easeOutQuad  = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d
        return -c * t*(t-2) + b
    }
    static let easeInOutQuad = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t/(d/2)
        if t < 1 {
            return c/2*t*t + b;
        }
        let t1 = t-1
        let t2 = t1-2
        return -c/2 * ((t1)*(t2) - 1) + b;
    }
    
    // cubic
    static let easeInCubic   = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d
        return c*t*t*t + b
    }
    static let easeOutCubic   = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d-1
        return c*(t*t*t + 1) + b
    }
    static let easeInOutCubic = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t/(d/2)
        if t < 1{
            return c/2*t*t*t + b;
        }
        t -= 2
        return c/2*(t*t*t + 2) + b;
    }
    
    // quart
    static let easeInQuart   = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d
        return c*t*t*t*t + b
    }
    static let easeOutQuart  = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d-1
        return -c * (t*t*t*t - 1) + b
    }
    static let easeInOutQuart = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t/(d/2)
        
        if t < 1{
            return c/2*t*t*t*t + b;
        }
        t -= 2
        return -c/2 * (t*t*t*t - 2) + b;
    }
    
    // quint
    static let easeInQuint     = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d
        return c*t*t*t*t*t + b
    }
    static let easeOutQuint    = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d-1
        return c*(t*t*t*t*t + 1) + b
    }
    static let easeInOutQuint  = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t/(d/2)
        if t < 1 {
            return c/2*t*t*t*t*t + b;
        }
        t -= 2
        return c/2*(t*t*t*t*t + 2) + b;
    }
    
    // back
    static let easeInBack    = Easing { (_t,b,c,d) -> CGFloat in
        let s:CGFloat = 1.70158
        let t = _t/d
        return c*t*t*((s+1)*t - s) + b
    }
    static let easeOutBack   = Easing { (_t,b,c,d) -> CGFloat in
        let s:CGFloat = 1.70158
        let t = _t/d-1
        return c*(t*t*((s+1)*t + s) + 1) + b
    }
    static let easeInOutBack = Easing { (_t,b,c,d) -> CGFloat in
        var s:CGFloat = 1.70158
        var t = _t/(d/2)
        if t < 1{
            s *= (1.525)
            return c/2*(t*t*((s+1)*t - s)) + b;
        }
        s *= 1.525
        t -= 2
        return c/2*(t*t*((s+1)*t + s) + 2) + b;
    }
    
    // bounce
    static let easeInBounce    = Easing { (t,b,c,d) -> CGFloat in
        return c - easeOutBounce.invoke(d-t, b, c, d) + b
    }
    static let easeOutBounce   = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t/d
        if t < (1/2.75){
            return c*(7.5625*t*t) + b;
        } else if t < (2/2.75) {
            t -= 1.5/2.75
            return c*(7.5625*t*t + 0.75) + b;
        } else if t < (2.5/2.75) {
            t -= 2.25/2.75
            return c*(7.5625*t*t + 0.9375) + b;
        } else {
            t -= 2.625/2.75
            return c*(7.5625*t*t + 0.984375) + b;
        }
    }
    static let easeInOutBounce = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t
        if t < d/2{
            return easeInBounce.invoke(t*2, 0, c, d) * 0.5 + b
        }
        return easeOutBounce.invoke (t*2-d, 0, c, d) * 0.5 + c*0.5 + b
    }
    
    
    // circ
    static let easeInCirc    = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d
        return -c * (sqrt(1 - t*t) - 1) + b
    }
    static let easeOutCirc   = Easing { (_t,b,c,d) -> CGFloat in
        let t = _t/d-1
        return c * sqrt(1 - t*t) + b
    }
    static let easeInOutCirc = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t/(d/2)
        if t < 1{
            return -c/2 * (sqrt(1 - t*t) - 1) + b;
        }
        t -= 2
        return c/2 * (sqrt(1 - t*t) + 1) + b;
    }
    
    // elastic
    static var easeInElastic    = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t
        
        if t==0{ return b }
        t/=d
        if t==1{ return b+c }
        
        let p = d * 0.3
        let a = c
        let s = p/4
        
        t -= 1
        return -(a*pow(2,10*t) * sin( (t*d-s)*(2*CGFloat.pi)/p )) + b;
    }
    static let easeOutElastic   = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t
        
        if t==0{ return b }
        t/=d
        if t==1{ return b+c}
        
        let p = d * 0.3
        let a = c
        let s = p/4
        
        return (a*pow(2,-10*t) * sin( (t*d-s)*(2*CGFloat.pi)/p ) + c + b);
    }
    static let easeInOutElastic = Easing { (_t,b,c,d) -> CGFloat in
        var t = _t
        if t==0{ return b}
        
        t = t/(d/2)
        if t==2{ return b+c }
        
        let p = d * (0.3*1.5)
        let a = c
        let s = p/4
        
        if t < 1 {
            t -= 1
            return -0.5*(a*pow(2,10*t) * sin((t*d-s)*(2*CGFloat.pi)/p )) + b;
        }
        t -= 1
        return a*pow(2,-10*t) * sin( (t*d-s)*(2*CGFloat.pi)/p )*0.5 + c + b;
    }
    
    // expo
    static let easeInExpo    = Easing { (_t,b,c,d) -> CGFloat in
        return (_t==0) ? b : c * pow(2, 10 * (_t/d - 1)) + b
    }
    static let easeOutExpo   = Easing { (_t,b,c,d) -> CGFloat in
        return (_t==d) ? b+c : c * (-pow(2, -10 * _t/d) + 1) + b
    }
    static let easeInOutExpo = Easing { (_t,b,c,d) -> CGFloat in
        if _t==0{ return b }
        if _t==d{ return b+c}
        
        var t = _t/(d/2)
        
        if t < 1{
            return c/2 * pow(2, 10 * (_t - 1)) + b;
        }
        let t1 = t-1
        return c/2 * (-pow(2, -10 * t1) + 2) + b;
    }
    
    // sine
    static let easeInSine    = Easing { (_t,b,c,d) -> CGFloat in
        return -c * cos(_t/d * (CGFloat.pi/2)) + c + b
    }
    static let easeOutSine   = Easing { (_t,b,c,d) -> CGFloat in
        return c * sin(_t/d * (CGFloat.pi/2)) + b
    }
    static let easeInOutSine = Easing { (_t,b,c,d) -> CGFloat in
        return -c/2 * (cos(CGFloat.pi*_t/d) - 1) + b
    }
}
