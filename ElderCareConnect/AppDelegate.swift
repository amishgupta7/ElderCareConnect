//
//  AppDelegate.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 6/10/24.
//

import UIKit
import FirebaseCore
import FirebaseAppCheck


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Global.appYellow,  // Customize the color
            //.font: UIFont(name: "Georgia-Bold", size: 24) ?? UIFont.systemFont(ofSize: 28, weight: .medium)
            .font: UIFont(name: "Noteworthy-Bold", size: 22) ?? UIFont.systemFont(ofSize: 28, weight: .medium)

        ]

        UINavigationBar.appearance().titleTextAttributes = titleAttributes
        
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

