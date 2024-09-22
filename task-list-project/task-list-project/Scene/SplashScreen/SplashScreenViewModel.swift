//
//  SplashScreenViewModel.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 20/09/24.
//

import Foundation
import FirebaseAuth
import Firebase
import GoogleSignIn
import FirebaseFirestore

class SplashScreenViewModel: BaseViewModel {
    @Published var userData: User?
    @Published var isActive: Bool = false
    @Published var isRequestFinish: Bool = false
    
    // MARK: - Method
    func isUserAlreadySignIn() {
        if let user = Auth.auth().currentUser {
            self.userData = user
            isActive = true
            isRequestFinish = true
        } else {
            isActive = false
            isRequestFinish = true
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
                
        GIDSignIn.sharedInstance.configuration = config

        // Get the key window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            GIDSignIn.sharedInstance.signIn(withPresenting: window.rootViewController ?? UIViewController()) { result, error in
                if let error = error {
                    print("Google Sign-In error: \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user, let idToken = user.idToken else { return }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase sign-in error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let user = authResult?.user {
                        self.saveUserToFirestore(user: user)
                    }
                }
            }
        }
    }
    
    func saveUserToFirestore(user: User) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error checking user document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                self?.isActive = true
            } else {
                let userData = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "displayName": user.displayName ?? ""
                ]
                
                userRef.setData(userData) { [weak self] error in
                    if let error = error {
                        print("Error saving user to Firestore: \(error.localizedDescription)")
                    } else {
                        UserDefaults.standard.set(user.uid, forKey: "userUID")
                        self?.isActive = true
                    }
                }
            }
        }
    }

}
