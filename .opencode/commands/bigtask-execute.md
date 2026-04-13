---
description: Execute a specific subtask by ID
---

# Bigtask Execute Command

## Parameter Validation

IF $ARGUMENTS is empty OR $ARGUMENTS does not contain "/":
OUTPUT "Error: Invalid format. Please provide both project name and task ID."
OUTPUT "Usage: /bigtask-execute <project-name>/<task-id>"
OUTPUT "Example: /bigtask-execute project-a/task-1"
STOP

## Execution

## Clarification Guidelines

During task execution, if you encounter any of the following, ASK THE USER for clarification:

- Task requirements are unclear or ambiguous
- Missing input files or dependencies not satisfied
- Conflicting instructions between task description and actual code
- Need clarification on expected output format or structure
- Encounter technical issues or blockers
- Unclear about coding standards or conventions to follow

When asking, be specific about what you need clarified and provide options when possible.

---

Execute a specific subtask based on the provided task ID and project name.

The format is: `/bigtask-execute project-name/task-id` (e.g., `/bigtask-execute project-a/task-1`)

1. First, read the `tasks/$1/task_plan.md` file to understand all tasks (where $1 is the project name)
2. Find the task with ID: $2 (e.g., "task-1", "task-2")
3. Check for any input files that this task depends on (from previous task outputs in `tasks/$1/outputs/`)
4. Execute the task and create output files in `tasks/$1/outputs/`

The task plan format is:

- **ID**: unique identifier
- **Description**: what the task does
- **Dependencies**: array of task IDs that must complete first
- **Input**: what files this task needs as input
- **Output**: what files this task produces

After execution, create a state file `tasks/$1/$2-state.json` (e.g., `tasks/project-a/task-1-state.json`) with:

- taskId
- status (completed/failed)
- outputFiles (array of files created)
- timestamp

Report the execution status and any files created.
