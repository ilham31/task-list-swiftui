//
//  Extension-View.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTap())
    }
}

