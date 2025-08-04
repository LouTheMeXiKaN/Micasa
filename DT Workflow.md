### **(B) Human \+ AI Workflow: The Founder & Claude Code**

This workflow is optimized for a non-coder founder (Human) collaborating with the Claude Code CLI agent (AI). It positions the founder as the **Context Engineer and Architect**, leveraging the principle of "CLAUDE.md Supremacy."

#### **1\. The Foundation: Context Engineering (The `CLAUDE.md` Strategy)**

Your primary job is to program the AI's behavior and constraints using `CLAUDE.md` files. This is how you maintain control over the architecture.

**a. The Project Constitution (`<project_root>/CLAUDE.md`)**

This is the supreme source of truth. It must define the stack and explicitly import all your documentation using the `@` syntax. Place all documentation files in a `docs/` subdirectory.

Markdown  
\# Micasa MVP Project Constitution

\#\# Technology Stack  
\[Define your stack: e.g., Backend: Node.js/Express/Prisma; Web: Next.js; Mobile: Flutter\]

\#\# Core Documentation (AUTHORITATIVE SOURCE OF TRUTH)  
Adhere strictly to these specifications for all tasks. Do not deviate from the defined schemas or flows.

\#\#\# Specifications  
\- API Contract: @docs/DTAPI Contract1.0.md  
\- Database Schema: @docs/DTDatabase Schema1.0.md  
\- Scope of Work (SOW): @docs/sow-v8-updated.md

\#\#\# User Experience & Flows  
\- User Flows: @docs/User Flows.md  
\- Mobile Screen List (SL7): @docs/SL7.md  
\- Web Screen List: @docs/web-screen-list-v2-6-complete.md

\#\# Workflow Rules  
1\. Implement APIs exactly as defined in the API Contract.  
2\. Implement UIs exactly as defined in the Screen Lists (SL7/Web).

\#\# File Boundaries (Negative Constraints)  
DO NOT edit or delete: .env, node\_modules/, dist/.

**b. Scoped Memory (Hierarchical Context)**

Create specialized instructions in subdirectories to maintain focus:

* `backend/CLAUDE.md`: Rules specific to the backend (e.g., "Use Prisma for all database interactions. Ensure robust error handling for all API endpoints.").  
* `mobile/CLAUDE.md`: Rules specific to Flutter (e.g., "Use BLoC for state management. Strictly adhere to the UI/UX defined in SL7.md.").

#### **2\. The AI Team: Subagent Configuration**

Define specialized AI "engineers" in `.claude/agents/` to handle specific domains. This improves performance and focus.

1. **`Planner.md`:** (Read-only access) Analyzes requirements and generates detailed technical implementation plans.  
2. **`BackendEngineer.md`:** Specializes in the backend stack, API implementation, and database logic.  
3. **`FlutterEngineer.md`:** Specializes in building the mobile UI based on `SL7.md`.

#### **3\. The Development Loop: The EPREV Cycle**

Execute the development plan (Part A) task by task using this structured loop: Explore, Plan, Review, Execute, Validate.

**Step 1: Explore (Context Definition \- Human)**

1. **Select Task:** Choose the next granular task (e.g., "Phase 1.1, Task 3: Auth Endpoints").  
2. **Clear Context:** Run `/clear` in the CLI to reset Claude's short-term memory.  
3. **Define the Prompt:** State the task clearly, referencing the documentation and specifying the `Planner` agent.  
   *Example:*  
   "We are starting Phase 1.1, Task 3\. Use the `Planner` subagent to analyze the requirements for the authentication endpoints (`/auth/register`, `/auth/login`). Reference the `DTAPI Contract1.0.md` (Section 1\) and the `Users` table in the DB Schema."

**Step 2: Plan (AI Strategy)**

1. **Demand Extended Thinking:** Instruct the Planner to use maximum reasoning capacity.  
   *Example:*  
   "`ultrathink` and generate a detailed, step-by-step implementation plan, including file changes, security considerations (hashing, JWT), and validation."

**Step 3: Review (Human Oversight \- CRITICAL)**

1. **Analyze:** Review the AI's plan meticulously. Does it align with the documentation? Is it logical and safe?  
2. **Course Correction:** If flawed, provide feedback: "Your plan missed the requirement for password hashing using bcrypt. Revise the plan."  
3. **Do not proceed until the plan is perfect.**

**Step 4: Execute (Agentic Coding \- AI)**

1. **Delegate Execution:** Approve the plan and delegate to the appropriate engineer agent. *Example:* "The plan is approved. Use the `BackendEngineer` subagent to execute this plan."  
2. **Efficiency Tip:** To speed this up, launch Claude Code with `--allowedTools "Edit,Write,Bash(npm install)"` or, if you trust the plan completely, `--dangerously-skip-permissions`.

**Step 5: Validate (QA and Debugging \- Human \+ AI)**

1. **AI Testing:** "Use the `BackendEngineer` to write and run unit tests for the new endpoints."  
2. **Manual QA:** The founder manually tests the feature (e.g., using Postman for the API).  
3. **Debugging:** If bugs are found, paste the error logs into Claude: "The login failed. Here are the logs: \[LOGS\]. Diagnose and fix this."  
4. **Commit:** Once validated, commit the code.

