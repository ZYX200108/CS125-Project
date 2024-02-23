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
    
    
    @State var heightView: Bool = false
    @State var sexView: Bool = false
    
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
                    Text("Height:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    Button(String(profileViewModel.height)) {
                        heightView = true
                    }
                    .sheet(isPresented: $heightView) {
                        dataView(title: "Height", range: 1...200, unit: "cm", selectedVar: $profileViewModel.height, viewState: $heightView)
                    }
                }
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
            .navigationBarItems(trailing: Button("Done") {
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
