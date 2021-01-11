//
//  ViewController.swift
//  ForceUpdate
//
//  Created by Mollick, Tapash on 20/02/20.
//  Copyright © 2020 Mollick, Tapash. All rights reserved.
//

import UIKit
import Firebase

///By default, Remote Config will cache any values it retrieves from the cloud for about 12 hours. In a production app, this is probably just fine. But when you’re doing development — or following a Firebase Remote Config tutorial for iOS online — this can make it really tough to test out new values. So, instead, you’re specifying a fetchDuration of 0 to ensure you never use the cached data.



class ViewController: UIViewController {
    
    let isUpdateAvailable = "isUpdate"
    let new_version = "new_version"
    
    var remoteConfig: RemoteConfig!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        fetchConfig()
        
    }
    
    private func fetchConfig() {
        guard let currentVersion = remoteConfig[new_version].stringValue else {
            return
        }
        versionLabel.text = "Current Version: " + currentVersion
        
        let expirationDuration = 0 // WARNING: Don't actually do this in production!
        
        // [START fetch_config_with_callback]
        // TimeInterval is set to expirationDuration here, indicating the next fetch request will use
        // data fetched from the Remote Config service, rather than cached parameter values, if cached
        // parameter values are more than expirationDuration seconds old. See Best Practices in the
        // README for more information.
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate(completionHandler: { (error) in
                    // ...
                })
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.updateUI()
        }
        // [END fetch_config_with_callback]
    }
    
    private func updateUI() {
        
        var appVersionString = "1.0"
        if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersionString = text
        }
        
        let newVersion = remoteConfig[new_version].stringValue
        print("appVersionString\(String(describing: appVersionString))")
        print("newVersion\(String(describing: newVersion))")
        
        
        // [END get_config_value]
        
        if remoteConfig[isUpdateAvailable].boolValue {
            if appVersionString != newVersion {
            showForceUpdateWithMessage(String(format: "A new version of the app is available. Please update to version %@ now.",newVersion ?? appVersionString) as NSString)
            }
        }
    }
    
    func showForceUpdateWithMessage(_ message: NSString) {
        let alert = UIAlertController(title: "Update Available", message: message as String, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Update", style: .cancel, handler: { (action) in
            self.openAppInStore()
        })
        
        alert.addAction(ok)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.present(alert, animated: true) {
        }
    }
    
    @objc func openAppInStore() {
        let iTunesLink = "https://itunes.apple.com/app/id1444274060"
        if let url = URL(string: iTunesLink), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
}

