# msal-ios-graph-api-example
A sample iOS app written in Swift that uses MSAL iOS and calls the MS Graph API.

Code partially adapted from https://docs.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-ios
The page mentioned above also has setup instructions which also applies to this sample.

CocoaPods is used to integrate MSAL iOS into the project.
Xcode 11.7 was used.

The sample allows:
-Authentication using MSAL iOS.
-Calling any MS Graph endpoint with GET, straight from the app.
-v1.0 and beta endpoints.
-Scrollable responses.
-Requesting scope consent.
-Copy token.

To do:
-Support for more REST methods.
-Interface improvements.
-Support for extra headers. (e.g. ConsistencyLevel)
-Show response headers.

