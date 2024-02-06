//
//  HomeView.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import SwiftUI
import HealthKit

struct HomeView: View {
    var body: some View {
        @State var progress: CGFloat = 0.75 // Example progress, set to 75%
        @State var hourlyCaloriesBurned: [Double] = [0,0,0,0,0,0,
                                                     0,55,20,20,24,35,
                                                     13,40,550,20,0,0,
                                                     0,0,0,0,0,0]
        @ObservedObject var manager = HealthKitManager()
        
        VStack(spacing: 20) {
            Text("You have walked \(Int(progress * 10000)) steps today")
                .font(.title)
                .padding(.top)
            
            // Custom circular progress indicator
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(Color.blue) // Changed color
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue) // Changed color
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                Text("\(Int(progress * 100))% of daily goal")
                    .font(.title2)
                    .bold()
            }
            .frame(width: 200, height: 200)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(progress * 1000)) cal")
                        .font(.headline)
                    Text("Cal Burned")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("1,000 cal")
                        .font(.headline)
                    Text("Daily Goal")
                        .font(.caption)
                }
            }
            .padding()
            
            // Statistic Bar Graph
            VStack(alignment: .leading) {
                Text("Statistic")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                // Calculating scale factor based on max calories
                let maxCalories = hourlyCaloriesBurned.max() ?? 0
                let maxHeight: Double = 100 // The max height you want for your tallest bar
                let scaleFactor = maxCalories > 0 ? maxHeight / maxCalories : 0
                
                // Creating the bar graph
                VStack {
                    HStack(alignment: .bottom, spacing: 0.5) {
                        ForEach(0..<hourlyCaloriesBurned.count, id: \.self) { index in
                            VStack {
                                // Create a bar for each hour
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(hourlyCaloriesBurned[index] > 0 ? Color.orange : Color.clear)
                                    .frame(width: 12, height: max(CGFloat(hourlyCaloriesBurned[index]) * scaleFactor, 2))
                                    .padding(.bottom, 8)
                                // Add hour labels at the bottom
                                Text(index % 3 == 0 ? "\(index % 12 == 0 ? 12 : index % 12)\(index < 12 ? "\nAM" : "\nPM")" : " ")
                                    .font(.system(size: 6)) // Smaller font size to ensure it fits
                                    .frame(height: 20)
                            }
                        }
                    }
                }
                .frame(height: 120) // Set the height of the entire bar graph container
            }
            .padding(.horizontal)
            
            
            
            Spacer() // Pushes everything to the top
        }
        .padding()
        .onAppear {
            // Request HealthKit authorization first
            manager.requestAuthorization { authorized, error in
                if let error = error {
                    // Handle any errors here
                    print("Authorization Error: \(error.localizedDescription)")
                } else if authorized {
                    // Fetch workouts only after authorization is granted
                    manager.fetchWorkouts { (workouts, error) in
                        if let error = error {
                            // Handle any errors here
                            print("Error fetching workouts: \(error.localizedDescription)")
                        } else if let workouts = workouts {
                            // Process the retrieved workouts here
                            for workout in workouts {
                                print("Workout: \(workout.workoutActivityType), \(workout.startDate), \(workout.duration), \(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) kcal")
                            }
                        }
                    }
                } else {
                    print("HealthKit authorization was not granted.")
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
