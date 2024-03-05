//
//  DataCollectionViewModel.swift
//  CS125
//
//  Created by zhe yuan on 2/21/24.
//

import FirebaseCore
import FirebaseFirestore

class UserDataCollectionViewModel: ObservableObject {
    let db = Firestore.firestore()
    
    @Published var foodAllergies: [String] = []
    @Published var age: Int = 18
    @Published var weight: Int = 120
    @Published var targetWeight: Int = 120
    @Published var height: Int = 180
    @Published var sex: String = "Male"
    @Published var targetYear: Int = 2024
    @Published var targetMonth: Int = 11
    @Published var targetDay: Int = 11
        
    func addAllergy(_ allergy: String) {
        DispatchQueue.main.async {
            self.foodAllergies.append(allergy)
        }
    }
    
    func removeAllergy(at offsets: IndexSet) {
        DispatchQueue.main.async {
            self.foodAllergies.remove(atOffsets: offsets)
        }
    }
    
    func saveUserData(userName: String, email: String) async {
        do {
          let ref = try await db.collection("users").addDocument(data: [
            "name": userName,
            "age": age,
            "weight": weight,
            "targetWeight": targetWeight,
            "height": height,
            "allergies": foodAllergies,
            "email": email,
            "sex": sex,
            "target Date": [targetYear, targetMonth, targetDay]
          ])
          print("Document added with ID: \(ref.documentID)")
        } catch {
          print("Error adding document: \(error)")
        }
    }
}
