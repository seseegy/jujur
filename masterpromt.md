ROLE AND MISSION

Act as a senior Flutter engineer, mobile product architect, UX/UI designer, database engineer, accessibility specialist, and software quality engineer.

Your task is to design and build a complete, production-quality Android application using Dart and Flutter.

The application is called "Jujur" (working title).

Jujur is a private, offline-first daily activity, habit, self-reflection, and Islamic worship tracking application.

Its core philosophy is:

"Help users see their daily lives honestly, without shame, unnecessary pressure, manipulation, or dependence on the internet."

This is not a generic habit tracker, a gamified productivity application, an AI-powered life coach, or a decorative dashboard.

Build a real application with functional features, persistent local storage, reliable data migration, export and backup capabilities, polished UI/UX, and a maintainable architecture.

Do not stop after generating a prototype, mockup, design system, or collection of static screens.

Implement the actual application.

---

1. NON-NEGOTIABLE PRODUCT PRINCIPLES

Every implementation decision must follow these principles.

1.1 Offline-first

The application must work fully without an internet connection.

The following features must work offline:

- Daily activity tracking.
- Habit creation and tracking.
- Prayer tracking.
- Worship tracking.
- Daily reflections.
- Historical activity browsing.
- Statistics and summaries.
- Search and filtering.
- Data export.
- Backup creation.
- Backup restoration.
- Settings.
- Custom categories.
- Reminders, subject to operating-system permissions and scheduling limitations.

Do not require:

- User accounts.
- Cloud authentication.
- A backend server.
- An API key.
- Remote configuration.
- AI services.
- Internet access for normal application functionality.

Do not implement fake offline support where the interface loads but the data operations fail without internet.

If optional network-dependent functionality is ever introduced, it must be isolated from the core application.

1.2 Honest tracking

The application must never assume that an activity was completed merely because the day ended.

Every tracked item must have a meaningful state model.

Examples:

- Completed.
- Not completed.
- Partially completed, where applicable.
- Skipped or excused, where applicable.
- Not recorded.

These states must be represented explicitly in the data model.

An empty record must not automatically be interpreted as a failure.

A user must be able to distinguish between:

- An activity they did not complete.
- An activity they have not recorded yet.
- An activity that does not apply to them.

Never silently convert missing information into a negative result.

1.3 Privacy by default

All personal records must remain on the device unless the user explicitly exports or shares them.

Do not introduce analytics SDKs, advertising SDKs, behavioral tracking, cloud synchronization, or third-party data collection.

Do not transmit private records to external services.

Do not add an AI chatbot or AI-generated motivational messages.

Do not include unnecessary network permissions.

The application should require only the Android permissions genuinely needed by implemented features.

1.4 Mature and intentional UX

The application must feel like a thoughtfully designed native mobile product.

Avoid:

- Generic AI-generated dashboard layouts.
- Excessive rounded cards.
- Random gradients.
- Excessive drop shadows.
- Glassmorphism without a clear purpose.
- Emoji used as the primary icon system.
- Excessive decorative illustrations.
- Artificially inflated statistics.
- Fake productivity scores.
- Confetti for ordinary actions.
- Endless streak notifications.
- Empty charts with fabricated data.
- Excessive onboarding.
- Unnecessary animations.
- Repetitive motivational quotes.

Every visual element must serve a real purpose.

Prioritize hierarchy, readability, spacing, predictable interactions, restrained colors, and excellent typography.

---

2. TECHNOLOGY STACK

Use the following technical foundation.

2.1 Required technologies

- Language: Dart.
- Framework: Flutter.
- Primary target: Android.
- Architecture: Feature-oriented, layered architecture with clear separation of concerns.
- State management: Riverpod.
- Local database: SQLite through a maintained Flutter SQLite solution, preferably Drift.
- Local preferences: SharedPreferences or an equivalent lightweight local settings store.
- Date and time handling: Use appropriate Dart date/time utilities and a maintained timezone solution when necessary.
- Serialization: Explicit, versioned JSON serialization.
- Testing: Flutter unit tests, widget tests, and integration tests.
- Icons: Material Symbols or another consistent, maintained icon library.

Choose compatible, stable package versions based on the existing Flutter SDK and project constraints.

Do not invent package names or APIs.

Check package compatibility before integrating dependencies.

Prefer a small, reliable dependency set over a large collection of unnecessary packages.

Use native Android capabilities when required for reliable local notifications, file access, backup handling, or other platform-specific functionality.

2.2 Database requirements

Use a local relational database for structured application records.

The database must support:

- Foreign-key relationships.
- Database transactions.
- Indexes for frequently queried fields.
- Schema versioning.
- Safe database migrations.
- Unique constraints where appropriate.
- Atomic multi-record operations.
- Efficient historical queries.

Enable foreign-key enforcement.

Use transactions when creating or restoring related records.

Do not store the entire application database as one large JSON object inside SharedPreferences.

Do not use temporary in-memory collections as the permanent source of truth.

2.3 Architecture

Organize the codebase by feature and responsibility.

A possible structure:

lib/
main.dart
app/
app.dart
bootstrap.dart
router.dart
theme/
app_theme.dart
app_colors.dart
app_typography.dart
app_spacing.dart
config/
app_config.dart
core/
database/
app_database.dart
migrations/
errors/
extensions/
formatters/
notifications/
backup/
export/
accessibility/
widgets/
features/
dashboard/
data/
domain/
presentation/
daily_log/
data/
domain/
presentation/
prayers/
data/
domain/
presentation/
habits/
data/
domain/
presentation/
worship/
data/
domain/
presentation/
reflections/
data/
domain/
presentation/
history/
data/
domain/
presentation/
statistics/
data/
domain/
presentation/
search/
data/
domain/
presentation/
settings/
data/
domain/
presentation/
backup/
data/
domain/
presentation/

