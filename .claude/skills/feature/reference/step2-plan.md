# Step 2. plan 생성

## Step 2-1. plan.md 생성

- `spec.md` 의 `## 무엇에 의존하는가` 에 명시된 파일을 읽고 현재 상태를 파악한다
  - 명시되지 않은 경우 spec.md 내용 기반으로 영향 범위를 직접 판단한다
- `.claude/templates/plan.template.md` 를 참고하여 plan.md 를 작성한다
- 코드는 작성하지 않는다
- `.claude/specs/features/$ARGUMENTS/plan.md` 로 저장한다

## Step 2-2. 인간 확인

```
✅ plan.md 생성 완료
📁 위치: .claude/specs/features/$ARGUMENTS/plan.md

plan.md 를 검토해주세요.
계속하려면 '확인', 수정이 필요하면 내용을 알려주세요.
```

'확인' 입력 후 `step3-tasks.md` 를 읽고 절차를 따른다.
