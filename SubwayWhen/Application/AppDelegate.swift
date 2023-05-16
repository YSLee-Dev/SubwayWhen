//
//  AppDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit
import FirebaseCore
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var updateCount = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Background 작업
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yslee.subwaywhen-liveactivity.refresh", using: nil){task in
            self.backgroundLiveActivityUpdate(task: task as! BGAppRefreshTask)
        }
        
        // 네트워크 감지 class
        NetworkMonitor.shared.monitorStart()
        
        // LanchScreen 지연
        sleep(1)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        NetworkMonitor.shared.monitorStop()
        SubwayWhenDetailWidgetManager.shared.stop()
    }
}

extension AppDelegate{
    func backgroundLiveActivityUpdate(task : BGAppRefreshTask){
        if self.updateCount >= 10{
            self.scheduleAppRefresh()
            
            SubwayWhenDetailWidgetManager.shared.update(status: "TEST", statusMSG: "TEST", nowStation: "TEST", lastUpdate: "TEST")
            self.updateCount += 1
            
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
        }else{
            task.setTaskCompleted(success: true)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yslee.subwaywhen-liveactivity.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("NOT BACKGROUND SCHEDULE SUBMIT")
        }
    }
}