This is an architectural guide, not a requirement to create empty folders.

Only introduce abstractions that improve maintainability.

Keep widgets focused on presentation.

Keep business rules out of widgets.

Use repositories for data access.

Use domain models or well-defined data models.

Keep database queries out of presentation components.

Avoid giant files, deeply nested widgets, circular dependencies, and unnecessary abstraction layers.

---

3. PRODUCT EXPERIENCE

The application should feel calm, private, reflective, and easy to use.

The primary interaction should take only a few seconds.

Opening the application should immediately help users answer three questions:

1. What have I done today?
2. What still needs to be recorded?
3. How did I spend my day?

Do not turn these questions into a complicated analytics dashboard.

3.1 Main navigation

Use a bottom navigation bar with four primary destinations:

1. Today.
2. History.
3. Insights.
4. Settings.

Prayer tracking and worship tracking should be accessible directly from Today.

Habits and daily activities should also be accessible from Today.

Avoid creating a separate bottom navigation item for every feature.

Use secondary screens, tabs, or detail pages when appropriate.

Preserve navigation state where reasonable.

Use clear page titles and predictable back navigation.

3.2 First-launch experience

Create a short onboarding flow.

The onboarding should explain:

- The purpose of the application.
- That records are stored locally.
- That an account is not required.
- That incomplete activities are not automatically failures.
- That backup is the user's responsibility unless they configure an external backup mechanism themselves.

Allow the user to skip optional personalization.

Do not require:

- Registration.
- Email.
- Phone number.
- Cloud account creation.
- Notification permission during the first frame of application launch.

Request notification permission only when the user enables a reminder or reaches a context where the permission is necessary.

Provide a simple optional setup for:

- Preferred language.
- Theme.
- Week start day.
- Prayer tracking preferences.
- Habit preferences.

Do not block the main application behind a lengthy onboarding process.

---

4. TODAY SCREEN

The Today screen is the heart of the application.

It must be useful, calm, and fast.

4.1 Header

Display:

- Current date.
- Day of the week.
- A short, restrained heading.
- A button to navigate to another date.
- A button to access the daily reflection, if appropriate.

Use the device's local date and locale.

Handle date boundaries correctly.

Do not assume the user is always in the same timezone.

4.2 Daily overview

Display a compact overview of today's records.

Examples:

- Activities recorded.
- Habits completed.
- Prayer records.
- Reflection status.

Only display metrics supported by real data.

Never use a percentage as if it represents overall personal worth.

Do not display a single productivity score that combines prayer, personal habits, work, and reflections into one moral judgment.

If progress indicators are shown, label exactly what they measure.

Distinguish between:

- Completed.
- Remaining.
- Not yet recorded.
- Not applicable.

A user who has not recorded anything should see a useful empty state, not a dashboard full of zeros.

4.3 Daily activity list

Allow users to record activities such as:

- Studying.
- Working.
- Reading.
- Exercising.
- Spending time with family.
- Household tasks.
- Personal projects.
- Rest.
- Other custom activities.

Each activity may support:

- Title.
- Optional description.
- Category.
- Date.
- Optional start time.
- Optional end time.
- Optional duration.
- Optional notes.
- Completion status.
- Optional tags.

Allow users to create, edit, duplicate, and delete activity entries.

Validate start and end times.

Support activities without exact times.

Do not force users to account for every minute of the day.

Do not treat rest as wasted time.

If an activity spans midnight, handle it explicitly rather than silently creating invalid durations.

Provide a fast-entry interaction for simple records.

Users must be able to add a basic activity without navigating through many forms.

4.4 Daily checklist

Allow users to define recurring daily activities.

Examples:

- Read for 15 minutes.
- Study a subject.
- Exercise.
- Limit social media.
- Sleep before a chosen time.

Users must be able to:

- Mark an item complete.
- Mark it incomplete.
- Undo a change.
- Add a note.
- Edit the item.
- Disable it without deleting historical records.

The checklist must distinguish between today's instance and the underlying habit definition.

Changes to a recurring habit must not unexpectedly rewrite historical records.

---

5. ISLAMIC PRAYER TRACKING

Prayer tracking is a first-class feature.

It must be implemented respectfully and with appropriate Islamic terminology.

The application must support the five daily obligatory prayers:

1. Subuh / Fajr.
2. Zuhur / Dhuhr.
3. Asar / Asr.
4. Magrib / Maghrib.
5. Isya / Isha.

Use the Indonesian prayer names by default.

Allow language-aware naming when additional languages are implemented.

5.1 Daily prayer records

Each prayer record should include:

- Prayer identifier.
- Prayer date.
- Prayer status.
- Optional actual completion time.
- Optional note.
- Optional jamaah indicator.
- Optional tracking metadata.

Use a clearly defined status model.

At minimum, support:

- Belum dicatat.
- Sudah dilaksanakan.
- Terlewat.
- Tidak berlaku or an appropriate exceptional state when explicitly relevant.

The application must not automatically assume that a prayer was performed.

The user must record it.

Do not automatically mark a prayer as missed merely because its scheduled time has passed.

