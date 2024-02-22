//
//  AddActivity.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import SwiftUI

struct AddFoodView: View {
    @State private var carbs: Double = 0
    @State private var protein: Double = 0
    @State private var veggies: Double = 0
    @State private var showingPicker = false
    @State private var pickerValue: Double = 0
    @State private var activeNutrient: NutrientType?

    var body: some View {
        VStack(spacing: 30) {
            NutritionRingView(carbs: carbs, protein: protein, veggies: veggies)
                .frame(width: 200, height: 200)
                .padding(.bottom, 20)
            
            LegendView()

            // Your existing NutrientInputButtons and sheet
            HStack {
                NutrientInputButton(nutrient: "Carbohydrate", systemImage: "fork.knife", currentValue: carbs) {
                    self.activeNutrient = .carbs
                    self.pickerValue = carbs
                    self.showingPicker = true
                }.font(.system(size: 15))
                NutrientInputButton(nutrient: "Protein", systemImage: "fish.fill", currentValue: protein) {
                    self.activeNutrient = .protein
                    self.pickerValue = protein
                    self.showingPicker = true
                }.font(.system(size: 15))
                NutrientInputButton(nutrient: "Vegetables", systemImage: "leaf.fill", currentValue: veggies) {
                    self.activeNutrient = .veggies
                    self.pickerValue = veggies
                    self.showingPicker = true
                }.font(.system(size: 15))
            }
            .padding(.top, 50)
            .sheet(isPresented: $showingPicker) {
                NumberPickerView(selectedValue: $pickerValue) {
                    if let activeNutrient = activeNutrient {
                        switch activeNutrient {
                        case .carbs:
                            carbs = pickerValue
                        case .protein:
                            protein = pickerValue
                        case .veggies:
                            veggies = pickerValue
                        }
                    }
                    self.showingPicker = false
                }
            }

            Text("Total Calories: \(calculateTotalCalories(), specifier: "%.2f")")
                .padding()
        }
        .padding()
    }

    private func calculateTotalCalories() -> Double {
        (carbs + protein + veggies) * 4 // Simplified calculation for the example
    }
}

struct NutritionRingView: View {
    var carbs: Double
    var protein: Double
    var veggies: Double

    private var total: Double { carbs + protein + veggies }

    var body: some View {
        ZStack {
            if total == 0 {
                // Display a grey ring if there are no inputs
                Circle()
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .overlay(
                        Text("No Data")
                            .foregroundColor(.gray)
                            .font(.caption)
                    )
            } else {
                // Normal ring segments showing nutritional balance
                RingSegment(color: .green, startPercentage: 0, endPercentage: veggies / max(total, 1), label: "\(Int(veggies / max(total, 1) * 100))%")
                RingSegment(color: .red, startPercentage: veggies / max(total, 1), endPercentage: (veggies + carbs) / max(total, 1), label: "\(Int(carbs / max(total, 1) * 100))%")
                RingSegment(color: .blue, startPercentage: (veggies + carbs) / max(total, 1), endPercentage: 1, label: "\(Int(protein / max(total, 1) * 100))%")
            }
        }
    }
}

struct RingSegment: View {
    var color: Color
    var startPercentage: Double
    var endPercentage: Double
    var label: String

    var body: some View {
        ZStack {
            Circle()
                .trim(from: CGFloat(startPercentage), to: CGFloat(endPercentage))
                .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .overlay(
                    GeometryReader { geometry in
                        Text(label)
                            .font(.caption)
                            .position(x: geometry.size.width / 2, y: 25) // Adjust position as needed
                            .foregroundColor(.white)
                    }
                )
        }
    }
}

struct LegendView: View {
    var body: some View {
        HStack {
            LegendColor(color: .green, text: "Vegetables")
            LegendColor(color: .red, text: "Carbohydrate")
            LegendColor(color: .blue, text: "Protein")
        }
    }
}

struct LegendColor: View {
    var color: Color
    var text: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.caption)
        }
    }
}


struct NutrientInputButton: View {
    var nutrient: String
    var systemImage: String
    var currentValue: Double
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage) // Using system images
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black) // You can change the color as needed
                Text("\(nutrient): \(currentValue, specifier: "%.0f")g")
            }
        }
    }
}

struct NumberPickerView: View {
    @Binding var selectedValue: Double
    var doneAction: () -> Void

    var body: some View {
        VStack {
            Picker("Value", selection: $selectedValue) {
                ForEach(0..<100) { value in
                    Text("\(value)").tag(Double(value))
                }
            }
            .pickerStyle(WheelPickerStyle())

            Button("Done") {
                doneAction()
            }
        }
    }
}

enum NutrientType {
    case carbs, protein, veggies
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodView()
    }
}

