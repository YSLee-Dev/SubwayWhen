# {Name}Feature.swift 템플릿

```swift
//
//  {Name}.swift
//  {타겟}
//
//  Created by 이윤수 on {날짜: MM/DD/YY}
//

import ComposableArchitecture

@Reducer
struct {Name}Feature {
    
    // MARK: - Dependency
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    // MARK: - Action
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
    }
    
    // MARK: - Reducer
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
            }
        }
    }
}
```
