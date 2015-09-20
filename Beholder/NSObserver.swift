//
//  KVObserver.swift
//  Signal
//
//  Created by Mikhail Vroubel on 13/09/2014.
//
//

import Foundation

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
    let action:[NSObject : AnyObject] -> ()
    
    public init(object:NSObject, keyPath:String, options:NSKeyValueObservingOptions = .New, action:([NSObject : AnyObject]) -> ()) {
        self.action = action
        super.init(owner: object, context: OwneeOwner + "." + keyPath)
        addObserver(self, forKeyPath: self.context as! String, options: options, context: &self.context)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &self.context {
            action(change!)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    override public func cancel() {
        if context != nil {
            removeObserver(self, forKeyPath: context as! String, context:&self.context)
            owner = nil
        }
        super.cancel()
    }
}

@objc public class NCObserver: Ownee {
    let action:NSNotification -> ()
    
    public init(object:NSObject, name:String, action:(NSNotification -> ())) {
        self.action = action
        super.init(owner: object, context: name)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("observeNote:"), name: name, object: object)
    }
    
    public func observeNote(note:NSNotification) {
        action(note)
    }
    
    override public func cancel() {
        if let name = context as? String {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: name, object: owner)
            super.cancel()
        }
    }
}

extension Ownee {
    public func scope(scope:NSObject) {
        weak var scopeDealloc = scope.observe {[weak self] in self?.cancel()}
        self.observe {[weak scopeDealloc] in scopeDealloc?.cancel()}
    }
}

extension NSObject {
    public func observeName(name:String, scope:NSObject? = nil, action:(NSNotification) -> ()) -> NCObserver {
        return NCObserver(object: self, name: name,action: action).setup {_ = scope.map($0.scope)}
     }
    
    public func observeKeyPath(keyPath:String, scope:NSObject? = nil, action:([NSObject : AnyObject]) -> ()) -> KVObserver {
        return KVObserver(object: self, keyPath: keyPath, options: .New, action: action).setup {_ = scope.map($0.scope)}
    }
    
    public func observe(scope:NSObject? = nil, dealloc:() -> ()) -> DAObserver {
        return DAObserver(owner: self, action: dealloc).setup {_ = scope.map($0.scope)}
    }
}
