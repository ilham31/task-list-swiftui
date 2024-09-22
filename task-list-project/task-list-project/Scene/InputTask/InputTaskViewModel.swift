//
//  InputTaskViewModel.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import Foundation
import FirebaseFirestore
import CoreData

class InputTaskViewModel: BaseViewModel {
    @Published var task = ""
    
    var coreDataContext: NSManagedObjectContext?
    
    //MARK: - Method
    func getNavigationTitle(isCreateNewTask: Bool) -> String {
        return isCreateNewTask ? "New Task" : "Edit Task"
    }
    
    func addTaskData(completion: @escaping (Result<Void, Error>) -> Void) {
        if networkMonitor.checkConnection() {
            addTaskToFirestore { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let error):
                    let task = TaskModel(id: UUID().uuidString, taskName: self.task, isDone: false)
                    self.insertNewTaskToCoreData(taskModel: task) { result in
                        switch result {
                        case .success():
                            completion(.success(()))
                        case .failure(let failure):
                            completion(.failure(failure))
                        }
                    }
                }
            }
        } else {
            let task = TaskModel(id: UUID().uuidString, taskName: task, isDone: false)
            insertNewTaskToCoreData(taskModel: task) { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
        }
    }

    
    //MARK: - Firestore Request
    private func addTaskToFirestore(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userUID = UserDefaults.standard.string(forKey: "userUID") else { return }
        let db = Firestore.firestore()
        
        let taskData: [String: Any] = [
            "task_id": UUID().uuidString,
            "task_name": task,
            "task_is_done": false
        ]
        
        db.collection("users").document(userUID).updateData([
            "tasks": FieldValue.arrayUnion([taskData])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    //MARK: - Core Data Method
    private func insertNewTaskToCoreData(taskModel: TaskModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let coreDataContext = coreDataContext else { return }
        let newTask = TaskData(context: coreDataContext)
        
        newTask.taskRemoteId = taskModel.id
        newTask.taskName = taskModel.taskName
        newTask.isDone = taskModel.isDone
        newTask.isSync = false

        do {
            try coreDataContext.save()
            completion(.success(()))
        } catch (let error) {
            completion(.failure(error))
        }
    }
}
