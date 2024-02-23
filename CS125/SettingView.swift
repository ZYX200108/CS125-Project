//
//  SettingView.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject public var authViewModel: AuthenticationViewModel
    @State var isProfileViewActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Account")) {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(authViewModel.displayName)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(authViewModel.email)
                                .foregroundColor(.gray)
                        }
                        NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                            Text("Profile")
                        }
                    }
                    
                    Section(header: Text("Settings")) {
                        Toggle(isOn: .constant(true)) {
                            Text("Notifications")
                        }
                        Toggle(isOn: .constant(false)) {
                            Text("Dark Mode")
                        }
                    }
                    
                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Settings")
                
                Button("Sign Out", action: authViewModel.signOutWithEmail)
                    .padding(.bottom, 20)
            }
        }
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthenticationViewModel()
        SettingView(authViewModel: authViewModel)
    }
}
