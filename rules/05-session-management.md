# Session Management Rules

## Starting a Session

At the beginning of every session, Claude should:
1. Briefly acknowledge the project context (do not recite the entire CLAUDE.md)
2. If resuming work, summarize where things left off in 1-2 sentences
3. Ask what the user wants to work on today

## Context Hygiene

### When to Suggest /clear
- The user switches to a completely different topic
- The conversation has been going for 20+ back-and-forth messages
- Claude notices it is starting to repeat itself or get confused
- The user says "let's start fresh" or "new topic"

How to suggest it:
```
We have been working on a lot of things in this conversation. To make sure I stay sharp,
I recommend starting fresh. Type /clear and then tell me what you need next.
Your files and changes are all saved -- nothing will be lost.
```

### When to Suggest /compact
- The session is getting long but the user is still on the same task
- Claude needs to keep working but context is filling up

How to suggest it:
```
This conversation is getting long. I can compress the earlier parts to free up space
while keeping the important details. Want me to do that? (Just say "yes" or type /compact)
```

## Ending a Session

Before a session ends or when the user seems done:
1. Create a checkpoint if there are unsaved changes
2. Summarize what was accomplished in plain language
3. Note any unfinished items
4. Suggest what to do next time

Template:
```
Here is what we accomplished today:
- [Item 1]
- [Item 2]

Still to do:
- [Remaining item, if any]

Everything is saved. Next time, you can pick up by saying "[suggested prompt]".
```

## Handling Long Tasks

For tasks that take many steps:
1. Give progress updates every 3-5 actions: "Step 2 of 5 done. Working on step 3 now."
2. Checkpoint at meaningful milestones
3. If the task is taking longer than expected, explain why and give a revised estimate

## The "Where Was I?" Response

When a user returns and asks "where did we leave off?" or similar:
1. Check the most recent checkpoint messages
2. Check auto-memory for session notes
3. Summarize the last session's work and current project state
4. Suggest the next step

## Parallel Session Awareness

If the user mentions work done in another session or by another tool:
- Do NOT assume you know what happened
- Ask: "I was not part of that session. Can you tell me what was changed, or should I look at the files to figure it out?"
- Read the relevant files before making assumptions
