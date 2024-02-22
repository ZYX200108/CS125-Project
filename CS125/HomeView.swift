//
//  HomeView.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import SwiftUI
import HealthKit

struct HomeView: View {
    @ObservedObject var healthKitManager = HealthKitManager()
    @State private var healthData = HealthData(hourlyCalories: [], totalSteps: 0)
    @State private var progress: CGFloat = 0
    @State private var dailySteps = 0
    @State private var dailyGoal = 1000
    @State private var dailyCal = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("You have walked \(dailySteps) steps today")
                .font(.title)
                .padding(.top)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                Text("\(Int(progress * 100))% of daily goal")
                    .font(.title2)
                    .bold()
            }
            .frame(width: 200, height: 200)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(dailyCal) cal")
                        .font(.headline)
                    Text("Cal Burned")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(dailyGoal) cal")
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
                let maxCalories = healthData.hourlyCalories.max() ?? 1 // Avoid division by zero
                let maxHeight: Double = 100 // The max height you want for your tallest bar
                let scaleFactor = maxCalories > 0 ? maxHeight / maxCalories : 0
                
                // Creating the bar graph
                HStack(alignment: .bottom, spacing: 0.5) {
                    ForEach(0..<healthData.hourlyCalories.count, id: \.self) { index in
                        VStack {
                            // Create a bar for each hour
                            RoundedRectangle(cornerRadius: 4)
                                .fill(healthData.hourlyCalories[index] > 0 ? Color.orange : Color.clear)
                                .frame(width: 12, height: max(CGFloat(healthData.hourlyCalories[index]) * CGFloat(scaleFactor), 2))
                                .padding(.bottom, 8)
                            // Add hour labels at the bottom
                            Text(index % 3 == 0 ? "\(index % 12 == 0 ? 12 : index % 12)\(index < 12 ? "\nAM" : "\nPM")" : " ")
                                .font(.system(size: 6)) // Smaller font size to ensure it fits
                                .frame(height: 20)
                        }
                    }
                }
                .frame(height: 120) // Set the height of the entire bar graph container
            }
            .padding(.horizontal)
            
//            Spacer()
        }
        .padding()
        .onAppear {
            healthKitManager.requestAuthorization { authorized, error in
                if authorized {
                    healthKitManager.fetchHourlyCalories { data in
                        DispatchQueue.main.async {
                            self.healthData = data
                            self.dailySteps = healthData.totalSteps
                            self.dailyCal = Int(healthData.hourlyCalories.reduce(0.0, { $0 + Double($1) }))
                            self.progress = CGFloat(dailyCal) / CGFloat(dailyGoal)
                        }
                    }
                } else {
                    print("Authorization Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
