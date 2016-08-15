//
//  KVObserver.swift
//  Signal
//
//  Created by Mikhail Vroubel on 13/09/2014.
//
//

import Foundation
import Utils

@objc public class DAObserver: Ownee {
    let action:()->()
    public init(owner:NSObject, action:()->()) {
        self.action = action
        super.init(owner: owner, context:nil)
    }
    
    deinit {
        action()
    }
}

@objc public class KVObserver: Ownee {
    let action:([NSObject : AnyObject]) -> ()
    
    public init(object:NSObject, keyPath:String, options:NSKeyValueObservingOptions = .new, action:([NSObject : AnyObject]) -> ()) {
        self.action = action
        super.init(owner: object, context: OwneeOwner + "." + keyPath)
        addObserver(self, forKeyPath: self.context as! String, options: options, context: &self.context)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if context == &self.context {
            action(change!)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override public func finish() {
        if context != nil {
            removeObserver(self, forKeyPath: context as! String, context:&self.context)
            owner = nil
        }
        super.finish()
    }
}

@objc public class NCObserver: Ownee {
    let action:(Notification) -> ()
    
    public init(object:NSObject, name:String, action:((Notification) -> ())) {
        self.action = action
        super.init(owner: object, context: name)
        NotificationCenter.default.addObserver(self, selector: #selector(NCObserver.observeNote(_:)), name: NSNotification.Name(rawValue: name), object: object)
    }
    
    public func observeNote(_ note:Notification) {
        action(note)
    }
    
    override public func finish() {
        if let name = context as? String {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: name), object: owner)
            super.finish()
        }
    }
}

extension Ownee {
    public func scope(_ scope:NSObject) {
        weak var scopeDealloc = scope.observe {[weak self] in self?.finish()}
        _ = self.observe {[weak scopeDealloc] in scopeDealloc?.finish()}
    }
}

extension NSObject {
    public func observeName(_ name:String, scope:NSObject? = nil, action:(Notification) -> ()) -> NCObserver {
        return NCObserver(object: self, name: name,action: action).tap {_ = scope.map($0.scope)}
     }
    
    public func observeKeyPath(_ keyPath:String, scope:NSObject? = nil, action:([NSObject : AnyObject]) -> ()) -> KVObserver {
        return KVObserver(object: self, keyPath: keyPath, options: .new, action: action).tap {_ = scope.map($0.scope)}
    }
    
    public func observe(_ scope:NSObject? = nil, dealloc:() -> ()) -> DAObserver {
        return DAObserver(owner: self, action: dealloc).tap {_ = scope.map($0.scope)}
    }
}
