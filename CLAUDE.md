# Micasa MVP Project Constitution

## Technology Stack
- Backend: Node.js, Express, Prisma, PostgreSQL
- Mobile: Flutter (BLoC for state management)
- Web: Next.js (for future guest experience)

## Core Documentation (AUTHORITATIVE SOURCE OF TRUTH)
Adhere strictly to these specifications for all tasks.

---

### **NEW: Implementation Blueprints**
This section contains detailed, feature-specific implementation plans.

**RULE: When a specific Implementation Blueprint exists for a feature, it is the PRIMARY source of truth and OVERRIDES the general specifications in the SOW or Screen Lists for that feature.**

- **Authentication Flow:** @docs/implementation_plan_revised.md

---

### General Specifications
- API Contract: @docs/API Contract 1.4.md
- Database Schema: @docs/DTDatabase Schema1.0.md
- Scope of Work (SOW): @docs/sow-v8-updated.md

### User Experience & Flows
- Mobile Screen List (SL7): @docs/SL7.md
- Web Screen List: @docs/web-screen-list-v2-6-complete (1).md
- Micasa Design System: @docs/micasa-design-system.md

## Workflow Rules
1. Implement mobile UIs exactly as defined in the screen lists and design system, unless overridden by a specific Implementation Blueprint.
2. Use the BLoC pattern for all state management.
3. All API calls must match the definitions in the API Contract.

## File Boundaries (Negative Constraints)
DO NOT edit or delete: .env, .gitignore, node_modules/, dist/, .dockerignore