# AI_Feature.md

## Method and benefit

- Our app has a local rule based smart helper that suggests an event based on attendance history and preferred interests. This feature allows users to align their interests with a focused event choice, so they don’t have to scroll through the entire list to manually find an event they’d like to attend. No machine learning is used to create the smart helper.

## User decision and success criteria

- As a potential user of the app, you’d likely be asking yourself “Which unplanned event that I have yet to attend should I consider attending next”, to which the app would reply by using its helper to provide an answer.

- You may also ask yourself, “How does the app provide a suggestion appropriately?”

- To answer that question we can look at the content displayed to the user. Event appears with a suggestion label and reasoning message, or no available events to display appears, both of which mark successful operation of the smart helper.

## Inputs

| Input | Source | Purpose |
| --- | --- | --- |
| Event category | events table | Category name |
| Category attendance count | Attendance table joined with events | Counts distinct attended events |
| Preferred interests | SharedPreferences | Select 3 categories |
| Planned status | events  table | Store Boolean as 0 or 1 |
| Attendance status | attendance table | Attendance record existence |
| Event date/time | events table | Break score ties |

## Method and reasoning

The smart helper uses a scoring system to determine the event to display, which looks like this:

Score =

attendance count for its category + 2 if its category matches a preferred interest

Already attended events are excluded from the home catalog database query. Planned events and events with a score of 0 are excluded from the recommendation candidates. The highest scoring event is suggested; if there are multiple events with tied highest scores, the date and time is used to break the tie, with earliest date/time selected.

The reason behind using the attendance count as a determining factor is because attendance history can indicate favorable event types within attendance history. Preferred interests does not need user event history, so it can be used to display suggestions immediately with a simple settings selection.

Planned events don’t add towards the attended event count since intention can not be equated as a completed attendance.

Preferred interests can not stack favorability scores, so if all three dropdowns are set to the same category, that category can only get the “ +2” on their score instead of “+6”.

## Alternatives and baseline

- An alternative to the current system is to have preference only ranking, which displays suggestions by matching selected interests. This would reduce complexity of scoring and Sqlite table joining operations.

- In our context, the baseline is based on attendance only, meaning:

- Baseline score = attendance count for the category

## Case table

| Type | Inputs | Expected behavior | Actual app behavior | Pass/fail |
| --- | --- | --- | --- | --- |
| Normal | Art attended 3 times, Food attended 2 times and preferred | Baseline: Art suggested<br>Current method: Food suggested | Food  event suggested | pass |
| Empty/insufficient | Events in catalog, no attendance history or preferred interest selected | No suggested  event available | No suggested event | Pass |
| Invalid | Unknown category | Category is not used for scoring | Current implementation has static category list | Fail |
| Boundary | Two events with equal high score and different dates | Earlier dated event is suggested | Earlier event is displayed in suggestion area | Pass |
| Counterexample | Sports attended 10 times, Technology attended 0 times and preferred | Baseline: Sports suggested<br>Current method: sports suggested | Sports event is suggested, attendance count outweighs preference score. | Pass |

## Counterexample and decision

- As shown in the table, a counterexample occurs when the user has attended 10 10 sports events and has selected technology as one of their preferred interests. Sports is scored as have 10 points and technology only receives 2, so sports is suggested to the user. This favors event types that are not helpful if the user has recently changed interests in order to attend technology events. An improvement to the scoring could be prioritizing preferred interest picks or progressively reducing the weighted score of events in history if they are older than the 10th most recent event.

## Explanation and user control

- The suggested card explains its selection using the category’s attendance count if greater than 0 and if it matches a preferred interest.

- Marking a suggested event as planned removes it from the suggestion area and the existing catalog list updates with the event card now having a planned marker.

- The existing suggestion card space updates immediately following the previous action due to loadData() being called, and updates with a new card or with “ no events to suggest” message depending on what conditions are met.

- Suggested events can change if user has changed preferred interest in settings before returning to home page.

## No data and invalid feedback

- The app doesn’t distinguish between lack of matching events and insufficient preference data for displaying the “no events to suggest” message.

- The event form prevents required fields from being empty when creating or editing event details

- Similarly, forms don’t accept invalid input and display error messages.

## Offline and restart

- The helper reads events and attendance from Sqlite storage and preferred interests form SharedPreferences.

- All helper operations are performed locally within dart files.
