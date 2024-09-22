//
//  MyTaskView.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import SwiftUI

struct MyTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = MyTaskListViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoggedOut {
                SplashScreenView()
                    .transition(.move(edge: .leading))
            } else {
                NavigationView {
                    VStack(alignment: .center, spacing: 8) {
                        SearchBarView()
                        if viewModel.isLoading {
                            ProgressView("Loading tasks...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        } else {
                            if viewModel.tasks.isEmpty {
                                Text("No task right now, please input new task")
                            } else {
                                List {
                                    ForEach(viewModel.isSearching ? viewModel.filteredTask : viewModel.tasks, id: \.self) { task in
                                        TaskView(task: task)
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                }
                                .listStyle(.plain)
                                .listRowSpacing(0)
                            }
                        }
                    }
                    .dismissKeyboardOnTap()
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .navigationTitle("My Task List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(destination: InputTaskView(isCreateNewTask: true)) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .tint(.yellow)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                viewModel.signOutUser()
                            }) {
                                Text("Log Out")
                            }
                        }
                    }
                    .onAppear {
                        viewModel.coreDataContext = viewContext
                        viewModel.fetchTaskData()
                    }
                    .environmentObject(viewModel)
                }
            }
        }
        .animation(.default, value: viewModel.isLoggedOut)
    }
}

#Preview {
    MyTaskView()
}

