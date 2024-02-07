//
//  mainView.swift
//  CS125
//
//  Created by zhe yuan on 2/6/24.
//

import SwiftUI

struct MainView: View {
    @StateObject public var viewModel = AuthenticationViewModel()
    
    var body: some View {
        Group {
            if viewModel.isUserAuthenticated {
                ContentView(viewModel: viewModel)
            } else {
                AuthenticationView(viewModel: viewModel)
            }
        }
    }
}

struct mainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
