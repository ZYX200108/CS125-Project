//
//  signUpView.swift
//  CS125
//
//  Created by zhe yuan on 2/7/24.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject public var authViewModel: AuthenticationViewModel
    @Binding var signUpView: Bool
    @State var dataCollectionView: Bool = false
    
    @State var userName = ""
    @State var userEmail = ""
    @State var userPW = ""
    
    var body: some View {
        VStack {
            VStack{
                Text("Sign Up")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                HStack{
                    Text("Already have an account?")
                    Button("Log in") {
                        signUpView = false
                        authViewModel.initialize()
                    }
                }
            }
            .padding(.bottom, 30)
            
            HStack {
                Image(systemName: "person")
                    .frame(width: 24, height: 24)
                TextField("User name", text: $userName)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .frame(width:330)
            }
            .padding(.bottom, 30)
            
            HStack {
                Image(systemName: "envelope")
                    .frame(width: 24, height: 24)
                TextField("Email", text: $userEmail)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .frame(width:330)
            }
            .padding(.bottom, 30)
            
            HStack {
                Image(systemName: "key.horizontal")
                    .frame(width: 24, height: 24)
                SecureField("Password", text: $userPW)
                    .textFieldStyle(.roundedBorder)
                    .frame(width:330)
            }
            .padding(.bottom, 30)
            
            Button("Continue") {
                dataCollectionView = true
                DispatchQueue.main.async {
                    authViewModel.email = self.userEmail
                    authViewModel.displayName = self.userName
                    authViewModel.password = self.userPW
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .sheet(isPresented: $dataCollectionView) {
                UserDataCollectionView(authViewModel: authViewModel, dataCollectionView: $dataCollectionView)
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthenticationViewModel()
        SignUpView(authViewModel: authViewModel, signUpView: .constant(true))
    }
}
