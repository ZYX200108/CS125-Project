//
//  UserDataCollectionView.swift
//  CS125
//
//  Created by zhe yuan on 2/21/24.
//

import SwiftUI

struct UserDataCollectionView: View {
    @ObservedObject var viewModel = UserDataCollectionViewModel()
    @State private var newAllergy: String = ""
    
    let ageRange = 1...100
    let weightRange = 50...300
    let heightRange = 100...250

    var body: some View {
        VStack {
            Text("Data Collection")
                .fontWeight(.bold)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                SectionView(title: "Age", range: ageRange, selection: $viewModel.age)
                SectionView(title: "Height", range: heightRange, selection: $viewModel.height)
                SectionView(title: "Current Weight", range: weightRange, selection: $viewModel.weight)
                SectionView(title: "Target Weight", range: weightRange, selection: $viewModel.targetWeight)
            }
            
            Text("Food Allergies")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 15)
            
            VStack {
                HStack {
                    TextField("Enter a new food allergy", text: $newAllergy)
                        .padding(.leading, 20)
                    
                    Button(action: {
                        guard !newAllergy.isEmpty else { return }
                        viewModel.addAllergy(newAllergy)
                        newAllergy = "" // Clear the input field after adding
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.green)
                    }
                    .padding(.trailing, 20)
                }
                
                ScrollView(.vertical) {
                    ScrollViewReader { value in
                        VStack {
                            ForEach(viewModel.foodAllergies.indices, id: \.self) { index in
                                HStack {
                                    Text(viewModel.foodAllergies[index])
                                        .padding(5)
                                        .padding(.leading, 15)
                                        .id(index)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Button(action: {
                                        viewModel.removeAllergy(at: IndexSet(integer: index))
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.trailing, 22)
                                }
                                
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 130)
            }
            .padding(.leading, 15)
            .padding(.bottom, 15)
            
            Button("Continue") {
                Task {
                    await viewModel.saveUserData(userName: "test")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

struct SectionView: View {
    let title: String
    let range: ClosedRange<Int>
    @Binding var selection: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            Menu {
                ForEach(range, id: \.self) { value in
                    Button("\(value)") {
                        selection = value
                    }
                }
            } label: {
                HStack {
                    Text("\(selection)")
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
            }
        }
        .padding(.leading, 15)
        .padding(.vertical, 5)
    }
}

#Preview {
    UserDataCollectionView()
}
