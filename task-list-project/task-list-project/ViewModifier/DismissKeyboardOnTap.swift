//
//  DismissKeyboardOnTap.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import SwiftUI

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.endEditing(true)
            }
    }
}