Do not automatically mark a prayer as completed based on a notification interaction unless the user explicitly confirms completion.

Make it easy to correct an accidental tap.

Support editing historical prayer records.

The default behavior should be honest, respectful, and nonjudgmental.

5.2 Optional prayer times

Prayer time calculation is an optional enhancement.

If implemented, prayer times must be calculated locally or imported through an explicit user action.

Support configurable:

- Calculation method.
- Location.
- Timezone.
- Relevant calculation adjustments.
- Local reminder preferences.

Do not hardcode prayer times for a particular city.

Do not silently use an arbitrary calculation method.

Clearly distinguish:

- Calculated prayer times.
- Manually configured prayer times.
- Actual recorded completion times.

Do not require internet access to record prayers.

If accurate local prayer-time calculation requires location information, explain this and allow manual configuration.

Location access must be optional.

5.3 Prayer statistics

Provide historical summaries such as:

- Number of recorded completed prayers.
- Number of missed prayers explicitly recorded by the user.
- Number of prayers not yet recorded.
- Weekly and monthly summaries.

Never count an unrecorded prayer as a missed prayer.

Do not generate guilt-inducing language.

Do not describe a user's religious commitment using an invented score.

Avoid competitive leaderboards, public rankings, or social comparison.

5.4 Prayer reminders

Allow optional local notifications for prayer-related reminders.

Users must be able to:

- Enable or disable reminders.
- Choose which prayers trigger reminders.
- Configure reminder timing.
- Change notification behavior.

Handle Android notification permission requirements.

Do not assume notifications always fire at an exact time.

Account for operating-system restrictions and timezone changes.

The core prayer tracker must remain fully functional if notifications are disabled.

---

6. OTHER WORSHIP TRACKING

Create a separate but related worship tracking feature.

Allow users to enable or disable optional tracking items such as:

- Tilawah Al-Qur'an.
- Murajaah.
- Dzikir pagi.
- Dzikir petang.
- Sedekah.
- Puasa sunnah.
- Shalat sunnah.
- Tahajud.
- Dhuha.
- Other user-defined worship activities.

These are configurable tracking options, not mandatory daily requirements.

Do not assume that every worship activity must be performed every day.

Each item should support appropriate tracking types.

Examples:

Boolean:

- Completed.
- Not completed.
- Not recorded.

Quantity:

- Number of pages read.
- Number of verses read.
- Number of repetitions.

Duration:

- Minutes spent reading.
- Minutes spent studying.

Free-form:

- Personal reflection.
- Optional note.

Let the user choose which activities appear on the Today screen.

Keep the default interface uncluttered.

Do not force users to track every religious practice.

Historical worship records must remain available even when a tracking item is later disabled.

---

7. HABIT MANAGEMENT

Implement a complete recurring habit system.

Each habit should support:

- Name.
- Description.
- Category.
- Icon or simple visual identifier.
- Active or archived state.
- Start date.
- Optional end date.
- Recurrence pattern.
- Selected weekdays.
- Optional target value.
- Optional target unit.
- Optional reminder.
- Display order.
- Optional color chosen from a restrained palette.

Support:

- Every day.
- Selected weekdays.
- Specific recurring schedules where practical.
- One-time tasks where appropriate.

A habit must have a distinct record for each applicable date.

Editing a habit must not silently overwrite historical completion records.

Deleting a habit must require an appropriate confirmation and preserve or explicitly handle its historical data.

Prefer archiving for ordinary removal.

7.1 Habit states

Support:

- Not recorded.
- Completed.
- Partially completed.
- Skipped, when appropriate.

Not every habit needs every state.

Use a suitable state model for each tracking type.

A quantity-based habit should allow recording the actual quantity instead of only a binary completion value.

For example:

- Target: 20 pages.
- Actual: 12 pages.

Display progress without labeling the user a failure.

7.2 Streaks

Streaks are optional.

If implemented:

- Explain how they are calculated.
- Do not count unscheduled days as failures.
- Do not count missing records as completed.
- Allow users to disable streak displays.
- Avoid making streaks the main measure of success.

Do not introduce streak freezes, artificial scarcity, or manipulative engagement mechanics.

---

8. DAILY REFLECTION

Create a private daily reflection feature.

The purpose is to help users understand their day, not to produce artificial motivational content.

Suggested optional prompts:

- Apa yang berjalan baik hari ini?
- Apa yang belum berjalan sesuai rencana?
- Apa yang saya pelajari hari ini?
- Apa yang ingin saya perbaiki besok?
- Hal apa yang saya syukuri hari ini?

These prompts must be editable or configurable.

Users should be able to write freely without answering every prompt.

Support:

- Autosave with a clear persistence strategy.
- Manual save where appropriate.
- Editing previous reflections.
- Deleting a reflection.
- Empty reflections without forced completion.
- Searching reflections.
- Exporting reflection content.

Avoid saving every keystroke directly to the database without a deliberate strategy.

Use debouncing, explicit save operations, or another reliable mechanism.

Prevent data loss when:

- The user leaves the screen.
- The app moves to the background.
- The operating system terminates the process.
- The device rotates.
- The application is reopened.

Display a subtle saved indicator when appropriate.

Reflection content must remain local and private.

---

9. HISTORY AND CALENDAR

Implement a usable historical browsing experience.

Support:

- Calendar navigation.
- Daily detail views.
- Previous and next day navigation.
- Weekly summaries.
- Monthly summaries.
- Historical activity lists.
- Historical prayer records.
- Historical habit records.
- Historical reflections.

