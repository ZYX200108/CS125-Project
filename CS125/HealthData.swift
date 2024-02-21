//
//  HealthData.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import Foundation
import HealthKit
import SwiftUI


struct HealthData {
    var hourlyCalories: [Double]
    var totalSteps: Int
}

class HealthKitManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
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
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!  // For sleep data
        ]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { (success, error) in
            completion(success, error)
        }
    }
    
    
    func fetchHourlyCalories(completion: @escaping (HealthData) -> Void) {
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        var hourlyCalories = Array(repeating: 0.0, count: 24) // Initialize an array for 24 hours of data
        var totalSteps = 0
        let group = DispatchGroup() // Use a dispatch group to manage multiple asynchronous queries
        
        // Fetch hourly calories
        for hour in 0..<24 {
            group.enter() // Enter the group for each query
            
            let startHour = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
            let endHour = Calendar.current.date(bySettingHour: hour, minute: 59, second: 59, of: Date())!
            let predicate = HKQuery.predicateForSamples(withStart: startHour, end: endHour, options: .strictStartDate)
            
            let calorieQuery = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                hourlyCalories[hour] = calories
                group.leave() // Leave the group once the query completes
            }
            healthStore.execute(calorieQuery)
        }
        
        // Fetch total daily steps
        group.enter() // Enter the group for the step count query
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        let dailyPredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: dailyPredicate, options: .cumulativeSum) { _, result, _ in
            let steps = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
            totalSteps = steps
            group.leave() // Leave the group once the query completes
        }
        healthStore.execute(stepsQuery)
        
        // Completion handler to return results
        group.notify(queue: .main) { // Once all queries complete, this block will be called
            let healthData = HealthData(hourlyCalories: hourlyCalories, totalSteps: totalSteps)
            completion(healthData)
        }
    }
    
    // Helper function to fetch calories for a given time period
    private func fetchCalories(for quantityType: HKQuantityType, predicate: NSPredicate, completion: @escaping (Double) -> Void) {
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            completion(calories)
        }
        healthStore.execute(query)
    }
    
    // Function to fetch sleep data
    func fetchSleepAnalysis(completion: @escaping ([HKCategorySample]?, Error?) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let sleepData = results as? [HKCategorySample] else {
                completion(nil, error)
                return
            }
            completion(sleepData, nil)
        }
        healthStore.execute(query)
    }
}

