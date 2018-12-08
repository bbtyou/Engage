//
//  AppDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/6/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // - Firebase Messaging key
    let fbMessageIDKey = "gcm.message_id"
    
    // - Push token
    var apnsToken: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // - Configure firebase
        FirebaseApp.configure()
        
        // - Set the messaging delegate
        Messaging.messaging().delegate = self
        
        // - Set the user notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // - Authorization options for notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (allowed, error) in
            if let e = error {
                log.error("Registration for push could not be completed. \(e).")
                return
            }
            
            if allowed {
                // - Observe that login has completed before we register for push
                NotificationCenter.default.addObserver(self, selector: #selector(self.registerForPush), name: NSNotification.Name.init("loginCompleted"), object: nil)
                
                // - Register the application for remote notifications
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("loginCompleted"), object: nil)
    }
}

// - Private
fileprivate extension AppDelegate {

    // - Push registration
    @objc func registerForPush() {
        guard let token = self.apnsToken else {
            log.warning("Unable to register for push notifications because the push token could not be verified.")
            return
        }
        
        let request = PushRegisterRequest.init(token: token)
        request.sendRequest { (response, data, error) in
            if let error = error {
                log.error("\(error)")
                return
            }
            
            if let data = data, let dataString = String.init(data: data, encoding: .utf8), let response = response {
                log.verbose("Push registration response: \(response).")
                log.verbose("Push registration data: \(dataString))")
            }
        }
    }    
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let contents = userInfo["aps"] as? [String: Any]
        let alert = contents?["alert"] as? [String: Any]
        let body = alert?["body"]
        
        if let messageId = userInfo[self.fbMessageIDKey] {
            log.debug("Push message id = \(messageId).")
        }
        
        guard let view = UIApplication.topViewController() as? Notifiable & UIViewController, let message = body as? String else {
            log.warning("Unable to display message notification because the top view controller could not be obtained.")
            return
        }
        
        view.notify(message: message, 2.0)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        log.debug("Firebase registration token: \(fcmToken).")
        self.apnsToken = fcmToken
    }
    
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        log.verbose("Received data message: \(remoteMessage.appData)")
    }
}