Do not place excessive information inside calendar cells.

Use restrained indicators to communicate whether a date contains recorded information.

Do not mark a day as unsuccessful solely because it contains incomplete or missing records.

Users must be able to open any historical date and edit the relevant records.

Handle:

- Month boundaries.
- Year boundaries.
- Leap years.
- Local timezone changes.
- Daylight-saving changes where applicable.
- Historical records with missing optional fields.

Do not generate records for every possible date unless the underlying model genuinely requires them.

---

10. INSIGHTS AND STATISTICS

Create a practical insights screen.

It should answer useful questions without becoming a surveillance-style dashboard.

Possible summaries:

- Activities completed during the last seven days.
- Most frequently recorded activity categories.
- Habit completion over selected periods.
- Prayer tracking history.
- Worship activity totals.
- Total recorded reading duration.
- Average duration of activities when meaningful.
- Days with saved reflections.
- Changes compared with the previous period.

All statistics must be calculated from actual persisted records.

Provide:

- Date-range selection.
- Clear metric definitions.
- Appropriate empty states.
- Accessible chart labels.
- Useful textual summaries.
- A way to navigate from a metric to the relevant records.

Do not:

- Invent data.
- Inflate numbers.
- Treat missing records as zero completion unless the metric explicitly requires it and explains the behavior.
- Claim causation from simple correlations.
- Present religious observance as a competitive score.
- Create charts solely to fill screen space.

Use charts only when they improve understanding.

Prefer a clear text summary or a compact table when it communicates the information better.

---

11. SEARCH AND FILTERING

Implement local search across relevant records.

Depending on the selected search scope, allow users to search:

- Activity titles.
- Activity descriptions.
- Notes.
- Habit names.
- Reflection content.
- Custom categories.

Support filters such as:

- Date range.
- Category.
- Completion status.
- Activity type.

Search must not require internet access.

Use indexed database queries when appropriate.

Avoid loading the entire database into memory for large searches.

Do not expose private reflection text in notifications.

---

12. DATABASE AND DATA MODEL

Design the database before implementing the UI.

Use an appropriate normalized relational schema.

At minimum, evaluate the following entities.

12.1 App settings

Fields may include:

- Setting key.
- Setting value.
- Updated timestamp.

Store application settings separately from high-volume tracking records.

12.2 Activity categories

Fields:

- ID.
- Name.
- Optional description.
- Optional icon identifier.
- Optional color identifier.
- Created timestamp.
- Updated timestamp.
- Archived state.

12.3 Activity entries

Fields:

- ID.
- Title.
- Optional description.
- Category ID.
- Start timestamp.
- Optional end timestamp.
- Optional duration.
- Date key.
- Completion status.
- Optional notes.
- Created timestamp.
- Updated timestamp.

Validate that end timestamps do not precede start timestamps.

Allow activities without start or end times when appropriate.

12.4 Habit definitions

Fields:

- ID.
- Name.
- Description.
- Tracking type.
- Recurrence configuration.
- Target value.
- Target unit.
- Start date.
- Optional end date.
- Active state.
- Display order.
- Created timestamp.
- Updated timestamp.

12.5 Habit records

Fields:

- ID.
- Habit ID.
- Local date key.
- Status.
- Actual value.
- Optional notes.
- Created timestamp.
- Updated timestamp.

Add a suitable uniqueness constraint to prevent duplicate records for the same habit and date.

12.6 Prayer records

Fields:

- ID.
- Prayer identifier.
- Prayer date.
- Status.
- Optional completion timestamp.
- Optional jamaah status.
- Optional note.
- Created timestamp.
- Updated timestamp.

Use a unique constraint for the appropriate combination of prayer identifier and prayer date.

Make sure the data model can distinguish the local prayer date from a UTC timestamp.

12.7 Worship definitions and records

Use separate definition and record structures.

Support boolean, numeric, duration-based, and other appropriate tracking types.

Validate values according to the selected tracking type.

12.8 Daily reflections

Fields:

- ID.
- Local date key.
- Reflection content or structured answers.
- Created timestamp.
- Updated timestamp.

Choose a clear model for multiple prompts or multiple reflection entries per day.

Do not accidentally overwrite a reflection when the user creates another entry.

12.9 Data integrity

Use stable identifiers.

Use UTC timestamps for audit metadata where appropriate.

Use local date keys for date-based records.

Do not rely on timestamps alone to identify a local calendar day.

Ensure the system behaves correctly when the user changes the device timezone.

Use database transactions for multi-step operations.

Define deletion behavior explicitly.

Do not allow orphaned records.

Preserve historical records when definitions are archived.

Document important data-model decisions.

The schema above is a starting point, not an excuse to implement an inflexible model.

Refine it when needed, but preserve the intended behavior.

---

13. DATA PERSISTENCE AND RECOVERY

This feature is critical.

Data persistence must be implemented and tested, not merely described in the UI.

13.1 Persistence requirements

All user-created records must survive:

- Closing and reopening the application.
- Process termination.
- Device restart.
- Navigation between screens.
- Rebuilding the UI.
- Application upgrades with compatible schema migrations.

Do not keep authoritative application data only in provider state or widget state.

The database is the source of truth.

13.2 Database migrations

Use explicit database schema versions.

Implement safe migrations when tables or columns change.

Do not delete the database to resolve a migration error.

