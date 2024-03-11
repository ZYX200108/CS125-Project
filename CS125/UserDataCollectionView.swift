//
//  UserDataCollectionView.swift
//  CS125
//
//  Created by zhe yuan on 2/21/24.
//

import SwiftUI

struct UserDataCollectionView: View {
    @StateObject var dataViewModel = UserDataCollectionViewModel()
    @ObservedObject public var authViewModel: AuthenticationViewModel
    @Binding var dataCollectionView: Bool
    @State private var newAllergy: String = ""
    @State private var newCat: String = "Select a category"
    public var httpModel = httpRequestModel()
    
    let ageRange = 1...100
    let weightRange = 50...300
    let heightRange = 100...250
    let yearRange = 2024...2030
    let monthRange = 1...12
    let sexOption = ["Male", "Female"]
    let activityLevels = ["sedentary", "lightly active", "moderately active", "very active"]

    var body: some View {
        Text("Data Collection")
            .fontWeight(.bold)
            .font(.largeTitle)
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Sex")
                            .font(.headline)
                        
                        Menu {
                            ForEach(sexOption, id: \.self) { value in
                                Button("\(value)") {
                                    dataViewModel.sex = value
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(dataViewModel.sex)")
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
                    
                    DateView(title:"Target Date", years: yearRange, months: monthRange, dataViewModel: dataViewModel)
                    dataChoiceView(title: "Age", range: ageRange, selection: $dataViewModel.age)
                    dataChoiceView(title: "Height", range: heightRange, selection: $dataViewModel.height)
                    dataChoiceView(title: "Current Weight", range: weightRange, selection: $dataViewModel.weight)
                    dataChoiceView(title: "Target Weight", range: weightRange, selection: $dataViewModel.targetWeight)
                    
                    VStack(alignment: .leading) {
                        Text("Activity Level")
                            .font(.headline)
                        
                        Menu {
                            ForEach(activityLevels, id: \.self) { value in
                                Button("\(value)") {
                                    dataViewModel.activityLevel = value
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(dataViewModel.activityLevel)")
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
                            dataViewModel.addAllergy(newAllergy)
                            newAllergy = ""
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
                                ForEach(dataViewModel.foodAllergies.indices, id: \.self) { index in
                                    HStack {
                                        Text(dataViewModel.foodAllergies[index])
                                            .padding(5)
                                            .padding(.leading, 15)
                                            .id(index)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Button(action: {
                                            dataViewModel.removeAllergy(at: IndexSet(integer: index))
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
                
                Text("Food Categories")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                
                VStack {
                    HStack {
                        Menu {
                            ForEach(dataViewModel.food_cat, id: \.self) { value in
                                Button("\(value)") {
                                    self.newCat = value
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(self.newCat)")
                                    .padding(.leading, 5)
                                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                        }
                        
                        Button(action: {
                            guard !self.newCat.isEmpty else { return }
                            dataViewModel.addCat(self.newCat)
                            self.newCat = "Select a category"
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
                                ForEach(dataViewModel.foodCategories.indices, id: \.self) { index in
                                    HStack {
                                        Text(dataViewModel.foodCategories[index])
                                            .padding(5)
                                            .padding(.leading, 15)
                                            .id(index)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Button(action: {
                                            dataViewModel.removeCat(at: IndexSet(integer: index))
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
                
                HStack {
                    Button(" Back     ") {
                        dataCollectionView = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .frame(width: 200, height: 20)
                    
                    Button("Sign Up") {
                        Task {
                            print("sign up button clicked")
                            await authViewModel.signUpWithEmail()
                            await dataViewModel.saveUserData(userName: authViewModel.displayName, email: authViewModel.email)
                            httpModel.initializeUser(userName: authViewModel.displayName) { response in }
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .frame(width: 200, height: 20)
                }
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct dataChoiceView: View {
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

struct DateView: View {
    let title: String
    let years: ClosedRange<Int>
    let months: ClosedRange<Int>
    @ObservedObject var dataViewModel: UserDataCollectionViewModel
    
    let days: [Int: ClosedRange<Int>] =
    [1: 1...31,
     2: 1...29,
     3: 1...31,
     4: 1...30,
     5: 1...31,
     6: 1...30,
     7: 1...31,
     8: 1...31,
     9: 1...30,
     10: 1...31,
     11: 1...30,
     12: 1...31]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            HStack {
                Menu {
                    ForEach(years, id: \.self) { value in
                        Button(String(value)) {
                            dataViewModel.targetYear = value
                        }
                    }
                } label: {
                    HStack {
                        Text(String(dataViewModel.targetYear))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                }
                
                Menu {
                    ForEach(months, id: \.self) { value in
                        Button("\(value)") {
                            dataViewModel.targetMonth = value
                        }
                    }
                } label: {
                    HStack {
                        Text("\(dataViewModel.targetMonth)")
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                }
                
                Menu {
                    ForEach(days[dataViewModel.targetMonth]!, id: \.self) { value in
                        Button("\(value)") {
                            dataViewModel.targetDay = value
                        }
                    }
                } label: {
                    HStack {
                        Text("\(dataViewModel.targetDay)")
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
        }
        .padding(.leading, 15)
        .padding(.vertical, 5)
    }
}

struct UserDataCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthenticationViewModel()
        UserDataCollectionView(authViewModel: authViewModel, dataCollectionView: .constant(true))
    }
}
