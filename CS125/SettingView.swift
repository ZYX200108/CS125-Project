//
//  SettingView.swift
//  CS125
//
//  Created by Yuxue Zhou on 2/5/24.
//
//  Edited by Zijie Liu on 2/23/24.

import SwiftUI
import UserNotifications

enum Theme: String {
    case light, dark
    
    mutating func toggle() {
        self = self == .light ? .dark : .light
    }
}

struct SettingView: View {
    @ObservedObject public var authViewModel: AuthenticationViewModel
    @State var isProfileViewActive = false
    @State private var notificationsEnabled = false
    @State private var showingSettingsAlert = false
    @State private var openAppSettings = false
    @AppStorage("themePreference") private var themePreference: Theme = .light
    
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
                        Toggle(isOn: $notificationsEnabled) {
                            Text("Notifications")
                        }
                        .onChange(of: notificationsEnabled) {
                            if notificationsEnabled {
                                showCustomAlert()
                            }
                        }
                        Toggle("Dark Mode", isOn: Binding(
                            get: { self.themePreference == .dark },
                            set: { newValue in self.themePreference = newValue ? .dark : .light }
                        ))
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
        .alert(isPresented: $showingSettingsAlert) {
            Alert(
                title: Text("Notification Permissions"),
                message: Text("Notifications have been disabled. Please enable them in Settings to continue."),
                primaryButton: .default(Text("Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel{
                    notificationsEnabled = false
                }
            )
        }
        .preferredColorScheme(themePreference == .dark ? .dark : .light)
        
    }
    
    private func showCustomAlert() {
            showingSettingsAlert = true
        }

    private func requestNotificationsPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                notificationsEnabled = true
                print("Notification permissions granted.")
            } else {
                showingSettingsAlert = true
                notificationsEnabled = false
                print("Notification permissions denied.")
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


struct ExampleView: View {
    @AppStorage("themePreference") private var themePreference: Theme = .light
        
        var body: some View {
            Text("Hello, World!")
                .foregroundColor(themePreference == .dark ? .white : .black)
                .background(themePreference == .dark ? Color.black : Color.white)
        }
}