Never silently reset user data after a failed migration.

Provide a safe failure path and preserve the original database.

Test upgrades from previous schema versions where applicable.

13.3 Database error handling

Handle:

- Database initialization failures.
- Disk-full errors.
- Invalid records.
- Constraint violations.
- Failed transactions.
- Database migration errors.
- Corrupted backup files.

Show clear, understandable error messages.

Do not expose stack traces to normal users.

Do not pretend that a failed write succeeded.

---

14. BACKUP AND RESTORE

Implement a complete, usable backup and restore system.

A backup is not the same as a plain CSV export.

14.1 Full backup

Create a versioned backup format.

Prefer a ZIP archive containing:

- A machine-readable JSON manifest.
- All supported user data.
- Categories and custom definitions.
- Activity records.
- Habit definitions and records.
- Prayer records.
- Worship definitions and records.
- Reflections.
- Relevant user settings.
- Schema and backup format versions.
- Creation timestamp.
- Optional integrity checksum.

Use a documented backup format.

Do not include transient UI state.

Do not include caches.

Do not include unnecessary operating-system data.

Do not claim that a backup contains data that was never exported.

14.2 Backup creation

Allow users to:

- Create a backup manually.
- Choose a destination through the Android file picker or Storage Access Framework.
- Share the resulting backup file.
- See success or failure.
- See the backup creation time.
- Understand what the backup includes.

Ensure the backup is complete before reporting success.

Use a temporary file and an atomic finalization strategy when practical.

14.3 Backup restoration

Allow users to select a previously created backup.

Validate the file before modifying the database.

Check:

- File format.
- Supported backup version.
- Required files.
- JSON structure.
- Data types.
- Record identifiers.
- Relationships.
- Integrity checksum, if present.

If validation fails, leave existing data unchanged.

Restoration must not partially overwrite the database.

Use a transaction or a carefully designed staged restore process.

Provide an explicit restore strategy:

1. Replace existing application data.
2. Merge records, if reliable merge semantics have been implemented.

For replacement, show a clear confirmation and explain the consequences.

For merge, define conflict handling using stable IDs and updated timestamps.

Never silently overwrite conflicting user data.

If restoration fails, preserve the original data.

14.4 Backup encryption

Evaluate optional encrypted backups.

If implemented:

- Use a maintained cryptographic library.
- Use a secure key derivation method appropriate for password-based encryption.
- Use authenticated encryption.
- Generate unique salts and nonces as required.
- Never store the backup password in plain text.
- Never invent a custom encryption algorithm.
- Explain that losing the password may make the backup unrecoverable.

An unencrypted backup must be clearly identified as containing readable personal data.

Encryption must not become a prerequisite for using the application.

14.5 Backup integrity

Add automated tests for:

- Valid backup restoration.
- Invalid archive handling.
- Missing manifest.
- Unsupported versions.
- Corrupted JSON.
- Duplicate identifiers.
- Failed database writes.
- Interrupted restoration.
- Empty database restoration.
- Restoration over an existing database.

Do not claim to support restoration scenarios that have not been tested.

---

15. DATA EXPORT

Provide separate export options for portability and analysis.

At minimum, support:

15.1 JSON export

Include structured records with stable identifiers.

Use a documented format.

Include schema version information.

15.2 CSV export

Provide CSV export for appropriate record types.

Consider separate files for:

- Activities.
- Habits.
- Habit records.
- Prayer records.
- Worship records.
- Reflections, where suitable.

Use UTF-8 encoding.

Correctly escape:

- Commas.
- Quotes.
- Newlines.
- Unicode characters.

Preserve Indonesian text.

Handle spreadsheet formula injection when exporting user-controlled text to spreadsheet-oriented formats.

Do not silently modify the underlying stored text.

15.3 Export options

Allow users to select:

- A date range.
- Record categories.
- Record types.
- Whether notes are included, where appropriate.

Provide an export preview or summary.

Clearly communicate which records are being exported.

Use the system file picker or sharing interface.

Do not require internet access.

---

16. UI/UX DESIGN SYSTEM

Create a coherent, production-quality design system before building the main screens.

The visual direction should be:

"Quiet, editorial, warm, precise, modern, and understated."

The interface should feel intentionally designed by a thoughtful product designer, not assembled from generic AI-generated components.

16.1 Visual identity

Use:

- A restrained color palette.
- Clear typographic hierarchy.
- Consistent spacing.
- Strong alignment.
- Subtle separators.
- Purposeful negative space.
- Consistent iconography.
- Carefully designed empty states.
- Readable forms.
- Clear interaction feedback.

Possible starting palette:

Light theme:

- Background: warm off-white.
- Surface: white or a very subtle warm neutral.
- Primary: deep forest green.
- Primary text: dark charcoal.
- Secondary text: muted gray.
- Border: light neutral gray.
- Success: restrained green.
- Warning: muted amber.
- Error: accessible muted red.

Dark theme:

- Background: deep neutral charcoal.
- Surface: slightly elevated dark neutral.
- Primary: accessible muted green.
- Text: warm off-white.
- Borders: subtle dark gray.

These are starting directions, not mandatory hardcoded colors.

Evaluate contrast and visual balance.

Avoid making the entire application green.

Use accent colors sparingly.

Do not use gradients as a substitute for visual hierarchy.

16.2 Typography

Use a readable font system.

Use bundled fonts only when licensing and package size are appropriate.

Choose clear typography for:

