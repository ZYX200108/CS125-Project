//
//  UserProfileViewModel.swift
//  CS125
//
//  Created by zhe yuan on 2/22/24.
//

import FirebaseCore
import FirebaseFirestore

class UserProfileViewModel: ObservableObject {
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
    
    private var docID: String = ""
    
    func addAllergy(_ allergy: String) {
        foodAllergies.append(allergy)
    }
    
    func removeAllergy(at offsets: IndexSet) {
        foodAllergies.remove(atOffsets: offsets)
    }
    
    func updateUserData() {
        let documentRef = db.collection("users").document(docID)
        let data = [
            "age": age,
            "weight": weight,
            "targetWeight": targetWeight,
            "height": height,
            "allergies": foodAllergies,
            "sex": sex,
            "target Date": [targetYear, targetMonth, targetDay]
        ] as [String : Any]
        
        documentRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func getUserData(email: String) async {
        do {
            let querySnapshot = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
            
            guard let user = querySnapshot.documents.first else {
                print("No matching documents found for email: \(email)")
                return
            }
            
            let userData = user.data()
            
            docID = user.documentID
            
            age = userData["age"] as? Int ?? 0
            weight = userData["weight"] as? Int ?? 0
            targetWeight = userData["targetWeight"] as? Int ?? 0
            height = userData["height"] as? Int ?? 0
            foodAllergies = userData["allergies"] as? [String] ?? []
            sex = userData["sex"] as? String ?? "Unknown"
            
            if let date = userData["target Date"] as? [Int], date.count == 3 {
                targetYear = date[0]
                targetMonth = date[1]
                targetDay = date[2]
            } else {
                print("Date is missing or not in the expected format.")
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
}
