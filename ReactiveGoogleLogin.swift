//
//  GIDSignIn+Rx.swift
//
//  Created by Nazih Shoura on 08/05/2017.
//  Modified by Balazs Vadnai on 2018. 05. 09..
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//

import Foundation
import GoogleSignIn
import RxSwift
import RxCocoa

public class RxGIDSignInDelegateProxy: DelegateProxy<GIDSignIn, GIDSignInDelegate>, GIDSignInDelegate, DelegateProxyType {
    /// Typed parent object.
    public weak private(set) var gidSignIn: GIDSignIn?

    // MARK: delegate
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if let subject = _gidGoogleUserSigninResult {
                subject.on(.error(error))
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
    public init(gidSignIn: ParentObject) {
        self.gidSignIn = gidSignIn
        super.init(parentObject: gidSignIn, delegateProxy: RxGIDSignInDelegateProxy.self)
    }

    fileprivate var _gidGoogleUserSigninResult: ReplaySubject<GIDGoogleUser>?

    internal var gidGoogleUserSigninResult: ReplaySubject<GIDGoogleUser> {
        if let subject = _gidGoogleUserSigninResult {
            return subject
        }
        let subject = ReplaySubject<GIDGoogleUser>.create(bufferSize: 1)
        _gidGoogleUserSigninResult = subject
        return subject
    }

    // MARK: proxy

    public static func registerKnownImplementations() {
        register { RxGIDSignInDelegateProxy(gidSignIn: $0) }
    }

    /// For more information take a look at `DelegateProxyType`.
    public static func setCurrentDelegate(_ delegate: GIDSignInDelegate?, to object: GIDSignIn) {
        object.delegate = delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    public static func currentDelegate(for object: GIDSignIn) -> GIDSignInDelegate? {
        return object.delegate
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
    public var delegate: DelegateProxy<GIDSignIn, GIDSignInDelegate> {
        return RxGIDSignInDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for user resulted from Google Sign in .
    public var signinResult: Single<GIDGoogleUser> {
        let proxy = RxGIDSignInDelegateProxy.proxy(for: base)
        return proxy.gidGoogleUserSigninResult.take(1).asSingle()
    }
}

extension GIDSignIn {
    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    public func createRxDelegateProxy() -> RxGIDSignInDelegateProxy {
        return RxGIDSignInDelegateProxy(gidSignIn: self)
    }

}