- Page titles.
- Section headings.
- Body text.
- Secondary labels.
- Numeric values.
- Date and time information.

Do not use oversized typography everywhere.

Do not make every label bold.

Maintain a consistent scale.

Support dynamic text scaling as far as practical.

16.3 Spacing and layout

Create a spacing scale, for example:

- 4 dp.
- 8 dp.
- 12 dp.
- 16 dp.
- 20 dp.
- 24 dp.
- 32 dp.

Use it consistently.

Use a small set of component radii rather than rounding every element excessively.

Do not wrap every section inside a separate card.

Use cards when grouping, elevation, or interaction semantics justify them.

Use lists, dividers, section headings, and open layouts where appropriate.

16.4 Component design

Build reusable components for:

- Buttons.
- Input fields.
- Date selectors.
- Status selectors.
- Empty states.
- Section headers.
- Confirmation dialogs.
- Bottom sheets.
- Snackbars.
- Loading indicators.
- Error messages.
- Progress indicators.
- Activity rows.
- Prayer rows.
- Habit rows.

Reusable components must not become generic abstractions that make simple layouts harder to understand.

16.5 Interaction design

Every interactive element must have:

- A clear purpose.
- A visible interactive state.
- Appropriate touch targets.
- Predictable behavior.
- Accessible semantics.
- Useful feedback.

Use undo actions for reversible operations where appropriate.

Use confirmation dialogs for destructive operations.

Avoid confirmation dialogs for every trivial action.

Respect the system's back navigation.

Avoid accidental double submissions.

Disable or guard actions while critical operations are running.

16.6 Accessibility

Support:

- Screen readers.
- Sufficient contrast.
- Scalable text.
- Meaningful accessibility labels.
- Appropriate touch target sizes.
- Keyboard navigation where applicable.
- Non-color indicators for statuses.
- Clear focus states.

Do not communicate status through color alone.

16.7 Motion

Animations must be subtle and purposeful.

Prefer brief transitions that explain state changes.

Avoid decorative animation loops.

Respect reduced-motion preferences when practical.

Never delay important interactions for unnecessary animation.

---

17. SCREEN-BY-SCREEN REQUIREMENTS

Implement the following screens.

17.1 Today screen

Include:

- Current date.
- Previous and next date navigation.
- Compact daily overview.
- Prayer tracker.
- User-selected worship activities.
- Habit checklist.
- Activity log.
- Daily reflection shortcut.
- Quick-add action.

The layout should prioritize the most frequently used tasks.

Do not display every possible feature at once.

Allow sections to be collapsed where useful.

Preserve appropriate section preferences locally.

17.2 Add activity screen

Include:

- Activity title.
- Optional description.
- Category.
- Date.
- Optional start time.
- Optional end time.
- Optional duration.
- Optional note.
- Completion state.

Validate inputs.

Keep the common entry flow short.

Advanced fields may be progressively disclosed.

17.3 Habit management screen

Include:

- Active habits.
- Archived habits.
- Create habit.
- Edit habit.
- Recurrence configuration.
- Tracking type.
- Optional target.
- Optional reminder.
- Display order.

Clearly explain when changes affect future records only.

17.4 Prayer detail screen

Include:

- The five obligatory prayers.
- Prayer date.
- Individual prayer states.
- Optional completion time.
- Optional jamaah tracking.
- Optional notes.
- Historical navigation.

Make corrections easy.

Do not infer a prayer's completion status from its scheduled time.

17.5 Daily reflection screen

Include:

- Reflection date.
- Optional prompts.
- A comfortable text editor.
- Save status.
- Historical navigation.
- Clear deletion behavior.

Avoid turning the reflection screen into a form with too many mandatory questions.

17.6 History screen

Include:

- Calendar.
- Date navigation.
- Compact activity summaries.
- Daily details.
- Historical editing.
- Filters.

Use restrained indicators.

17.7 Insights screen

Include:

- Date-range selection.
- Useful summary metrics.
- Prayer history.
- Habit history.
- Activity distribution.
- Reflection history.

Provide textual explanations for chart results.

Do not invent metrics to fill space.

17.8 Settings screen

Include:

- Theme: light, dark, system.
- Language.
- Week start day.
- Reminder settings.
- Prayer tracking preferences.
- Worship tracking preferences.
- Default categories.
- Data export.
- Backup.
- Restore.
- Database or data information where appropriate.
- About.
- Privacy explanation.
- Version information.

All settings must be persisted.

17.9 Empty states

Design useful empty states for:

- No activities.
- No habits.
- No reflections.
- No historical records.
- No insights.
- No backups.
- No search results.

Each empty state should explain the situation and provide a relevant next action.

Do not use meaningless placeholder text.

Do not create fake records to make the interface look populated.

---

18. DATE, TIME, AND CALENDAR CORRECTNESS

Date handling is a major source of bugs and must be designed deliberately.

Distinguish between:

- A calendar date.
- A local date and time.
- A UTC timestamp.
- A recurring schedule.

Use local date keys for date-based records.

Use timestamps for audit metadata and actual event times where appropriate.

Do not assume every day has exactly the same number of seconds.

Handle timezone changes.

Handle daylight-saving transitions where relevant.

Ensure that the same activity does not appear under the wrong date because of UTC conversion.

Historical date navigation must remain stable.

Prayer records must be associated with the intended local prayer date.

Recurring habits must use their configured calendar recurrence, not naive duration arithmetic.

Write unit tests for date boundaries and recurrence rules.

