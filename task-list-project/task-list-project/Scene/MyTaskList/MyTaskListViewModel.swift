//
//  MyTaskListViewModel.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreData

class MyTaskListViewModel: BaseViewModel {
    @Published var tasks: [TaskModel] = []
    @Published var filteredTask: [TaskModel] = []
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var isLoggedOut = false
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    var coreDataContext: NSManagedObjectContext?
    
    //MARK: - Method
    func searchData() {
        if searchText.isEmpty {
            isSearching = false
            filteredTask = []
            fetchTaskData()
        } else {
            isSearching = true
            filteredTask = tasks.filter({$0.taskName.lowercased().contains(searchText.lowercased())})
        }
    }
    
    func fetchTaskData() {
        if networkMonitor.checkConnection() {
            checkIsLocalDataNotSynced()
        } else {
            let localTask = getLocalTasks()
            let syncTask = localTask.compactMap{ localTask in
                let taskId = localTask.taskRemoteId?.isEmpty == false ? localTask.taskRemoteId : UUID().uuidString
                let taskName = localTask.taskName ?? ""
                let taskIsDone = localTask.isDone
                return TaskModel(id: taskId ?? "", taskName: taskName, isDone: taskIsDone)
            }
            tasks = syncTask
        }
    }
    
    func updateTaskData(task: TaskModel, newStatus: Bool) {
        updateFireStoreTaskStatus(task: task, newStatus: newStatus)
    }
    
    func deleteTaskData(task: TaskModel) {
        deleteFireStoreTask(task: task)
    }
    
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userUID")
            isLoggedOut = true
            resetCoreData()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
    }
    
    //MARK: - Firestore Request
    private func fetchFireStoreTasks() {
        guard let userUID = UserDefaults.standard.string(forKey: "userUID") else { return }
        isLoading = true
        db.collection("users").document(userUID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                let localTask = self.getLocalTasks()
                let syncTask = localTask.compactMap{ localTask in
                    let taskId = localTask.taskRemoteId?.isEmpty == false ? localTask.taskRemoteId : UUID().uuidString
                    let taskName = localTask.taskName ?? ""
                    let taskIsDone = localTask.isDone
                    return TaskModel(id: taskId ?? "", taskName: taskName, isDone: taskIsDone)
                }
                tasks = syncTask
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data(), let tasksArray = data["tasks"] as? [[String: Any]] {
                    if self.isSearching {
                        let task: [TaskModel] = tasksArray.compactMap { taskData in
                            guard let taskID = taskData["task_id"] as? String,
                                  let taskName = taskData["task_name"] as? String,
                                  let taskIsDone = taskData["task_is_done"] as? Bool else { return nil }
                            
                            return TaskModel(id: taskID, taskName: taskName, isDone: taskIsDone)
                        }
                        self.filteredTask = task.filter({$0.taskName.lowercased().contains(self.searchText.lowercased())})
                    } else {
                        self.tasks = tasksArray.compactMap { taskData in
                            guard let taskID = taskData["task_id"] as? String,
                                  let taskName = taskData["task_name"] as? String,
                                  let taskIsDone = taskData["task_is_done"] as? Bool else { return nil }
                            
                            return TaskModel(id: taskID, taskName: taskName, isDone: taskIsDone)
                        }
                        resetCoreDataAndAddNewTasks(newTasks: tasks)
                    }
                }
            }
        }
    }
    
    private func updateFireStoreTaskStatus(task: TaskModel, newStatus: Bool) {
        isLoading = true
        let db = Firestore.firestore()
        
        guard let userUID = UserDefaults.standard.string(forKey: "userUID") else { return }

        // Remove the old task
        db.collection("users").document(userUID).updateData([
            "tasks": FieldValue.arrayRemove([task.toDictionary()])
        ]) { [weak self] error in
            self?.isLoading = false
            if let error = error {
                print("Error removing old task: \(error.localizedDescription)")
            } else {
                // Create the updated task
                let updatedTask = TaskModel(id: task.id, taskName: task.taskName, isDone: newStatus)
                
                // Add the updated task
                db.collection("users").document(userUID).updateData([
                    "tasks": FieldValue.arrayUnion([updatedTask.toDictionary()])
                ]) { [weak self] error in
                    if let error = error {
                        print("Error adding updated task: \(error.localizedDescription)")
                    } else {
                        self?.fetchTaskData()
                    }
                }
            }
        }
    }
    
    private func deleteFireStoreTask(task: TaskModel) {
        isLoading = true
        guard let userUID = UserDefaults.standard.string(forKey: "userUID") else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).updateData([
            "tasks": FieldValue.arrayRemove([task.toDictionary()])
        ]) { [weak self] error in
            if let error = error {
                print("Error removing old task: \(error.localizedDescription)")
            } else {
                self?.fetchTaskData()
            }
        }
    }
    
    func replaceFireStoreTasks(to newTasks: [[String: Any]]) {
        guard let userUID = UserDefaults.standard.string(forKey: "userUID") else { return }

        let db = Firestore.firestore()
        let userDocumentRef = db.collection("users").document(userUID)

        userDocumentRef.setData(["tasks": newTasks], merge: true) { [weak self] error in
            if let error = error {
                print("Error updating tasks: \(error.localizedDescription)")
            } else {
                self?.fetchFireStoreTasks()
            }
        }
    }
    
    //MARK: - Core Data Request
    private func resetCoreData() {
        let entityNames = coreDataContext?.persistentStoreCoordinator?.managedObjectModel.entities.map({ $0.name }) ?? []
        
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try coreDataContext?.execute(deleteRequest)
            } catch let error as NSError {
                print("Error deleting \(entityName!): \(error.localizedDescription)")
            }
        }
        
        do {
            try coreDataContext?.save()
        } catch let error as NSError {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
    
    private func resetCoreDataAndAddNewTasks(newTasks: [TaskModel]) {
        guard let context = coreDataContext else { return }
        let fetchRequest: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        
        do {
            let existingTasks = try context.fetch(fetchRequest)
            for task in existingTasks {
                context.delete(task)
            }
            
            for newTask in newTasks {
                let taskData = TaskData(context: context)
                taskData.taskRemoteId = newTask.id
                taskData.taskName = newTask.taskName
                taskData.isDone = newTask.isDone
                taskData.isSync = true
            }
            
            try context.save()
            
        } catch {
            print("Failed to reset Core Data: \(error.localizedDescription)")
        }
    }
    
    private func checkIsLocalDataNotSynced() {
        let tasks = getLocalTasks()
        if !tasks.isEmpty {
            let unsyncData = tasks.filter({!$0.isSync})
            if unsyncData.count > 0 {
                if networkMonitor.checkConnection() {
                    var taskData = [[String: Any]]()
                    tasks.forEach { localTask in
                        let taskId = localTask.taskRemoteId?.isEmpty == false ? localTask.taskRemoteId : UUID().uuidString
                        let taskName = localTask.taskName ?? ""
                        let taskIsDone = localTask.isDone
                        let buildData: [String: Any] = [
                            "task_id": taskId ?? "",
                            "task_name": taskName,
                            "task_is_done": taskIsDone
                        ]
                        taskData.append(buildData)
                    }
                    replaceFireStoreTasks(to: taskData)
                }
            } else {
                fetchFireStoreTasks()
            }
        } else {
            fetchFireStoreTasks()
        }
    }
    
    private func getLocalTasks() -> [TaskData] {
        guard let context = coreDataContext else { return [] }
        
        let fetchRequest: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
        }
        return []
    }

}
