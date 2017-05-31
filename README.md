This is a simple Reactive wrapper for iOS GoogleSignIn to git rid of the ugly delegate methods! Tested on  `GoogleSignIn V4.0.2`

## How to use:

Simply copy `ReactiveGoogleLogin.swift` to your project, request google signin
```swift
GIDSignInButton().sendActions(for: .touchUpInside)
```

, and declare observables for Google signin results
```swift
let googleUser: Observable<GIDGoogleUser> = GIDSignIn.sharedInstance().rx.signinResult

let error: Observable<Error> = GIDSignIn.sharedInstance().rx.gidGoogleSigninError

```

That's it :D
