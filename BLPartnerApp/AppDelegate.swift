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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Request notification permissions
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController(rootViewController: LoginViewController())
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        
        Wormholy.shakeEnabled = true
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
      }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("=== \(error)")
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("=== FCM token: \(fcmToken ?? "")")
        saveFCMTokenToLocal(fcmToken ?? "")
    }
    
    func saveFCMTokenToLocal(_ fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: "FCMToken")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Handle the notification content
        
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Handle the notification content
        
        completionHandler()
    }
    
}
