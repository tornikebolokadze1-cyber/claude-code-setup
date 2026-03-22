# Error Recovery Rules

## When Something Breaks

If an error occurs after Claude makes a change, follow this procedure:

### Step 1: Assess Severity
| Severity | Symptoms | Action |
|----------|----------|--------|
| **Minor** | One feature not working, styling off | Fix silently, inform user what happened |
| **Medium** | Page not loading, form broken | Stop, explain in plain language, fix with permission |
| **Critical** | App won't start, blank screen, data loss risk | IMMEDIATELY restore last checkpoint, then explain |

### Step 2: Communicate Clearly

Use this template when reporting errors to non-technical users:

```
Something went wrong: [one plain-language sentence]

What happened: [simple explanation without jargon]
What I am doing about it: [the fix in plain terms]
Your data is: [SAFE / AT RISK -- if at risk, explain what]
```

NEVER say:
- "There's a TypeError in the component lifecycle"
- "The build failed with exit code 1"
- "Null reference exception at line 47"

INSTEAD say:
- "The contact form stopped showing up because of a typo I made. Fixing it now."
- "The page went blank because a file I edited had a mistake. I am restoring the previous version."
- "The save feature is broken because the connection settings got mixed up. Let me put them back."

### Step 3: Fix Procedure

1. **If it is a simple typo or small mistake**: Fix it immediately, verify it works, tell the user
2. **If the fix is unclear**: Restore the last working checkpoint FIRST, then investigate
3. **If multiple things broke**: Do NOT try to fix them all at once. Restore checkpoint. Start over with a smaller change.
4. **If you cannot fix it after 2 attempts**: Stop. Tell the user honestly. Suggest they run `/rewind` or say "go back to when it was working."

### Step 4: Post-Recovery

After any error recovery:
1. Create a new checkpoint of the restored/fixed state
2. Summarize what went wrong in one sentence
3. Explain what you will do differently this time
4. Proceed more cautiously (smaller changes, more verification)

## Auto-Diagnosis Triggers

When the user says any of these, enter diagnosis mode:
- "Something broke"
- "It's not working"
- "The page is blank/white"
- "I see an error"
- "It looks wrong"
- "That's not what I wanted"

### Diagnosis Procedure
1. Check the most recent changes Claude made
2. Run the app/site and check for errors
3. Compare current state to the last working checkpoint
4. Present findings in plain language
5. Offer: "Should I fix it or go back to the last save?"

## The Two-Strike Rule

If Claude's fix attempt fails twice:
- STOP trying the same approach
- Restore to the last working checkpoint
- Tell the user: "My approach is not working. I have restored your project to when it was working. Let me try a completely different way, or you can tell me more about what you need."

## Preventing Cascading Failures

- NEVER make a second change to fix a broken first change without checkpointing
- NEVER modify additional files to "work around" an error
- NEVER suppress, hide, or comment out errors -- fix the root cause
- If fixing one thing breaks another, restore and rethink the entire approach
