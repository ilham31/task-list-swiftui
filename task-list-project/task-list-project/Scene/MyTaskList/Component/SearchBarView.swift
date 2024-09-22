//
//  SearchBarView.swift
//  task-list
//
//  Created by Muhammad Ilham Ramadhan on 19/09/24.
//

import SwiftUI

struct SearchBarView: View {
    @EnvironmentObject var viewModel: MyTaskListViewModel
    
    var body: some View {
        TextField("Search", text: $viewModel.searchText)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onChange(of: viewModel.searchText, initial: false) {
                viewModel.searchData()
            }
    }
}
