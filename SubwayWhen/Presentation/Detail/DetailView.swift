//
//  DetailView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    @State private var store: StoreOf<DetailFeature>
    
    init(store: StoreOf<DetailFeature>) {
        self.store = store
    }
    
    var body: some View {
        Text("")
    }
}

#Preview {
    DetailView(store: .init(initialState: .init(), reducer: {}))
}
