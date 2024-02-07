//
//  signUpView.swift
//  CS125
//
//  Created by zhe yuan on 2/7/24.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject public var viewModel: AuthenticationViewModel
    @Binding var signUpView: Bool
    
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
                        viewModel.initialize()
                    }
                }
            }
            .padding(.bottom, 30)
            
            HStack {
                Image(systemName: "person")
                    .frame(width: 24, height: 24)
                TextField("User name", text: $viewModel.displayName)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .frame(width:330)
            }
            .padding(.bottom, 30)
            
            HStack {
                Image(systemName: "envelope")
                    .frame(width: 24, height: 24)
                TextField("Email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .frame(width:330)
            }
            .padding(.bottom, 30)
            
            HStack {
                Image(systemName: "key.horizontal")
                    .frame(width: 24, height: 24)
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .frame(width:330)
            }
            .padding(.bottom, 30)
            
            Button("Sign Up") {
                Task {
                    await viewModel.signUpWithEmail()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthenticationViewModel()
        SignUpView(viewModel: viewModel, signUpView: .constant(true))
    }
}
