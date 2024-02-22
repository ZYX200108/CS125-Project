//
//  authenticationView.swift
//  CS125
//
//  Created by zhe yuan on 2/6/24.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct AuthenticationView: View {
    @ObservedObject public var authViewModel: AuthenticationViewModel
    @State private var signUpView: Bool = false

    var body: some View {
        VStack{
            VStack {
                Image("AuthImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300)
                
                Text("Login")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: "envelope")
                        .frame(width: 24, height: 24)
                    TextField("Email", text: $authViewModel.email)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding(.bottom, 5)
                
                HStack {
                    Image(systemName: "key.horizontal")
                        .frame(width: 24, height: 24)
                    SecureField("Password", text: $authViewModel.password)
                }
                .padding(.bottom, 1)
                
                Button("Log in") {
                    Task {
                        await authViewModel.signInWithEmail()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                
            }
            .padding()
            
            HStack {
                VStack {Divider()}
                Text("or")
                VStack {Divider()}
            }
            
            VStack {
                SignInWithAppleButton(
                    onRequest: { request in },
                    onCompletion: {result in }
                )
                .frame(maxWidth: 350, minHeight: 60, maxHeight: 60)
                .cornerRadius(8)
                .padding(.top)
                .padding(.bottom)
                
                HStack {
                    Text("Don't have an account yet?")
                    Button("Sign Up") {
                        signUpView = true
                        self.authViewModel.initialize()
                    }
                }
                .sheet(isPresented: $signUpView) {
                    SignUpView(authViewModel: authViewModel, signUpView: $signUpView)
                }
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthenticationViewModel()
        AuthenticationView(authViewModel: authViewModel)
    }
}

