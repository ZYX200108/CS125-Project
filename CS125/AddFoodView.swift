//
//  AddActivity.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import SwiftUI

//struct AddActivityView: View {
//    var body: some View {
//        Text("Hello, World!")
//    }
//}
import UIKit

class AddFoodView: UIViewController {

    let carbsTextField = UITextField()
    let proteinTextField = UITextField()
    let veggiesTextField = UITextField()
    let calculateButton = UIButton(type: .system)
    let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
    }

    private func setupViews() {
        // Configure text fields
        [carbsTextField, proteinTextField, veggiesTextField].forEach { textField in
            textField.borderStyle = .roundedRect
            textField.keyboardType = .decimalPad
        }

        // Configure button
        calculateButton.setTitle("Calculate Calories", for: .normal)
        calculateButton.addTarget(self, action: #selector(calculateCalories), for: .touchUpInside)

        // Configure label
        resultLabel.text = "Calories: 0"
        resultLabel.textAlignment = .center

        // Add subviews
        view.addSubview(carbsTextField)
        view.addSubview(proteinTextField)
        view.addSubview(veggiesTextField)
        view.addSubview(calculateButton)
        view.addSubview(resultLabel)
    }

    private func layoutViews() {
        // Layout your views programmatically or using Auto Layout
    }

    @objc func calculateCalories() {
        guard let carbs = Double(carbsTextField.text ?? ""),
              let protein = Double(proteinTextField.text ?? ""),
              let veggies = Double(veggiesTextField.text ?? "") else {
            // Handle invalid input
            return
        }

        let foodIntake = FoodIntake(carbs: carbs, protein: protein, veggies: veggies)
        let calories = foodIntake.totalCalories()
        resultLabel.text = "Calories: \(calories)"
    }
}

struct FoodIntake {
    var carbs: Double // in grams
    var protein: Double // in grams
    var veggies: Double // in grams

    func totalCalories() -> Double {
        let carbCalories = carbs * 4
        let proteinCalories = protein * 4
        let veggieCalories = veggies * 2
        return carbCalories + proteinCalories + veggieCalories
    }
}


#Preview {
    AddFoodView()
}
