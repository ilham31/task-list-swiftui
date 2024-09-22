//
//  TaskView.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import SwiftUI

struct TaskView: View {
    @EnvironmentObject var viewModel: MyTaskListViewModel
    var task: TaskModel
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                viewModel.updateTaskData(task: task, newStatus: !task.isDone)
            }) {
                Image(systemName: task.isDone ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(task.isDone ? .yellow : .gray)
            }
            .padding(16)
            Text(task.taskName)
                .font(.headline)
                .padding(.vertical, 16)
            Spacer()
            Button(action: {
                viewModel.deleteTaskData(task: task)
            }) {
                Image(systemName: "trash.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.red)
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(8)
        .padding()
        .shadow(radius: 8)
        .buttonStyle(PlainButtonStyle())
    }
}