---

19. LOCAL NOTIFICATIONS

Notifications are optional enhancements.

Implement them only with appropriate permission handling.

Requirements:

- Users can enable or disable reminders.
- Reminder schedules are stored persistently.
- Reminder settings can be changed.
- Disabled reminders are canceled.
- Rescheduling does not create duplicate notifications.
- Timezone changes are handled where practical.
- Notifications do not expose private reflection text.
- Notifications do not automatically mark activities complete.

Do not promise exact delivery times when Android scheduling restrictions prevent that guarantee.

The application must remain useful when all notifications are disabled.

---

20. PERFORMANCE AND RELIABILITY

The application should remain responsive with substantial historical data.

Requirements:

- Avoid unnecessary widget rebuilds.
- Use stable keys for dynamic lists where appropriate.
- Use database indexes for common queries.
- Paginate large histories when needed.
- Avoid loading all reflections into memory for ordinary list views.
- Keep database writes off expensive synchronous UI operations.
- Handle loading, success, empty, and error states.
- Avoid unnecessary package dependencies.
- Avoid memory leaks and unclosed resources.
- Use appropriate lifecycle management.
- Keep build methods focused on rendering.

Do not sacrifice correctness for premature optimization.

---

21. ERROR HANDLING

Handle failures deliberately.

Examples:

- Database unavailable.
- Failed database write.
- Invalid input.
- Invalid date range.
- File picker cancellation.
- Insufficient storage.
- Backup file corruption.
- Unsupported backup version.
- Restore conflict.
- Notification permission denied.
- Notification scheduling failure.
- Failed export.
- Missing optional configuration.

The UI must distinguish between cancellation and failure.

Do not show a success message after an unsuccessful operation.

Do not silently discard data.

Provide actionable error messages in Indonesian.

Use internal logging only where useful, and do not log private reflection content or other sensitive personal records.

---

22. TESTING REQUIREMENTS

Create a meaningful automated test suite.

22.1 Unit tests

Test:

- Habit recurrence.
- Completion status transitions.
- Prayer record handling.
- Date calculations.
- Weekly summaries.
- Monthly summaries.
- Statistics calculations.
- Input validation.
- Backup serialization.
- Backup validation.
- Export formatting.
- Merge conflict rules.
- Database migration logic.

22.2 Database tests

Verify:

- Records persist after database reopening.
- Unique constraints work.
- Foreign keys work.
- Transactions roll back correctly.
- Historical records survive habit archival.
- Updates do not create duplicate daily records.
- Migrations preserve existing data.
- Failed restoration does not corrupt existing records.

22.3 Widget tests

Test:

- Main navigation.
- Today screen.
- Prayer status updates.
- Habit completion.
- Activity creation.
- Activity editing.
- Reflection saving.
- Empty states.
- Validation messages.
- Theme changes.
- Accessible labels for critical controls.

22.4 Integration tests

Test complete workflows:

1. Launch the application.
2. Create a habit.
3. Record today's completion.
4. Close and reopen the application.
5. Verify the record still exists.
6. Edit a historical prayer record.
7. Write a daily reflection.
8. Create a full backup.
9. Clear test data in a controlled test environment.
10. Restore the backup.
11. Verify the restored records.
12. Export selected records to CSV.
13. Verify the exported content.

Also test offline operation.

Simulate network unavailability and verify that core features continue to work.

Do not claim a test passed unless it was actually executed.

---

23. ANDROID BUILD REQUIREMENTS

Create a working Android project.

Requirements:

- Correct Android package configuration.
- App name and launcher configuration.
- Appropriate Android SDK compatibility.
- Required permissions only.
- Correct notification configuration if notifications are implemented.
- File picker integration for backup and export.
- Release build configuration.
- App icon and splash screen.
- Proper handling of Android back navigation.
- Correct handling of app lifecycle changes.

Keep application identifiers configurable.

Do not invent signing credentials.

Do not commit secrets.

Do not hardcode passwords or encryption keys.

Provide instructions for creating a signed release build.

Do not claim that the application is production-ready merely because the debug build launches.

---

24. PROJECT QUALITY RULES

Follow these rules throughout implementation.

1. Never replace a requested working feature with a static mockup.
2. Never use fake persistence.
3. Never populate production screens with fabricated user records.
4. Never swallow exceptions silently.
5. Never hardcode personal records.
6. Never leave a primary action connected to an empty callback.
7. Never create buttons that only look functional.
8. Never delete user data to resolve an implementation problem.
9. Never silently overwrite existing records during restoration.
10. Never interpret missing data as completed activity.
11. Never interpret missing prayer records as missed prayers.
12. Never make internet connectivity mandatory for core features.
13. Never add unnecessary AI features.
14. Never add analytics or advertising.
15. Never compromise data integrity for visual polish.
16. Never create unnecessary abstractions solely to make the architecture look sophisticated.
17. Never generate an enormous monolithic Dart file.
18. Never claim that a feature is complete when its critical workflows are unimplemented.
19. Never use deprecated APIs when a suitable maintained alternative is available.
20. Never ignore build errors or test failures.

When a requirement cannot be implemented reliably, explain the limitation and provide a concrete alternative.

---

25. IMPLEMENTATION WORKFLOW

Do not attempt to generate the entire application in one uncontrolled code-generation pass.

Work in explicit phases.

Phase 1: Inspect and plan

Inspect the existing project and available environment.

If no project exists, initialize a proper Flutter project.

