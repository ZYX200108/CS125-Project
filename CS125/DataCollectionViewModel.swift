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
        
    func addAllergy(_ allergy: String) {
        foodAllergies.append(allergy)
    }
    
    func removeAllergy(at offsets: IndexSet) {
        foodAllergies.remove(atOffsets: offsets)
    }
    
    func saveUserData(userName: String) async {
        do {
          let ref = try await db.collection("users").addDocument(data: [
            "name": userName,
            "age": age,
            "weight": weight,
            "targetWeight": targetWeight,
            "height": height,
            "allergies": foodAllergies
          ])
          print("Document added with ID: \(ref.documentID)")
        } catch {
          print("Error adding document: \(error)")
        }
    }
}
