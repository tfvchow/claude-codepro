---
name: Testing Debugging
description: Advanced debugging patterns and examples for complex multi-component systems. Use this skill when debugging multi-layered systems (API, service, database, external services), when encountering intermittent or flaky failures, when 2+ fix attempts have failed, or when you need diagnostic instrumentation patterns. Complements the systematic-debugging standard rule with practical examples and code snippets.
---

# Testing Debugging - Advanced Patterns

This skill provides examples and patterns that complement the `systematic-debugging.md` standard rule. The rule covers the 4-phase process; this skill provides practical implementation guidance.

## When to use this skill

- When debugging multi-layered systems (frontend, API, business logic, database, caching, message queues)
- When encountering intermittent or flaky test failures
- When you've already tried 2+ fixes without success
- When you need diagnostic instrumentation examples
- When debugging CI/CD pipeline failures across multiple stages
- When integrating with external APIs that return unexpected responses

## Multi-Component Debugging Pattern

**WHEN system has multiple components (CI → build → signing, API → service → database):**

**BEFORE proposing fixes, add diagnostic instrumentation:**

```
For EACH component boundary:
  - Log what data enters component
  - Log what data exits component
  - Verify environment/config propagation
  - Check state at each layer

Run once to gather evidence showing WHERE it breaks
THEN analyze evidence to identify failing component
THEN investigate that specific component
```

**Example (multi-layer system):**

```bash
# Layer 1: Workflow/CI
echo "=== Secrets available in workflow: ==="
echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

# Layer 2: Build script
echo "=== Env vars in build script: ==="
env | grep IDENTITY || echo "IDENTITY not in environment"

# Layer 3: Signing script
echo "=== Keychain state: ==="
security list-keychains
security find-identity -v

# Layer 4: Actual signing
codesign --sign "$IDENTITY" --verbose=4 "$APP"
```

**This reveals:** Which layer fails (secrets → workflow ✓, workflow → build ✗)

## User Signals You're Doing It Wrong

Watch for these redirections from your human partner:

| Signal | What it means |
|--------|---------------|
| "Is that not happening?" | You assumed without verifying |
| "Will it show us...?" | You should have added evidence gathering |
| "Stop guessing" | You're proposing fixes without understanding |
| "Ultrathink this" | Question fundamentals, not just symptoms |
| "We're stuck?" (frustrated) | Your approach isn't working |

**When you see these:** STOP. Return to Phase 1 (see systematic-debugging rule).

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## When Investigation Reveals "No Root Cause"

If systematic investigation reveals issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

## Real-World Impact

From debugging sessions:
- Systematic approach: 15-30 minutes to fix
- Random fixes approach: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: Near zero vs common
