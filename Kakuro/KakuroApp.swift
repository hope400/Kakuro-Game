//
//  KakuroApp.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct KakuroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var gameTracker = GameTracker()
    @StateObject private var firebaseManager: FirebaseManager = .shared
    
    init() {
        KakuroTemplates.debugValidateAll()   // optional
//       TemplateAutoMaker.makeAllSets()
//        HardTemplateAutoMaker.makeHardSets()

       }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(gameTracker)
                .environmentObject(firebaseManager)
        }
    }
}


struct RootView: View {

    @EnvironmentObject var firebaseManager: FirebaseManager

    var body: some View {
        if firebaseManager.user == nil {
            LoginView()
        } else {
            KakuroMainMenu()
        }
    }
}
