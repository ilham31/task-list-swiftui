//
//  InputTaskView.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import SwiftUI

struct InputTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = InputTaskViewModel()
    
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var isCreateNewTask: Bool = true
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text("Input Task")
                .padding()
            TextField("Please Input Your Task", text: $viewModel.task)
                .padding(.horizontal, 16)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    UIApplication.shared.endEditing(true)
                }
            HStack {
                Spacer()
                Button(action: {
                    handleTaskAddition()
                }, label: {
                    Text("Submit Task")
                        .padding()
                        .background(Color.blue)
                        .tint(Color.white)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
                .buttonStyle(PlainButtonStyle())
            }
            .padding([.trailing, .top], 16)
        }
        .alert(alertMessage, isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) { }
        })
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(viewModel.getNavigationTitle(isCreateNewTask: isCreateNewTask))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundColor(.blue) // Customize the back button color
                }
            }
        }.onAppear {
            viewModel.coreDataContext = viewContext
        }
    }
    
    private func handleTaskAddition() {
        viewModel.addTaskData { result in
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}

#Preview {
    InputTaskView(isCreateNewTask: false)
}
