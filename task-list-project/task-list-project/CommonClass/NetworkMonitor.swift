//
//  NetworkMonitor.swift
//  task-list-project
//
//  Created by Muhammad Ilham Ramadhan on 21/09/24.
//

import Network
import Combine

class NetworkMonitor: ObservableObject {
    private var isConnected: Bool = true
    private var monitor: NWPathMonitor?
    
    func checkConnection() -> Bool {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        return isConnected
    }
}


