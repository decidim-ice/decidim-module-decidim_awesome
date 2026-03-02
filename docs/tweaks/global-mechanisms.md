# Global mechanisms

This page documents cross-cutting behavior that applies across multiple tweak families.

## Restrict scope for tweaks (transversal)

This is a transversal mechanism used by many features, not only governance-related ones.
It controls where a tweak applies:

- Global
- Participatory space type
- Participatory space
- Component
- Individual component instance

### How to use it

- Define a global default first.
- Narrow behavior only where needed.
- Prefer scoped rollout for risky changes, then promote to global once validated.

### Where it applies

Commonly reused by:

- Editor/content tweaks (1.x)
- Proposal/participation tweaks (2.x)
- UI/theming/navigation tweaks (4.x)
- Forms/surveys/verifications tweaks (5.x)
- Components/integrations tweaks (6.x)

See detailed behavior per tweak in each category page.
