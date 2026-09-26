<!--
ADOPT: scope by putting frontmatter ABOVE this comment, listing frontend
code, e.g.
---
paths:
  - "web/**"
  - "src/components/**"
---
Delete this file if the project has no user interface.
-->
# UI conventions

- **Confirm consequential actions.** Destructive, irreversible, or
  wide-reaching actions (deleting records, finalizing, sending to many
  people) get a confirmation dialog stating the impact (e.g. the recipient
  count). Dialogs use `role="dialog"` + `aria-labelledby`, which also
  scopes tests. Trivially reversible actions don't need one.
- Hide destructive controls on finalized records rather than leaving them
  one accidental click away.
- Form state initialized from loaded data re-syncs when that data changes,
  or an edit form reopens showing stale data.
- Guard against out-of-order responses (e.g. a request id, so an older
  response can't overwrite a newer one). Refresh silently when the tab
  regains focus, without clobbering unsaved edits.
- Feature-detect optional browser APIs (e.g. Web Share) per capability;
  omit the control where unsupported rather than showing it disabled.
- Keep page state (pagination, filters) in the URL query string, omitting
  defaults, so a refresh or shared link lands on the same view.
- Design for mobile: copy buttons where selecting text is awkward, and
  navigation that collapses on small screens.
- Every interactive control is reachable and usable by keyboard and has an
  accessible name.
