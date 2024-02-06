//
//  SettingView.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        List {
            Section(header: Text("Account")) {
                HStack {
                    Text("Username")
                    Spacer()
                    Text("User123")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    Text("user@example.com")
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
    }
}


#Preview {
    SettingView()
}
