//
//  RecommendationRetrieveModel.swift
//  CS125
//
//  Created by Yuxue Zhou on 3/12/24.
//

import FirebaseCore
import FirebaseFirestore
import Combine

struct RecipeStructure: Codable{
    var Calories: Float
    var Carbohydrate: Float
    var Cholesterol: Float
    var Fat: Float
    var Fiber: Float
    var Ingredients: String
    var Name: String
    var Protein: Float
    var Sodium: Float
    var Steps: String
    var Sugar: Float
}

class RecommendationRetrieveModel: ObservableObject {
    @Published var recipes: [RecipeStructure] = []
    let db = Firestore.firestore()
    @Published var errorMessage: String = ""
    
    func fetchRecommendation(userID: String) {
        let docRef = db.collection("users").document(userID).collection("Recommendation").document("Recommendation_string")
        docRef.getDocument { document, error in
            if let error = error {
                self.errorMessage = "Error getting document: \(error.localizedDescription)"
            } else if let document = document, document.exists, let data = document.data(), let recipesData = data["Data"] as? [[String: Any]] {
                // Convert each recipe dictionary to a RecipeStructure
                self.recipes = recipesData.compactMap { dict -> RecipeStructure? in
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                          let recipe = try? JSONDecoder().decode(RecipeStructure.self, from: jsonData) else {
                        return nil
                    }
                    return recipe
                }
                if self.recipes.isEmpty {
                    self.errorMessage = "No recipes could be decoded from the document."
                }
            } else {
                self.errorMessage = "Document does not exist or does not contain a 'Data' field"
            }
        }
    }

}
