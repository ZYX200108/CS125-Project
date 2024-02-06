//
//  HealthData.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject{
    let healthStore = HKHealthStore()
    
//    init(){
//        let steps =
//    }
    
    // Function to request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.example.HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."]))
            return
        }
        
        // Data types you want to read
        let readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { (success, error) in
            completion(success, error)
        }
    }
    
    
    func fetchWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let calendar = NSCalendar.current
        let now = Date()
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return }
        
        // Date predicate to fetch workouts from the last month
        let datePredicate = HKQuery.predicateForSamples(withStart: oneMonthAgo, end: now, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: datePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let workouts = results as? [HKWorkout] else {
                completion(nil, error)
                return
            }
            
            // Process the retrieved workouts here
            completion(workouts, nil)
        }
        
        healthStore.execute(query)
    }

    
    // Function to fetch steps and calories
    func fetchStepsAndCalories(completion: @escaping (Double, Double) -> Void) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            completion(steps, 0) // Temporary, will be updated with calories
            print(steps)
        }
        
        let caloriesQuery = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            completion(0, calories) // Temporary, will call the final completion
            print(calories)
        }
        
        healthStore.execute(stepsQuery)
        healthStore.execute(caloriesQuery)
    }
}

//class ViewController: UIViewController {
//    var healthKitManager: HealthKitManager!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        healthKitManager = HealthKitManager()
//        
//        // Request HealthKit authorization first
//        healthKitManager.requestAuthorization { [weak self] (authorized, error) in
//            guard authorized else {
//                print("HealthKit authorization denied!")
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                }
//                return
//            }
//            
//            // Fetch workouts if authorized
//            self?.healthKitManager.fetchWorkouts { (workouts, error) in
//                guard let workouts = workouts else {
//                    print("Error fetching workouts: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                for workout in workouts {
//                    print("Workout: \(workout.workoutActivityType), \(workout.startDate), \(workout.duration), \(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) kcal")
//                }
//            }
//        }
//    }
//}