Determine:

- Flutter and Dart versions.
- Existing project structure.
- Android build configuration.
- Available dependencies.
- Existing code that must be preserved.

Produce:

1. Product requirements summary.
2. Architecture proposal.
3. Database schema.
4. Navigation map.
5. Design system.
6. Dependency plan.
7. Implementation plan.
8. Risk register.

Keep the plan concise enough to be actionable.

Do not stop at planning unless the environment genuinely prevents implementation.

Phase 2: Establish the foundation

Implement:

- Project configuration.
- Application bootstrap.
- Theme system.
- Routing.
- Database initialization.
- Schema migrations.
- Core error handling.
- State management.
- Shared UI components.

Run the application and tests.

Resolve foundational errors before adding features.

Phase 3: Build the core daily workflow

Implement:

- Today screen.
- Activity creation and editing.
- Daily records.
- Habit definitions.
- Habit tracking.
- Persistent local storage.

Test the full workflow.

Phase 4: Implement worship features

Implement:

- Five daily prayers.
- Prayer history.
- Optional worship activities.
- Worship history.
- Relevant settings.

Verify that missing records remain distinct from explicitly missed prayers.

Phase 5: Implement reflection and history

Implement:

- Daily reflection.
- Autosave or a reliable save strategy.
- Historical editing.
- Calendar navigation.
- Search and filtering.

Test persistence after application termination.

Phase 6: Implement export and backup

Implement:

- JSON export.
- CSV export.
- Full backup.
- Backup validation.
- Restore.
- Merge or replacement semantics.
- Error handling.

Write tests before declaring backup and restore complete.

Phase 7: Implement insights

Build statistics from actual database records.

Validate calculations against known test datasets.

Ensure empty datasets produce honest empty states.

Phase 8: Refine the interface

Review:

- Visual hierarchy.
- Spacing.
- Typography.
- Touch targets.
- Accessibility.
- Dark mode.
- Loading states.
- Empty states.
- Error states.
- Small-screen behavior.
- Large-text behavior.

Remove unnecessary decoration.

Improve any screen that feels generic, crowded, or visually inconsistent.

Phase 9: Validate the application

Run the appropriate commands, including:

flutter pub get
flutter analyze
flutter test

Also run Android build commands appropriate to the project, such as:

flutter build apk --debug

Add integration tests and release-build validation where the environment permits.

Fix issues rather than merely listing them.

If a command cannot run because the environment lacks the required SDK or platform tools, report the actual limitation.

Phase 10: Final delivery

Provide:

- Implemented features.
- Project structure.
- Important architectural decisions.
- Database and migration information.
- Backup format documentation.
- Tests executed and their actual results.
- Known limitations.
- Instructions for running the app.
- Instructions for building the APK.
- APK location if an APK was successfully generated.
- Instructions for signing a release build.
- Recommendations for future improvements.

Do not claim to have generated an APK unless the file actually exists.

Do not claim all tests passed unless their results confirm it.

---

26. DEFINITION OF DONE

The application is not complete until the following conditions are satisfied.

[ ] The Flutter application builds successfully in the available environment.

[ ] The main navigation works.

[ ] Activities can be created, edited, and deleted.

[ ] Habits can be created, tracked, edited, and archived.

[ ] Historical records remain intact when definitions are changed.

[ ] Five daily prayers can be recorded independently.

[ ] Missing prayer records are not treated as missed prayers.

[ ] Optional worship activities work.

[ ] Daily reflections persist correctly.

[ ] Historical records can be browsed and edited.

[ ] Statistics are based on real records.

[ ] Search and filtering work offline.

[ ] User settings persist across application restarts.

[ ] Data survives application termination and reopening.

[ ] Database migrations preserve existing data.

[ ] JSON export works.

[ ] CSV export works for supported record types.

[ ] Full backup creation works.

[ ] Backup validation works.

[ ] Restore does not corrupt existing data when validation fails.

[ ] Destructive restoration requires explicit confirmation.

[ ] Backup and restore have automated tests.

[ ] Light and dark themes work.

[ ] Empty, loading, and error states are implemented.

[ ] Accessibility has been reviewed.

[ ] No core functionality depends on internet access.

[ ] No primary action is a nonfunctional placeholder.

[ ] Flutter analysis has been run and relevant issues resolved.

[ ] Tests have been executed and their results documented.

[ ] Android build results have been verified.

---

27. FINAL EXECUTION INSTRUCTIONS

Begin by inspecting the current environment and project.

Then implement the application incrementally, following the phases above.

Make reasonable engineering decisions without repeatedly asking me to approve ordinary implementation details.

If a major product decision is ambiguous, choose the simplest option that preserves user privacy, data integrity, usability, and future maintainability. Document the decision.

Prioritize the following order:

1. Correct data persistence.
2. Data integrity and recovery.
3. Core daily tracking.
4. Prayer and worship tracking.
5. Usability.
6. Visual quality.
7. Insights and optional enhancements.

Do not sacrifice a reliable backup system to implement decorative charts.

Do not sacrifice a clear user experience to add unnecessary features.

Do not add features merely because they are common in other habit-tracking applications.

Build the smallest complete version that satisfies the core requirements, then expand it systematically.

Your goal is not to produce the largest possible codebase.

Your goal is to deliver a reliable, beautiful, private, maintainable Flutter application that users can trust with their daily records.

Start with Phase 1, inspect the environment, and continue through implementation as far as the available tools allow.
