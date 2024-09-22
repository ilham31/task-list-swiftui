//
//  SplashScreenView.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import SwiftUI

struct SplashScreenView: View {
    @StateObject private var viewModel = SplashScreenViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isActive {
                MyTaskView()
                    .transition(.move(edge: .trailing)) // Add a transition here
            } else {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    Text("Task List App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    if viewModel.isRequestFinish {
                        Button(action: {
                            viewModel.signInWithGoogle()
                        }) {
                            Text("Sign in with Google")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .onAppear {
            viewModel.isUserAlreadySignIn()
        }
        .animation(.default, value: viewModel.isActive)
    }
}

#Preview {
    SplashScreenView()
}
