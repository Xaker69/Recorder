//
//  PlayButton.swift
//  voice recorder
//
//  Created by Максим Храбрый on 20.01.2020.
//  Copyright © 2020 Xaker. All rights reserved.
//

import UIKit

extension UIButton {

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if isHighlighted {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = UIColor(hex: 0xd1352c)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = UIColor(hex: 0xff3b30)
            }
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor(hex: 0xd1352c)
        }
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor(hex: 0xff3b30)
        }
        super.touchesEnded(touches, with: event)
    }
    
    
    private struct TouchAreaEdgeInsets {
        static var value = "\(#file)+\(#line)"
    }
    
    var touchAreaEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &TouchAreaEdgeInsets.value) as? NSValue {
                var edgeInsets = UIEdgeInsets.zero
                value.getValue(&edgeInsets)
                
                return edgeInsets
            } else {
                return UIEdgeInsets.zero
            }
        }
        
        set (newValue) {
            var newValueCopy = newValue
            let objCType = NSValue(uiEdgeInsets: UIEdgeInsets.zero).objCType
            let value = NSValue(&newValueCopy, withObjCType: objCType)
            
            objc_setAssociatedObject(self, &TouchAreaEdgeInsets.value, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if touchAreaEdgeInsets == .zero || !isEnabled || isHidden {
            return super.point(inside: point, with: event)
        }
        
        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: self.touchAreaEdgeInsets)
        
        return hitFrame.contains(point)
    }
    
    func increaseTouchArea(radius: CGFloat) {
        self.touchAreaEdgeInsets = UIEdgeInsets(top: -radius, left: -radius,
                                                bottom: -radius, right: -radius)
    }

}
