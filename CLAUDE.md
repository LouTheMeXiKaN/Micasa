# Micasa MVP Project Constitution

## Technology Stack
- Backend: Node.js with Express and Prisma ORM
- Web Frontend: Next.js with React
- Database: PostgreSQL

## Core Documentation (AUTHORITATIVE SOURCE OF TRUTH)
Adhere strictly to these specifications for all tasks. Do not deviate from the defined schemas or flows. Your primary function is to implement the features detailed in these documents precisely.

### Specifications
- Scope of Work (SOW): @docs/sow-v8-updated.md
- API Contract: @docs/API Contract 1.4.md
- Database Schema: @docs/DTDatabase Schema1.0.md
- Design System: @docs/micasa-design-system.md

### User Experience & Flows
- Mobile Screen List (SL7): @docs/SL7.md
- Web Screen List: @docs/web-screen-list-v2-6-complete.md

## Workflow Rules
1.  Implement backend APIs exactly as defined in the API Contract.
2.  Implement web UIs exactly as defined in the Web Screen List and guided by the Design System.
3.  All database changes must conform to the Database Schema using Prisma migrations.
4.  You are an expert software engineer. When a plan is approved, execute it efficiently.

## File Boundaries (Negative Constraints)
DO NOT edit, modify, or delete the following files or directories:
- .env
- .git/
- .github/
- node_modules/
- CLAUDE.md