//
//  AppDelegate.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/28.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseStorage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let shared = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCE3u5KCT169xXdo96QsrlyO6emFgyJYKo")
        GMSPlacesClient.provideAPIKey("AIzaSyCE3u5KCT169xXdo96QsrlyO6emFgyJYKo")
        
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()

        
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
}
