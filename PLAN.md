# SPM 4 — Native iOS Season Pass Manager


A native iOS app for sports season ticket holders to track ticket sales, game schedules, events, and financial analytics across NHL, NBA, NFL, MLB, and MLS — rebuilt from scratch in Swift/SwiftUI with dynamic team theming.

---

## **Features**

### Season Pass Management
- Create season passes by choosing a league, team, and adding seat pairs (section, row, seats, cost)
- Switch between multiple season passes from anywhere in the app
- Edit pass details — update season label, add/remove seat pairs
- Delete passes with confirmation

### Home Dashboard
- At-a-glance view of ticket sales grouped by game
- Each game card shows opponent logo/name, date, and individual seat sales
- Total revenue and quick stats visible at the top
- Pull-to-refresh to update data

### Schedule
- Full season schedule with opponent, date, time, and venue
- Filter by game type (All, Preseason, Regular, Playoff)
- Search by opponent name
- Visual indicators for payment status (Paid / Pending) with animated badges
- Resync schedule capability

### Events
- Track standalone events (concerts, special events, etc.)
- Add/edit/delete events with name, venue, location, date, seating, prices, status, and notes
- Financial summary: total paid, total sales, profit/loss, pending vs paid counts

### Analytics
- Season overview: total revenue, seats sold, sold rate
- Monthly revenue bar chart
- Per-seat-pair performance table (section, row, cost, revenue, games sold, balance)
- Season totals: cost, sales to date, net profit/loss

### Settings & Data
- Export data as JSON or CSV
- Import/restore from JSON backups
- Copy data to clipboard
- Add new passes, delete current pass

### Rewind (Backup History)
- View previous backup snapshots sorted by date
- See backup details (label, timestamp, sale/event counts)
- Restore data to a previous point with confirmation

---

## **Design**

- **Dynamic team theming** — colors, gradients, and accents change based on the selected team (e.g. Florida Panthers: navy blue, gold, red)
- Dark, sports-premium aesthetic with team gradient headers
- Cards with subtle shadows and rounded corners on grouped background
- SF Symbols throughout — tickets, calendars, charts, gear icons
- Haptic feedback on key actions (adding sales, switching passes, deleting)
- Spring animations for status badges and card transitions
- Native iOS controls: segmented pickers for filters, swipe-to-delete on lists, confirmation dialogs

---

## **Screens**

1. **Setup Screen** — Guided flow: pick league → pick team → add seat pairs → create pass
2. **Home Tab** — Sales dashboard grouped by game with revenue summary
3. **Schedule Tab** — Scrollable game list with filters, search, and payment status
4. **Analytics Tab** — Charts and tables showing revenue, seat performance, profit/loss
5. **Events Tab** — Event list with add/edit forms and financial summaries
6. **Settings Tab** — Data export/import, pass management, app info
7. **Edit Pass Sheet** — Modify season label and seat pairs
8. **Rewind Sheet** — Browse and restore from backup history
9. **Season Pass Selector** — Quick-switch between passes from a dropdown/sheet

---

## **App Icon**
- Dark navy blue background with a gradient to gold
- White ticket stub icon with a subtle sports field pattern
- Clean, modern, premium feel matching the sports theme
