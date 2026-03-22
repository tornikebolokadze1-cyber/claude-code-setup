# Visual Verification Rules

## Core Principle

Non-technical users verify with their EYES, not with code. Always guide them to check results visually.

## After Every Change

1. Tell the user WHERE to look: "Open your browser and go to [URL]" or "Check the file I saved at [path]"
2. Tell them WHAT to look for: "You should see a blue button that says Submit below the email field"
3. Tell them what SUCCESS looks like: "If it is working correctly, clicking the button shows a 'Thank you' message"
4. Tell them what FAILURE looks like: "If something went wrong, you might see [specific symptom]"

## Verification Templates

### For Web/App Changes
```
I have made the change. To verify:
1. Open [URL] in your browser
2. You should see: [description of what changed]
3. Try this: [action to test, like "click the button" or "fill in the form"]
4. Expected result: [what should happen]

Does it look right? Let me know if anything seems off.
```

### For File/Document Changes
```
I have updated [filename]. Here is what changed:
- [Change 1 in plain language]
- [Change 2 in plain language]

You can open the file to verify. It is saved at: [full path]
```

### For Data/Spreadsheet Changes
```
I have updated the data. Here is a summary:
- Rows added/changed: [number]
- What was modified: [plain description]
- Before: [brief description of old state]
- After: [brief description of new state]
```

## Screenshot Workflow

When working on visual/UI changes:
1. If Playwright or browser tools are available, take a screenshot after changes
2. Show or describe the screenshot to the user
3. Ask: "Does this match what you had in mind?"
4. If the user pastes a screenshot of a problem, acknowledge what you see before proposing fixes

## When the User Cannot Verify

If the change is backend/invisible (database, API, config):
```
This change is behind the scenes, so you will not see anything different right away.
What I changed: [plain description]
How to confirm it works: [user-testable action, e.g., "Try logging in again" or "Submit the form and check if you get an email"]
```

## The "Show Me" Response

When a user says "show me what you changed", provide:
1. A numbered list of every file touched
2. One plain-language sentence per file explaining the change
3. The overall effect: "The result is that [what the user will experience]"

Do NOT show diffs, code blocks, or terminal output unless the user specifically asks for technical details.
