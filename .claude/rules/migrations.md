<!--
ADOPT: scope by putting frontmatter ABOVE this comment, listing the
migration and schema directories, e.g.
---
paths:
  - "migrations/**"
  - "db/schema*"
---
The core safety rules (data-loss migrations, pre-change backups) are also
in CLAUDE.md, so a missed load here can't skip them.
-->
# Migrations and schema

## Mechanics
- Numbered sequentially, run exactly once, tracked in a migrations table.
- Never edit or delete a migration once shipped. An unused one stays,
  documented as unused.
- Mirror every schema change in the base schema so fresh installs match.
- A one-time data cleanup ships as a migration, so the fix and the cleanup
  deploy together with no manual step to remember.
- Test every migration against realistic synthetic or anonymized data,
  never a copy of production.

## Expand/contract, so rollback stays safe
Rollback swaps the build but leaves the schema, so every migration must
work with both the new build and the rollback target. Migrations are
forward-only; never rely on a down-migration to roll back.
- **Additive** (new table, new nullable or defaulted column, new index):
  ships with the code that uses it.
- **Remove, rename, or retype**, in stages across releases:
  1. Add the new shape.
  2. Code writes both, reads the new.
  3. Backfill.
  4. In a later release, once the rollback target no longer uses the old
     shape, drop it. This step is a data-loss migration: call it out, get
     the explicit OK, and take a verified pre-change backup.
- A migration that can't follow this pattern is flagged when presented and
  treated as destructive.

## Foreign keys and deletes
When adding a table that references another, check every delete path for
the referenced rows and make it clean up (or null out) the new table too,
including tables with two FK columns to the same parent. Add a regression
test that the delete still works with rows in the new table.

## Backward compatibility
For every new column, flag, or state tied to a user or account, state what
value existing rows get and whether that's right. Don't default a column
and assume usage will backfill it.
