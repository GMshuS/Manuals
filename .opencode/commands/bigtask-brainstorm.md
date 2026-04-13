---
description: Task brainstorming phase - explore requirements, solutions, and tech choices before bigtask-plan
subtask: true
---

# Bigtask Brainstorm Command

## Parameter Validation

IF $ARGUMENTS is empty:
OUTPUT "Error: Missing required arguments."
OUTPUT "Usage: /bigtask-brainstorm <project-name> <theme>"
OUTPUT "Example: /bigtask-brainstorm project-a user authentication system"
STOP

IF $ARGUMENTS does not contain " " (no space between project name and theme):
OUTPUT "Error: Missing theme description."
OUTPUT "Usage: /bigtask-brainstorm <project-name> <theme>"
OUTPUT "Example: /bigtask-brainstorm project-a user authentication system"
STOP

SET $PROJECT_NAME = first word of $ARGUMENTS
SET $THEME = $ARGUMENTS after first space

## Execution

## Brainstorming Guidelines

When doing brainstorming exploration, follow these principles:

1. **Requirement Exploration**: Clarify and elaborate the user's needs
   - Ask "what" questions to understand goals
   - Identify key features and functionalities
   - Consider user scenarios and use cases

2. **Solution Ideation**: Generate multiple approaches
   - Consider different architectural patterns
   - Explore various implementation strategies
   - No idea is too wild at this stage

3. **Technology Evaluation**: Assess tech options
   - Trade-offs between different tools/frameworks
   - Consider team skills and learning curve
   - Long-term maintenance implications

4. **Risk Identification**: Surface potential challenges
   - Technical risks and mitigation strategies
   - Unknown unknowns to be explored later
   - Questions that need further investigation

## Example Brainstorm Areas

- **Scope**: What should be included? What should be excluded?
- **Architecture**: Monolithic vs microservices, SPA vs MPA, etc.
- **Data**: Database choices, data modeling, caching strategies
- **APIs**: REST vs GraphQL, versioning, authentication
- **Frontend**: Framework choices, UI component strategies
- **DevOps**: Deployment, CI/CD, monitoring
- **Security**: Authentication, authorization, data protection

---

Explore the following topic and generate comprehensive brainstorming notes:

**Project Name**: $PROJECT_NAME

**Theme**: $THEME

First, check existing brainstoriming files in `tasks/$PROJECT_NAME/` if they exist to avoid duplication.

Create a `tasks/$PROJECT_NAME/brainstorm.md` file with the following structure:

```markdown
# Brainstorm: $PROJECT_NAME

## Theme

[Topic being brainstormed]

## Requirements Exploration

### Key Questions
- [Question 1]
- [Question 2]
- ...

### User Scenarios
- [Scenario 1]
- [Scenario 2]
- ...

## Solution Options

### Option 1: [Name]
- **Description**: [What it is]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Best For**: [Use cases]

### Option 2: [Name]
- [Same structure]

[Continue with more options...]

## Technology Stack

### Recommended Stack
- **Frontend**: [Option]
- **Backend**: [Option]
- **Database**: [Option]
- **Hosting**: [Option]
- **Other Tools**: [List]

### Alternative Stacks
- [Alternative 1]
- [Alternative 2]

## Risks and Open Questions

### High Priority
- [Risk/Question 1]
- [Risk/Question 2]

### Medium Priority
- [Risk/Question 3]

### To Investigate Later
- [Items to explore in detail during task planning]

## Next Steps

After brainstorming, proceed to `/bigtask-plan` to create the task plan based on the explored direction.

Use this brainstorming output as input context for the task planning phase.
```

Output the brainstorming notes and explain the reasoning behind each exploration area.