//
//  ViewController.swift
//  MSALiOSLearning
//
//  Created by Manuel Magalhães on 19/02/2022.
//  Copyright © 2022 Manuel Magalhães. All rights reserved.
//  Code partially adapted from https://docs.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-ios

import UIKit
import MSAL

class ViewController: UIViewController {
    
    let kClientID = "" //insert your app registration client id
    let kRedirectUri = "" //insert your app registration redirect uri
    let kAuthority = "https://login.microsoftonline.com/common"
    let kBaseGraphEndpoint = "https://graph.microsoft.com"
    
    var kScopes: [String] = []
    var kVersion = "/v1.0"
    
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParameters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    var loggingText: UITextView!
    var signOutButton: UIButton!
    var copyTokenButton: UIButton!
    var callGraphButton: UIButton!
    var usernameLabel: UILabel!
    var endpointTextBox: UITextField!
    var scopesTextBox: UITextField!
    var apiVersionSwitch: UISwitch!
    
    
    
    func initUI() {
        
        //username
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = ""
        usernameLabel.textColor = .systemOrange
        usernameLabel.textAlignment = .center
        usernameLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(usernameLabel)
        
        usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        //copy token button
        copyTokenButton  = UIButton()
        copyTokenButton.translatesAutoresizingMaskIntoConstraints = false
        copyTokenButton.setTitle("Copy Token", for: .normal)
        copyTokenButton.setTitleColor(.systemOrange, for: .normal)
        copyTokenButton.setTitleColor(.gray, for: .disabled)
        copyTokenButton.addTarget(self, action: #selector(copyToken(_:)), for: .touchUpInside)
        self.view.addSubview(copyTokenButton)
        
        copyTokenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        copyTokenButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 90.0).isActive = true
        copyTokenButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        copyTokenButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        
        //call graph button
        callGraphButton  = UIButton()
        callGraphButton.translatesAutoresizingMaskIntoConstraints = false
        callGraphButton.setTitle("Call Microsoft Graph API", for: .normal)
        callGraphButton.setTitleColor(.systemOrange, for: .normal)
        callGraphButton.addTarget(self, action: #selector(callGraphAPI(_:)), for: .touchUpInside)
        self.view.addSubview(callGraphButton)
        
        callGraphButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        callGraphButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 120.0).isActive = true
        callGraphButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        callGraphButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        //sign out button
        signOutButton = UIButton()
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.systemOrange, for: .normal)
        signOutButton.setTitleColor(.gray, for: .disabled)
        signOutButton.addTarget(self, action: #selector(signOut(_:)), for: .touchUpInside)
        self.view.addSubview(signOutButton)
        
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.topAnchor.constraint(equalTo: callGraphButton.bottomAnchor, constant: 10.0).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        //beta version switch label
        let apiVersionLabel = UILabel()
        apiVersionLabel.text = "Beta API"
        apiVersionLabel.textAlignment = .center
        apiVersionLabel.textColor = .systemOrange
        apiVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(apiVersionLabel)
        
        apiVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        apiVersionLabel.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 0).isActive = true
        apiVersionLabel.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        apiVersionLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        //beta version switch
        apiVersionSwitch = UISwitch()
        apiVersionSwitch.translatesAutoresizingMaskIntoConstraints = false
        apiVersionSwitch.addTarget(self, action: #selector(toggleBeta(_:)), for: .valueChanged)
        self.view.addSubview(apiVersionSwitch)
        
        apiVersionSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        apiVersionSwitch.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 40.0).isActive = true
        apiVersionSwitch.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        //endpoint text field
        endpointTextBox = UITextField();
        endpointTextBox.isHidden = false
        endpointTextBox.backgroundColor = .systemGray
        endpointTextBox.textColor = .black
        endpointTextBox.text = "Write the MS Graph API endpoint (e.g. /me)"
        endpointTextBox.adjustsFontSizeToFitWidth = true
        endpointTextBox.clearsOnBeginEditing = true
        endpointTextBox.isEnabled = true
        endpointTextBox.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(endpointTextBox)
        
