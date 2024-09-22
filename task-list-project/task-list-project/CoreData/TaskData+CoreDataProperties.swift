//
//  TaskData+CoreDataProperties.swift
//  task-list-project
//
//  Created by Muhammad Ilham Ramadhan on 21/09/24.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isDone: Bool
    @NSManaged public var isSync: Bool
    @NSManaged public var taskName: String?
    @NSManaged public var taskRemoteId: String?

}

extension TaskData : Identifiable {

}
