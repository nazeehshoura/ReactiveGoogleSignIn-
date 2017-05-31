//
//  ReactiveGoogleSignIn.swift
//
//  Created by Nazih Shoura on 08/05/2017.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleSignIn

public class RxGIDSignInDelegateProxy: DelegateProxy, GIDSignInDelegate, DelegateProxyType {
    
    /// Typed parent object.
    public weak fileprivate(set) var gidSignIn: GIDSignIn?
    
    // MARK: delegate

    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if let subject = _gidGoogleSigninError {
                subject.on(.next(error))
            }
        }
        if let user = user {
            if let subject = _gidGoogleUserSigninResult {
                subject.on(.next(user))
            }
        }
        
        self._forwardToDelegate?.sign(signIn, didSignInFor: user, withError: error)
    }



    /// Initializes `RxScrollViewDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        guard let _ = parentObject as? GIDSignIn else {
            fatalError("Failure converting from \(parentObject) to \(GIDSignIn.self)")
        }
        
        super.init(parentObject: parentObject)
    }
    
    fileprivate var _gidGoogleSigninError: PublishSubject<Error>?
    fileprivate var _gidGoogleUserSigninResult: PublishSubject<GIDGoogleUser>?

    internal var gidGoogleUserSigninResult: PublishSubject<GIDGoogleUser> {
        if let subject = _gidGoogleUserSigninResult {
            return subject
        }
        
        let subject = PublishSubject<GIDGoogleUser>()
        _gidGoogleUserSigninResult = subject
        
        return subject
    }
    
    internal var gidGoogleSigninError: PublishSubject<Error> {
        if let subject = _gidGoogleSigninError {
            return subject
        }
        
        let subject = PublishSubject<Error>()
        _gidGoogleSigninError = subject
        
        return subject
    }

    // MARK: proxy
    
    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        guard let gidSignIn: GIDSignIn = object as? GIDSignIn else {
            fatalError("Failure converting from \(object) to \(GIDSignIn.self)")
        }

        return gidSignIn.createRxDelegateProxy()
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        guard let gidSignIn: GIDSignIn = object as? GIDSignIn else {
            fatalError("Failure converting from \(object) to \(GIDSignIn.self)")
        }
        gidSignIn.delegate = delegate as? GIDSignInDelegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        guard let gidSignIn: GIDSignIn = object as? GIDSignIn else {
            fatalError("Failure converting from \(object) to \(GIDSignIn.self)")
        }

        return gidSignIn.delegate
    }

    deinit {
        if let subject = _gidGoogleUserSigninResult {
            subject.on(.completed)
        }
    }

}

extension Reactive where Base: GIDSignIn {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxGIDSignInDelegateProxy.proxyForObject(base)
    }
    
    /// Reactive wrapper for user resulted from Google Sign in .
    public var signinResult: Observable<GIDGoogleUser> {
        let proxy = RxGIDSignInDelegateProxy.proxyForObject(base)
        
        return proxy.gidGoogleUserSigninResult.asObservable()
    }
    
    /// Reactive wrapper for the error resulted from Google Sign in .
    public var gidGoogleSigninError: Observable<Error> {
        let proxy = RxGIDSignInDelegateProxy.proxyForObject(base)
        
        return proxy.gidGoogleSigninError.asObservable()
    }
}

extension GIDSignIn {
    
    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    public func createRxDelegateProxy() -> RxGIDSignInDelegateProxy {
        return RxGIDSignInDelegateProxy(parentObject: self)
    }
    
}
