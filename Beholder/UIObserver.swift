//
//  UIObserver.swift
//  App
//
//  Created by Mikhail Vroubel on 9/19/15.
//  Copyright © 2015 Mikhail Vroubel. All rights reserved.
//

import UIKit

@objc public class UIObserver: Ownee {
    let action:(UIControl) -> ()
    let events:UIControlEvents
    
    public init(object:UIControl, events:UIControlEvents = .touchUpInside, action:((UIControl) -> ())) {
        (self.action, self.events) = (action, events)
        super.init(owner: object)
        object.addTarget(self, action: #selector(UIObserver.observeSender(_:)), for: events)
        
    }
    
    public func observeSender(_ sender:UIControl) {
        action(sender)
    }
    
    override public func cancel() {
        if let sender = owner as? UIControl {
            sender.removeTarget(self, action: #selector(UIObserver.observeSender(_:)), for: events)
            super.cancel()
        }
    }
}

@objc public class GRObserver: Ownee {
    let action:(UIGestureRecognizer) -> ()
    
    public init(object:UIGestureRecognizer, action:((UIGestureRecognizer) -> ())) {
        self.action = action
        super.init(owner: object)
        object.addTarget(self, action: #selector(UIObserver.observeSender(_:)))
    }
    
    public func observeSender(_ sender:UIGestureRecognizer) {
        action(sender)
    }
    
    override public func cancel() {
        if let sender = owner as? UIGestureRecognizer {
            sender.removeTarget(self, action: #selector(UIObserver.observeSender(_:)))
            super.cancel()
        }
    }
}

extension UIControl {
    public func observeEvents(_ events:UIControlEvents = .touchUpInside, action:(UIControl) -> ()) -> UIObserver {
        return UIObserver(object: self, events:events, action:action)
    }
}

extension UIGestureRecognizer {
    public func observeSender(_ action:(UIGestureRecognizer) -> ()) -> GRObserver {
        return GRObserver(object: self, action:action)
    }
}
