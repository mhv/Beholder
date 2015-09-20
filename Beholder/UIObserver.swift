//
//  UIObserver.swift
//  App
//
//  Created by Mikhail Vroubel on 9/19/15.
//  Copyright © 2015 Mikhail Vroubel. All rights reserved.
//

import UIKit

@objc public class UIObserver: Ownee {
    let action:UIControl -> ()
    let events:UIControlEvents
    
    public init(object:UIControl, events:UIControlEvents = .TouchUpInside, action:(UIControl -> ())) {
        (self.action, self.events) = (action, events)
        super.init(owner: object)
        object.addTarget(self, action: Selector("observeSender:"), forControlEvents: events)
        
    }
    
    public func observeSender(sender:UIControl) {
        action(sender)
    }
    
    override public func cancel() {
        if let sender = owner as? UIControl {
            sender.removeTarget(self, action: Selector("observeSender:"), forControlEvents: events)
            super.cancel()
        }
    }
}

@objc public class GRObserver: Ownee {
    let action:UIGestureRecognizer -> ()
    
    public init(object:UIGestureRecognizer, action:(UIGestureRecognizer -> ())) {
        self.action = action
        super.init(owner: object)
        object.addTarget(self, action: Selector("observeSender:"))
    }
    
    public func observeSender(sender:UIGestureRecognizer) {
        action(sender)
    }
    
    override public func cancel() {
        if let sender = owner as? UIGestureRecognizer {
            sender.removeTarget(self, action: Selector("observeSender:"))
            super.cancel()
        }
    }
}

extension UIControl {
    public func observeEvents(events:UIControlEvents = .TouchUpInside, action:(UIControl) -> ()) -> UIObserver {
        return UIObserver(object: self, events:events, action:action)
    }
}

extension UIGestureRecognizer {
    public func observeSender(action:(UIGestureRecognizer) -> ()) -> GRObserver {
        return GRObserver(object: self, action:action)
    }
}
