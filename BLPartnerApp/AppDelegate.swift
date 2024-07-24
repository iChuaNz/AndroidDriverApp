//
//  AppDelegate.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 16/07/24.
//

import UIKit
import Wormholy
import Firebase
import FirebaseMessaging
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController(rootViewController: LoginViewController())
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        newSetupFirebase(app: application)
        
        Wormholy.shakeEnabled = true
        setupFirebase()
        setupMessagingFirebase()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        UserDefaults.standard.set(deviceToken, forKey: "DeviceToken")
        print("==== \(deviceToken)")
    }
    
    private func setupFirebase() {
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        if let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        } else { FirebaseApp.configure() }
    }
}

