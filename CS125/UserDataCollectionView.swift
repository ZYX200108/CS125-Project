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
    
    let ageRange = 1...100
    let weightRange = 50...300
    let heightRange = 100...250
    let yearRange = 2024...2030
    let monthRange = 1...12
    let sexOption = ["Male", "Female"]

    var body: some View {
        Text("Data Collection")
            .fontWeight(.bold)
            .font(.largeTitle)
        ScrollView {
            VStack {
//                Text("Data Collection")
//                    .fontWeight(.bold)
//                    .font(.largeTitle)
                
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
                    SectionView(title: "Age", range: ageRange, selection: $dataViewModel.age)
                    SectionView(title: "Height", range: heightRange, selection: $dataViewModel.height)
                    SectionView(title: "Current Weight", range: weightRange, selection: $dataViewModel.weight)
                    SectionView(title: "Target Weight", range: weightRange, selection: $dataViewModel.targetWeight)
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
                            await authViewModel.signUpWithEmail()
                            await dataViewModel.saveUserData(userName: authViewModel.displayName, email: authViewModel.email)
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
