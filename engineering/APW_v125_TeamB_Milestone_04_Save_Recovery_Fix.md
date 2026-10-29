# Team B — Candidate 02: save recovery journal validation

## Confirmed issue
Startup journal recovery accepted a `before` object containing only a subset of expected save keys (including an empty object). The startup routine could then remove `apw71_journal` and mark recovery successful despite an incomplete rollback.

## Candidate 02 fix
In the `apw71_journal` startup validation, require `Object.keys(j.before).length === APW_SAVE_KEYS.length` and use `APW_SAVE_KEYS.some(...)` to reject any absent key or any value other than `null` or string. Invalid journals remain preserved for manual recovery.

## Verification
- 43 inline JavaScript blocks passed `node --check`.
- One targeted replacement applied; no art or gameplay rules changed.
- Candidate 02 SHA-256: `8eab8e6fb969b7f4e7624ebf770d686d66ade6d67a9aed824761b9eaffc89c52`.
- Browser, forced storage failure and actual recovery tests remain **unverified**.

## Team A handover
Candidate 02 ZIP is available in the Team B chat; do not treat this markdown as the HTML game. Merge only the strict journal-validation change into Team A's latest build after review.
