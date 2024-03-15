//
//  ContentView.swift
//  CS125
//
//  Created by Yuxue Zhou on 1/23/24.
//


import SwiftUI

struct ContentView: View {
    @State var selectedTab = "Home"
    @ObservedObject public var authViewModel: AuthenticationViewModel
    @EnvironmentObject public var mainViewModel: MainViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(userName: authViewModel.displayName)
                .tag("Home")
                .tabItem{
                    Image(systemName: "house")
                }
//            AddFoodView()
//                .tag("Adding")
//                .tabItem {
//                    Image(systemName: "plus.app")
//                }
            if mainViewModel.recommendationReady {
                RecommendView(name: authViewModel.displayName)
                    .tag("Recommendation")
                    .tabItem {
                        Image(systemName: "lightbulb.max")
                    }
            }
            else if !mainViewModel.recommendationReady {
                ModelNotReadyView()
                    .tag("Recommendation")
                    .tabItem {
                        Image(systemName: "lightbulb.max")
                    }
            }
            SettingView(authViewModel: authViewModel)
                .tag("Setting")
                .tabItem{
                    Image(systemName: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthenticationViewModel()
        ContentView(authViewModel: authViewModel).environmentObject(MainViewModel())
    }
}

