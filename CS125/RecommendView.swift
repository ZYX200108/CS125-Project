//
//  RecommandTab.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/6/24.
//

import SwiftUI

struct Recipe: Identifiable {
    var id: Int
    var name: String
    var authorName: String
    var cookTime: String
    var prepTime: String
    var description: String
    var imageUrl: String
    
    // Combine additional details into one description
    var detailedDescription: String {
        "Author: \(authorName)\nCook Time: \(cookTime)\nPrep Time: \(prepTime)\n\n\(description)"
    }
}

struct RecommendView: View {
    let recipes: [Recipe] = [
        Recipe(id: 38, name: "Low-Fat Berry Blue Frozen Dessert", authorName: "Dancer", cookTime: "PT24H", prepTime: "PT45M", description: "A delightful low-fat dessert that's perfect for a hot day.", imageUrl: "https://img.sndimg.com/food/image/upload/w_555,h_416,c_fit,fl_progressive,q_95/v1/img/recipes/38/YUeirxMLQaeE1h3v3qnM_229%20berry%20blue%20frzn%20dess.jpg"),
        Recipe(id: 39, name: "Biryani", authorName: "elly9812", cookTime: "PT25M", prepTime: "PT4H", description: "A flavorful and aromatic biryani recipe, perfect for any occasion.", imageUrl: "https://img.sndimg.com/food/image/upload/w_555,h_416,c_fit,fl_progressive,q_95/v1/img/recipes/39/picM9Mhnw.jpg"),
        Recipe(id: 40, name: "Best Lemonade", authorName: "Stephen Little", cookTime: "PT5M", prepTime: "PT30M", description: "A refreshing lemonade recipe, ideal for quenching your thirst.", imageUrl: "https://img.sndimg.com/food/image/upload/w_555,h_416,c_fit,fl_progressive,q_95/v1/img/recipes/40/picJ4Sz3N.jpg"),
        Recipe(id: 41, name: "Carina's Tofu-Vegetable Kebabs", authorName: "Cyclopz", cookTime: "PT20M", prepTime: "PT24H", description: "Delicious tofu and vegetable kebabs, perfect for a healthy meal.", imageUrl: "https://img.sndimg.com/food/image/upload/w_555,h_416,c_fit,fl_progressive,q_95/v1/img/recipes/41/picmbLig8.jpg"),
        Recipe(id: 42, name: "Cabbage Soup", authorName: "Duckie067", cookTime: "PT30M", prepTime: "PT20M", description: "A simple yet tasty cabbage soup recipe, great for a light meal.", imageUrl: "https://img.sndimg.com/food/image/upload/w_555,h_416,c_fit,fl_progressive,q_95/v1/img/recipes/42/picVEMxk8.jpg")
    ]
    
    @State private var selectedRecipe: Recipe?
    @State private var confirmedRecipeId: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                if let selectedRecipe = selectedRecipe {
                    RecipeDetailView(recipe: selectedRecipe, onConfirm: {
                        self.confirmedRecipeId = selectedRecipe.id
                        self.selectedRecipe = nil
                    }, onBack: {
                        self.selectedRecipe = nil
                    })
                } else {
                    List(recipes) { recipe in
                        RecipeRowView(recipe: recipe, isConfirmed: self.confirmedRecipeId == recipe.id)
                            .onTapGesture {
                                self.selectedRecipe = recipe
                            }
                            .opacity(self.confirmedRecipeId == nil || self.confirmedRecipeId == recipe.id ? 1 : 0.3)
                    }
                    .navigationTitle("Recipes")
                }
            }
        }
    }
}

struct RecipeRowView: View {
    var recipe: Recipe
    var isConfirmed: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(isConfirmed ? .blue : .primary)
                Text("By \(recipe.authorName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isConfirmed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecipeDetailView: View {
    var recipe: Recipe
    var onConfirm: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                
                Text(recipe.detailedDescription)
                    .font(.body)
                Spacer()
                HStack {
                    Button(action: onBack) {
                        Label("Back", systemImage: "arrow.left")
                    }
                    Spacer()
                    Button(action: onConfirm) {
                        Label("Confirm", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
//        .navigationTitle(recipe.name)
    }
}

// Preview
struct RecommendView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendView()
    }
}



