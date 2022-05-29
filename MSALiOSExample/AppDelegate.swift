//
//  AppDelegate.swift
//  MSALiOSExample
//
//  Created by Manuel Magalhães on 08/05/2022.
//  Copyright © 2022 Manuel Magalhães. All rights reserved.
//  Code partially adapted from https://docs.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-ios

import UIKit
import MSAL

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

            return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }


}