        endpointTextBox.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        endpointTextBox.topAnchor.constraint(equalTo: apiVersionSwitch.bottomAnchor, constant: 0).isActive = true
        endpointTextBox.widthAnchor.constraint(equalToConstant: 350.0).isActive = true
        endpointTextBox.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        //scopes text field
        scopesTextBox = UITextField();
        scopesTextBox.isHidden = false
        scopesTextBox.backgroundColor = .systemGray
        scopesTextBox.text = "Scopes to consent, separated by space"
        scopesTextBox.textColor = .black
        scopesTextBox.adjustsFontSizeToFitWidth = true
        scopesTextBox.clearsOnBeginEditing = true
        scopesTextBox.isEnabled = true
        scopesTextBox.translatesAutoresizingMaskIntoConstraints = false
        scopesTextBox.addTarget(self, action: #selector(updateScopes(_:)), for: .editingChanged)
        self.view.addSubview(scopesTextBox)
        
        scopesTextBox.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scopesTextBox.topAnchor.constraint(equalTo: apiVersionSwitch.bottomAnchor, constant: 40.0).isActive = true
        scopesTextBox.widthAnchor.constraint(equalToConstant: 350.0).isActive = true
        scopesTextBox.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        
        //logging text field
        loggingText = UITextView()
        loggingText.isUserInteractionEnabled = true
        loggingText.translatesAutoresizingMaskIntoConstraints = false
        loggingText.isScrollEnabled = true
        self.view.addSubview(loggingText)
        
        loggingText.topAnchor.constraint(equalTo: apiVersionSwitch.bottomAnchor, constant: 90.0).isActive = true
        loggingText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10.0).isActive = true
        loggingText.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10.0).isActive = true
        loggingText.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30.0).isActive = true
    }
    
    func platformViewDidLoadSetup() { //adds an observer, which will trigger appCameToForeGround() when app comes to foreground
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appCameToForeGround(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func appCameToForeGround(notification: Notification) { //loads current account when app comes to foreground
        self.loadCurrentAccount()
    }
    
    override func viewDidLoad() { //initializes view, msal, and account
        
        super.viewDidLoad()
        
        initUI()
        
        do {
            try self.initMSAL()
        } catch let error {
            self.updateLogging(text: "Unable to create Application Context \(error)")
        }
        
        self.loadCurrentAccount()
        self.platformViewDidLoadSetup()
    }
    
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            self.updateLogging(text: "Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.webViewParameters = MSALWebviewParameters(authPresentationViewController: self)
    }
    
    func getEndpoint() -> String { //builds endpoint with the base url, the ms graph api version used, and the text in the endpoint text field
        
        return kBaseGraphEndpoint + kVersion + endpointTextBox.text!;
    }
    
    @objc func copyToken(_ sender: AnyObject){ //copies token to clipboard
        
        UIPasteboard.general.string = self.accessToken
    }
    
    @objc func callGraphAPI(_ sender: AnyObject) { //calls the graph api. if there is an user signed in, it will obtain the token silently, otherwise it will present the sign in screen
        
        self.loadCurrentAccount { (account) in
            
            guard let currentAccount = account else {
                
                self.acquireTokenInteractively()
                return
            }
            
            self.acquireTokenSilently(currentAccount)
        }
    }
    
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    func loadCurrentAccount(completion: AccountCompletion? = nil) { //loads the account currently logged in
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't query current account with error: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                
                self.updateLogging(text: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                
                self.updateCurrentAccount(account: currentAccount)
                
                if let completion = completion {
                    completion(self.currentAccount)
                }
                
                return
            }
            
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    
    func acquireTokenInteractively() { //if user is not signed in, an authentication screen appears and afterwards a token is retrived and a Graph API request is made
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParameters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.updateCurrentAccount(account: result.account)
            self.getContentWithToken()
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) { //if user is signed in, a token is acquired silently, then a Graph API request is made
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.updateSignOutButton(enabled: true)
            self.getContentWithToken()
        }
    }
    
    func getContentWithToken() { //calls the microsoft graph api endpoint, with the token obtained previously in the Authorization header
        
        
        let graphURI = getEndpoint()
        let url = URL(string: graphURI)
        if(url != nil){ //verifies if it's a valid URL object, if it is not an error is logged
            var request = URLRequest(url: url!)
            request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    self.updateLogging(text: "Couldn't get graph result: \(error)")
                    return
                }
                
                guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                    
                    self.updateLogging(text: "Couldn't deserialize result JSON")
                    return
                }
                
                self.updateLogging(text: "Result from Graph: \(result))")
                
            }.resume()
        }else{
            self.updateLogging(text: "Invalid endpoint")
            return
        }
    }
    
    @objc func updateScopes(_ sender: AnyObject){ //updates scopes to consent when the scopes text field changes
        kScopes = []
        kScopes = (scopesTextBox.text?.components(separatedBy: " ") ?? []) as [String]
    }
    
    @objc func toggleBeta(_ sender: AnyObject){ //toggles version depending on the apiVersionSwitch being on or off
        if(apiVersionSwitch.isOn == true){
            kVersion = "/beta"
            
        }else{
            kVersion = "/v1.0"
            
        }
    }
    
    @objc func signOut(_ sender: AnyObject) { //tries to sign out, sets account to nil, and clears the access token
        
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount else { return }
        
        do {
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParameters!)
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    self.updateLogging(text: "Couldn't sign out account with error: \(error)")
                    return
                }
                
                self.updateLogging(text: "Sign out completed successfully")
                self.accessToken = ""
                self.updateCurrentAccount(account: nil)
            })
            
        }
    }
    
    func updateLogging(text : String) { //logs to the logging text field
        
        if Thread.isMainThread {
            self.loggingText.text = text
        } else {
            DispatchQueue.main.async {
                self.loggingText.text = text
            }
        }
    }
    
    func updateSignOutButton(enabled : Bool) { //enables/disables the sign out and the copy token buttons, depending if user is signed in or not
        if Thread.isMainThread {
            self.signOutButton.isEnabled = enabled
            self.copyTokenButton.isEnabled = enabled
        } else {
            DispatchQueue.main.async {
                self.signOutButton.isEnabled = enabled
                self.copyTokenButton.isEnabled = enabled
            }
        }
    }
    
    func updateAccountLabel() { //if the user is signed in, their username will appear in the usernameLabel
        guard let currentAccount = self.currentAccount else {
            self.usernameLabel.text = ""
            return
        }
        
        self.usernameLabel.text = currentAccount.username
    }
    
    func updateCurrentAccount(account: MSALAccount?) {  //calls the updateAccountLabel (which updates the usernameLabel) and updateSignOutButton (which enables/disables the sign out button and the copy token button)
        self.currentAccount = account
        self.updateAccountLabel()
        self.updateSignOutButton(enabled: account != nil)
    }
    
    
}

