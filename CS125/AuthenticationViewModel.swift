//
//  AuthenticationViewModel.swift
//  CS125
//
//  Created by zhe yuan on 2/6/24.
//

import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var displayName: String = ""
    public var programStart: Bool = false

    @Published var errorMessage: String?
    
    @Published var isUserAuthenticated: Bool = false
    
    init() {
        checkAuthState()
    }

    func signInWithEmail() async {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            let current_user = authResult.user
            DispatchQueue.main.async {
                self.isUserAuthenticated = true
                self.displayName = current_user.displayName ?? "unknown user"
            }
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signUpWithEmail() async {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: self.email, password: self.password)
            self.updateDisplayName(displayName: self.displayName, authResult: authResult)
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOutWithEmail() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isUserAuthenticated = false
            }
            self.initialize()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func checkAuthState() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.isUserAuthenticated = true
                if self.programStart == false {
                    self.email = user?.email ?? "unknown email"
                    self.displayName = user?.displayName ?? "unknown user"
                    self.programStart = true
                }
            } else {
                self.isUserAuthenticated = false
            }
        }
        
        if self.isUserAuthenticated {
            let current_user = Auth.auth().currentUser
            self.email = current_user?.email ?? "unknown email"
            self.displayName = current_user?.displayName ?? "unknown user"
        }
    }
    
    func updateDisplayName(displayName: String, authResult: AuthDataResult?) {
        let changeRequest = authResult?.user.createProfileChangeRequest()
        changeRequest?.displayName = self.displayName
        changeRequest?.commitChanges { (error) in }
    }
    
    func initialize() {
        DispatchQueue.main.async {
            self.displayName = ""
            self.email = ""
            self.password = ""
        }
    }
    
    func signInWithApple() async {
    }
}
