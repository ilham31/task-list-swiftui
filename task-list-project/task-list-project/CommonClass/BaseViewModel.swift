//
//  BaseViewModel.swift
//  task-list-project
//
//  Created by Muhammad Ilham Ramadhan on 21/09/24.
//

import Foundation

class BaseViewModel: ObservableObject {
    var networkMonitor: NetworkMonitor
    
    init() {
        networkMonitor = NetworkMonitor()
    }
}
