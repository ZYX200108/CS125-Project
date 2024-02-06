//
//  ContentView.swift
//  CS125
//
//  Created by Yuxue Zhou on 1/23/24.
//


import SwiftUI

struct ContentView: View {
    @State var selectedTab = "Home"
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag("Home")
                .tabItem{
                    Image(systemName: "house")
                }
            AddActivity()
                .tag("Adding")
                .tabItem {
                    Image(systemName: "plus.app")
                }
            SettingView()
                .tag("Setting")
                .tabItem{
                    Image(systemName: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

