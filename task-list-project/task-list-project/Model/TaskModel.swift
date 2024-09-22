//
//  TaskModel.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import Foundation

struct TaskModel: Identifiable, Hashable {
    var id: String
    var taskName: String
    var isDone: Bool
    
    func toDictionary() -> [String: Any] {
        return [
            "task_id": id,
            "task_name": taskName,
            "task_is_done": isDone
        ]
    }
}
