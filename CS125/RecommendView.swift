//
//  RecommandTab.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/6/24.
//


import SwiftUI

struct RecommendView: View {
    @StateObject var viewModel = RecommendationRetrieveModel()  // Initialize the view model
    @State private var selectedRecipeIndex: Int?  // Use an optional integer to track the selected recipe by index
    @State private var confirmedRecipeName: String?
    public var userName: String = ""
    
    init(name: String) {
        self.userName = name
    }

    var body: some View {
        NavigationView {
            VStack {
                if let index = selectedRecipeIndex, viewModel.recipes.indices.contains(index) {
                    let selectedRecipe = viewModel.recipes[index]
                    RecipeDetailView(recipe: selectedRecipe, onConfirm: {
                        self.confirmedRecipeName = selectedRecipe.Name
                        self.selectedRecipeIndex = nil
                    }, onBack: {
                        self.selectedRecipeIndex = nil
                    })
                } else {
                    List(viewModel.recipes.indices, id: \.self) { index in  // Use indices of recipes array
                        let recipe = viewModel.recipes[index]
                        RecipeRowView(recipe: recipe, isConfirmed: self.confirmedRecipeName == recipe.Name)
                            .onTapGesture {
                                self.selectedRecipeIndex = index  // Assign the selected index
                            }
                            .opacity(self.confirmedRecipeName == nil || self.confirmedRecipeName == recipe.Name ? 1 : 0.3)
                    }
                    .navigationTitle("Recipes")
                    .onAppear {
                        viewModel.fetchRecommendation(userID: self.userName)
                    }
                }
            }
            .background(.white)
        }
        .background(.white)
    }
}

struct RecipeRowView: View {
    var recipe: RecipeStructure
    var isConfirmed: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recipe.Name)
                    .font(.headline)
                    .foregroundColor(isConfirmed ? .blue : .primary)
                Text("Ingredients: \(recipe.Ingredients)")
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
    var recipe: RecipeStructure
    var onConfirm: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(recipe.Name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Rectangle()  // Placeholder for image
                    .fill(Color.gray)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                
                Text("Ingredients: \(recipe.Ingredients)\n\nSteps:\n\n \(recipe.Steps)")
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
    }
}

// Preview
struct RecommendView_Previews: PreviewProvider {
    static var previews: some View {
        let name = "charlie"
        RecommendView(name: name)
    }
}
