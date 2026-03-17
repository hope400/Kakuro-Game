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
    @StateObject private var firebaseManager: FirebaseManager = .shared
    @StateObject private var gameTracker = GameSession()
    


    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(firebaseManager)
                .environmentObject(gameTracker)
                .onAppear {
                    gameTracker.firebaseManager = firebaseManager
                }
        }
    }
}


struct RootView: View {

    @EnvironmentObject var firebaseManager: FirebaseManager

    var body: some View {
        Group {
            if firebaseManager.user == nil {
                LoginView()
            } else {
                KakuroMainMenu()
            }
        }
//        .task {
//            firebaseManager.uploadAllTemplates()
//        }
    }
}
