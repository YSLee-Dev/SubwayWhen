# Step 1. spec 생성

## 절차

1. `.claude/templates/spec.template.md` 를 읽는다
2. `.claude/specs/features/$ARGUMENTS/` 폴더를 생성한다
3. 템플릿을 복사하여 `.claude/specs/features/$ARGUMENTS/spec.md` 를 생성한다
   - `[기능명]` placeholder를 실제 기능명($ARGUMENTS)으로 치환
4. 아래 메시지를 출력하고 대기한다:

```
✅ spec.md 생성 완료
📁 위치: .claude/specs/features/$ARGUMENTS/spec.md

spec.md 를 작성한 후 '확인' 을 입력하세요.
```

5. '확인' 입력 후 `step2-plan.md` 를 읽고 절차를 따른다.
