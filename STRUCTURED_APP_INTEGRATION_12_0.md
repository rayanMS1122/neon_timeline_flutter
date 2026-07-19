# Structured app integration 12.0

The app keeps its task model, Cubit/Bloc, repository, database, navigation and
task sheets. Adapt values with `TimelineEntryAdapter<T>` and pass callbacks that
dispatch app mutations.

Use `dataRevision` when the list identity is stable but task data changes. The
active drag snapshots its source entry so unrelated stream updates do not
replace the feedback card. The host still decides whether a changed dragged
record should be rejected, rebased or retried.

Persistence states are visual only:
`idle`, `optimistic`, `saving`, `queuedOffline`, `rollingBack` and `failed`.
They never write data themselves.

