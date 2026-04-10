---
name: create-feature
description: TCA Feature 보일러플레이트를 생성한다. 새로운 화면(Feature)을 추가할 때 사용한다.
argument-hint: Feature이름
---

# TCA Feature 생성

신규 TCA Feature에 필요한 파일과 폴더 구조를 컨벤션에 맞게 생성한다.

---

## 실행 절차

1. 사용자에게 argument를 통해 이름을 받는다. (예: `Congestion`, `Search`)
2. `Presentation/{Name}/` 폴더 아래에 아래 구조로 파일을 생성한다
3. 각 파일은 `templates/` 안의 템플릿을 참고하여 `{Name}`을 실제 이름으로 치환해서 작성한다
4. `SubwayWhen.xcodeproj/project.pbxproj`에 파일을 추가해야 함을 사용자에게 안내한다

---

## 생성 폴더 구조

```
Presentation/{Name}/
├── {Name}Feature.swift                        ← templates/feature.md 참고
├── {Name}View.swift                           ← templates/view.md 참고
├── Coordinator/
│   └── Protocol/
│       └── {Name}CoordinatorProtocol.swift    ← templates/coordinator-protocol.md 참고
└── Entity/
    └── Protocol/
```

---

## ✅ 생성 후 체크리스트

- [ ] Xcode에서 파일을 프로젝트에 추가 (타겟: SubwayWhen)
- [ ] `SubwayWhen/Service/Dependency+.swift`에 필요한 의존성 등록
- [ ] Coordinator에서 `{Name}View` 화면 전환 로직 연결
