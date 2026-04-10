---
name: new-feature
description: $ARGUMENTS 기능의 spec 파일을 생성한다.
disable-model-invocation: true
---

# new-feature

$ARGUMENTS 기능의 spec 파일을 생성한다.

## 실행 절차

1. `.claude/templates/spec.template.md` 를 읽는다
2. `.claude/specs/features/$ARGUMENTS/` 폴더를 생성한다
3. 템플릿을 복사하여 `.claude/specs/features/$ARGUMENTS/spec.md` 를 생성한다
4. 생성 완료 후 아래 메시지를 출력한다:

```
✅ spec.md 생성 완료
📁 위치: .claude/specs/features/$ARGUMENTS/spec.md

spec.md 작성 후 /plan-feature $ARGUMENTS 를 실행하세요.
```
