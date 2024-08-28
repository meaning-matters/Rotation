//
//  AppDelegate.swift
//  Rotation
//
//  Created by Cornelis van der Bent on 12/10/2019.
//  Copyright © 2019 Meaning Matters. All rights reserved.
//

import UIKit
import CoreData
import Combine
import CoreMotion

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate
{
    var motionManager: CMMotionManager = CMMotionManager()
    var previousQuaternion: CMQuaternion!
    var lpFilter: Filter!
    var smaFilter: Filter!

    public let subject = PassthroughSubject<Double, Never>()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let sampleRate = 45.0
        motionManager.deviceMotionUpdateInterval = 1 / sampleRate
        motionManager.startDeviceMotionUpdates()

        lpFilter = LowPassFilter(sampleRate: sampleRate, cutOffFrequency: 0.3)
        smaFilter = SimpleMovingAverageFilter(sampleRate: sampleRate, period: 4)
        Timer.scheduledTimer(withTimeInterval: 1 / sampleRate, repeats: true)
        { timer in
            guard let attitude = self.motionManager.deviceMotion?.attitude else { return }

            print(self.motionManager.deviceMotion!.heading)

            if self.previousQuaternion == nil
            {
                self.previousQuaternion = attitude.quaternion
            }

            // Dynamic algorithm which calculates travelled distance.
            var currentQuaternion: CMQuaternion
            var distance: Double

            currentQuaternion = attitude.quaternion
            distance = sqrt(pow(currentQuaternion.x - self.previousQuaternion.x, 2) +
                            pow(currentQuaternion.y - self.previousQuaternion.y, 2) +
                            pow(currentQuaternion.z - self.previousQuaternion.z, 2) +
                            pow(currentQuaternion.w - self.previousQuaternion.w, 2));
            self.previousQuaternion = currentQuaternion;

            let filteredDistance = self.lpFilter.addSample(sample: self.smaFilter.addSample(sample: distance))
            self.subject.send(filteredDistance * 10)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
    {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer =
    {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Rotation")
        container.loadPersistentStores(completionHandler:
        { (storeDescription, error) in
            if let error = error as NSError?
            {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext ()
    {
        let context = persistentContainer.viewContext
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch
            {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
