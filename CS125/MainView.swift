//
//  mainView.swift
//  CS125
//
//  Created by zhe yuan on 2/6/24.
//

import SwiftUI

struct MainView: View {
    @StateObject public var authViewModel = AuthenticationViewModel()
    @StateObject public var mainViewModel = MainViewModel()
    
    
    var body: some View {
        Group {
            if authViewModel.isUserAuthenticated {
                ContentView(authViewModel: authViewModel)
                    .environmentObject(mainViewModel)
            } else {
                AuthenticationView(authViewModel: authViewModel, mainViewModel: mainViewModel)
            }
        }.onAppear {
            // Assigning mainViewModel to authViewModel's property
            authViewModel.mainViewModel = mainViewModel
        }
    }
}

struct mainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
