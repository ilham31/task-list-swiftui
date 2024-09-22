//
//  Extension-UIApplication.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import UIKit

extension UIApplication {
    func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows
            .filter(\.isKeyWindow)
            .first?
            .endEditing(force)
    }
}
