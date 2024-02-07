//
//  SettingView.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject public var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(viewModel.displayName)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(viewModel.email)
                            .foregroundColor(.gray)
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
            
            Button("Sign Out", action: viewModel.signOutWithEmail)
                .padding(.bottom, 20)
        }
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthenticationViewModel()
        SettingView(viewModel: viewModel)
    }
}
