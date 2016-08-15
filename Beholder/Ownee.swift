//
//  Ownee.swift
//  Signal
//
//  Created by Mikhail Vroubel on 13/09/2014.
//
//

import Foundation

let OwneeOwner = "unsafeOwner"

@objc public class Ownee : NSObject {
    @IBOutlet public var context:AnyObject?
    unowned var unsafeOwner:AnyObject
    @IBOutlet public weak var owner:NSObject? {
        willSet {
            willSet(owner, newValue: newValue)
        }
    }
    func willSet(_ owner:NSObject?, newValue:NSObject?) {
        if owner != newValue {
            if newValue != nil {
                objc_setAssociatedObject(newValue, unsafeAddress(of: self), self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            if owner != nil {
                objc_setAssociatedObject(owner, unsafeAddress(of: self), nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        unsafeOwner = newValue ?? Ownee.self
    }
    
    public init(owner:NSObject, context:AnyObject? = nil) {
        self.unsafeOwner = owner
        super.init()
        (self.owner, self.context) = (owner, context)
        willSet(nil, newValue: owner)
    }
    public func cancel() {
        owner = nil;
        context = nil
    }
    deinit {
        cancel()
    }
}
