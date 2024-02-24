//
//  ProfileView.swift
//  CS125
//
//  Created by zhe yuan on 2/22/24.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject public var authViewModel: AuthenticationViewModel
    @StateObject var profileViewModel: UserProfileViewModel = UserProfileViewModel()
    
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
    
    @State var heightView: Bool = false
    @State var sexView: Bool = false
    @State var yearView: Bool = false
    @State var monthView: Bool = false
    @State var dayView: Bool = false
    @State var ageView: Bool = false
    @State var curWeightView: Bool = false
    @State var targetWeightView: Bool = false
    @State var newAllergy: String = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("Sex:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    Button(String(profileViewModel.sex)) {
                        sexView = true
                    }
                    .sheet(isPresented: $sexView) {
                        NavigationView {
                            Picker("Select your Sex", selection: $profileViewModel.sex) {
                                ForEach(["Male", "Female"], id: \.self) { value in
                                    Button("\(value)") {
                                        profileViewModel.sex = value
                                    }
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .navigationTitle("Sex")
                            .navigationBarItems(trailing: Button("Done") {
                                sexView = false
                            })
                        }
                    }
                }
                
                HStack {
                    Text("Target Date:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    HStack {
                        Button(String(profileViewModel.targetYear)) {
                            yearView = true
                        }
                        .sheet(isPresented: $yearView) {
                            dataView(title: "Year", range: 2024...2030, unit: "", buttonName: "Continue", selectedVar: $profileViewModel.targetYear, viewState: $yearView)
                        }
                        Text("/")
                        Button(String(profileViewModel.targetMonth)) {
                            monthView = true
                        }
                        .sheet(isPresented: $monthView) {
                            dataView(title: "Month", range: 1...12, unit: "", buttonName: "Continue", selectedVar: $profileViewModel.targetMonth, viewState: $monthView)
                        }
                        Text("/")
                        Button(String(profileViewModel.targetDay)) {
                            dayView = true
                        }
                        .sheet(isPresented: $dayView) {
                            dataView(title: "Day", range: days[profileViewModel.targetMonth] ?? 1...31, unit: "", buttonName: "Done", selectedVar: $profileViewModel.targetDay, viewState: $dayView)
                        }
                    }
                }
                
                HStack {
                    Text("Age:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    Button(String(profileViewModel.age)) {
                        ageView = true
                    }
                    .sheet(isPresented: $ageView) {
                        dataView(title: "Age", range: 1...100, unit: "", buttonName: "Done", selectedVar: $profileViewModel.age, viewState: $ageView)
                    }
                }
                
                HStack {
                    Text("Height:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    Button(String(profileViewModel.height)) {
                        heightView = true
                    }
                    .sheet(isPresented: $heightView) {
                        dataView(title: "Height", range: 1...200, unit: "cm", buttonName: "Done", selectedVar: $profileViewModel.height, viewState: $heightView)
                    }
                }
                
                HStack {
                    Text("Current Weight:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    Button(String(profileViewModel.weight)) {
                        curWeightView = true
                    }
                    .sheet(isPresented: $curWeightView) {
                        dataView(title: "Current Weight", range: 50...300, unit: "lb", buttonName: "Done", selectedVar: $profileViewModel.weight, viewState: $curWeightView)
                    }
                }
                
                HStack {
                    Text("Target Weight:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    Button(String(profileViewModel.targetWeight)) {
                        targetWeightView = true
                    }
                    .sheet(isPresented: $targetWeightView) {
                        dataView(title: "Target Weight", range: 50...300, unit: "lb", buttonName: "Done", selectedVar: $profileViewModel.targetWeight, viewState: $targetWeightView)
                    }
                }
                
                Text("Food Allergies: ")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                ForEach(profileViewModel.foodAllergies.indices, id: \.self) { index in
                    HStack {
                        Text(profileViewModel.foodAllergies[index])
                            .padding(5)
                            .padding(.leading, 50)
                            .id(index)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            profileViewModel.removeAllergy(at: IndexSet(integer: index))
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                HStack {
                    TextField("Enter a new food allergy", text: $newAllergy)
                        .padding(.leading, 55)
                    
                    Button(action: {
                        guard !newAllergy.isEmpty else { return }
                        profileViewModel.addAllergy(newAllergy)
                        newAllergy = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.green)
                    }
                }
                
                Button("Apply Changes") {
                    profileViewModel.updateUserData()
                }.padding(.leading, 20)
            }
        }.onAppear {
            Task {
                await profileViewModel.getUserData(email: authViewModel.email)
            }
        }
    }
}

struct dataView: View {
    let title: String
    let range: ClosedRange<Int>
    let unit: String
    let buttonName: String
    @Binding var selectedVar: Int
    @Binding var viewState: Bool

    var body: some View {
        NavigationView {
            Picker("Select your height", selection: $selectedVar) {
                ForEach(range, id: \.self) { value in
                    Button("\(value) \(unit)"){
                        selectedVar = value
                    }
                }
            }
            .pickerStyle(WheelPickerStyle())
            .navigationTitle(title)
            .navigationBarItems(trailing: Button(buttonName) {
                viewState = false
            })
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthenticationViewModel()
        ProfileView(authViewModel: authViewModel)
    }
}
