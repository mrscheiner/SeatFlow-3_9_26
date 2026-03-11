import SwiftUI

struct EventsView: View {
	@Environment(DataStore.self) private var store
	@State private var showAddEvent = false
	@State private var editingEvent: StandaloneEvent?

	private var events: [StandaloneEvent] {
		store.appEvents.sorted { $0.date > $1.date }
	}

	private var totalPaid: Double {
		events.reduce(0) { $0 + $1.pricePaid }
	}

	private var totalSold: Double {
		events.compactMap(\.priceSold).reduce(0, +)
	}

	private var profitLoss: Double {
		totalSold - totalPaid
	}

	private var pendingCount: Int {
		events.filter { $0.status == .pending }.count
	}

	private var totalTicketsSold: Int {
		events.filter { $0.status == .sold }.reduce(0) { $0 + $1.seatCount }
	}

	private var theme: TeamTheme { store.currentTheme }

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				eventsHeader

				if !events.isEmpty {
					summaryHeader
				}

				if events.isEmpty {
					Spacer()
					VStack(spacing: 16) {
						Image(systemName: "ticket")
							.font(.system(size: 44))
							.foregroundStyle(.tertiary)
						Text("No Events Added")
							.font(.title3.weight(.semibold))
						Text("Create your first event to track concerts, special events, and more.")
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.center)
						Button("Add Event") { showAddEvent = true }
							.buttonStyle(.borderedProminent)
							.tint(theme.primary)
					}
					.padding(40)
					Spacer()
				} else {
					ScrollView {
						LazyVStack(spacing: 12) {
							ForEach(events) { event in
								EventCardView(
									event: event,
									onEdit: { editingEvent = event },
									onDelete: { store.deleteEvent(event.id) }
								)
							}
						}
						.padding(.horizontal, 16)
						.padding(.vertical, 12)

						BottomLogoView()
					}
				}
			}
			.background(Color(.systemGroupedBackground))
			.navigationBarTitleDisplayMode(.inline)
			.toolbarColorScheme(.dark, for: .navigationBar)
			.toolbarBackground(theme.primary, for: .navigationBar)
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Events")
						.font(.headline)
						.foregroundStyle(.white)
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						showAddEvent = true
					} label: {
						Image(systemName: "plus")
							.foregroundStyle(.white)
					}
				}
			}
			.sheet(isPresented: $showAddEvent) {
				AddEventView()
			}
			.sheet(item: $editingEvent) { event in
				AddEventView(editingEvent: event)
			}
		}
	}

	private var eventsHeader: some View {
		VStack(alignment: .leading, spacing: 6) {
			HStack(spacing: 10) {
				Image(systemName: "ticket.fill")
					.font(.title3)
					.foregroundStyle(.white)
				VStack(alignment: .leading, spacing: 2) {
					Text("Standalone Events")
						.font(.headline)
						.foregroundStyle(.white)
					Text("\(events.count) Events • All Passes")
						.font(.caption)
						.foregroundStyle(.white.opacity(0.9))
				}
				Spacer()
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(
			LinearGradient(
				colors: [theme.primary, theme.secondary.opacity(0.6)],
				startPoint: .leading,
				endPoint: .trailing
			)
		)
	}

	private var summaryHeader: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
				EventSummaryPill(title: "Paid", value: totalPaid.formatted(.currency(code: "USD").precision(.fractionLength(0))), color: .blue)
				EventSummaryPill(title: "Revenue", value: totalSold.formatted(.currency(code: "USD").precision(.fractionLength(0))), color: .green)
				EventSummaryPill(title: "P/L", value: profitLoss.formatted(.currency(code: "USD").precision(.fractionLength(0))), color: profitLoss >= 0 ? .green : .red)
				EventSummaryPill(title: "Tickets Sold", value: "\(totalTicketsSold)", color: theme.primary)
				EventSummaryPill(title: "Pending", value: "\(pendingCount)", color: .orange)
			}
			.padding(.vertical, 12)
		}
		.contentMargins(.horizontal, 16)
	}
}

struct EventSummaryPill: View {
	let title: String
	let value: String
	let color: Color

	var body: some View {
		VStack(spacing: 4) {
			Text(value)
				.font(.subheadline.weight(.bold))
				.foregroundStyle(color)
			Text(title)
				.font(.caption2)
				.foregroundStyle(.secondary)
		}
		.frame(width: 70)
		.padding(.vertical, 6)
		.background(Color(.secondarySystemGroupedBackground))
		.clipShape(.rect(cornerRadius: 12))
	}
}

struct EventCardView: View {
	let event: StandaloneEvent
	let onEdit: () -> Void
	let onDelete: () -> Void

	@State private var showDeleteConfirm = false

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(event.eventName)
						.font(.body.weight(.semibold))
						.lineLimit(3)
					if !event.venue.isEmpty {
						Text(event.venue)
							.font(.caption)
							.foregroundStyle(.secondary)
							.lineLimit(2)
					}
				}
				Spacer()
				EventStatusBadge(status: event.status)
			}

			HStack(spacing: 16) {
				Label(event.date.formatted(.dateTime.month(.abbreviated).day().year()), systemImage: "calendar")
					.font(.caption)
					.foregroundStyle(.secondary)

				if !event.section.isEmpty {
					Text("Sec \(event.section)")
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				if event.seatCount > 0 {
					Text("\(event.seatCount) tickets")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}

			if !event.notes.isEmpty {
				Text(event.notes)
					.font(.caption)
					.foregroundStyle(.secondary)
					.lineLimit(2)
			}

			HStack {
				HStack(spacing: 12) {
					VStack(alignment: .leading) {
						Text("Paid")
							.font(.caption2)
							.foregroundStyle(.secondary)
						Text(event.pricePaid, format: .currency(code: "USD"))
							.font(.subheadline.weight(.medium))
					}
					if let sold = event.priceSold {
						VStack(alignment: .leading) {
							Text("Sold")
								.font(.caption2)
								.foregroundStyle(.secondary)
							Text(sold, format: .currency(code: "USD"))
								.font(.subheadline.weight(.medium))
								.foregroundStyle(.green)
						}
					}
					if let pl = event.profitLoss {
						VStack(alignment: .leading) {
							Text("P/L")
								.font(.caption2)
								.foregroundStyle(.secondary)
							Text(pl, format: .currency(code: "USD"))
								.font(.subheadline.weight(.medium))
								.foregroundStyle(pl >= 0 ? .green : .red)
						}
					}
				}

				Spacer()

				HStack(spacing: 12) {
					Button {
						onEdit()
					} label: {
						Image(systemName: "pencil.circle.fill")
							.font(.title3)
							.foregroundStyle(.blue)
					}
					.buttonStyle(.plain)

					Button {
						showDeleteConfirm = true
					} label: {
						Image(systemName: "trash.circle.fill")
							.font(.title3)
							.foregroundStyle(.red.opacity(0.7))
					}
					.buttonStyle(.plain)
				}
			}
		}
		.padding(14)
		.background(Color(.secondarySystemGroupedBackground))
		.clipShape(.rect(cornerRadius: 14))
		.shadow(color: .black.opacity(0.06), radius: 4, y: 2)
		.alert("Delete Event?", isPresented: $showDeleteConfirm) {
			Button("Delete", role: .destructive) { onDelete() }
			Button("Cancel", role: .cancel) { }
		} message: {
			Text("Are you sure you want to delete \"\(event.eventName)\"?")
		}
	}
}

struct EventStatusBadge: View {
	let status: EventStatus

	var body: some View {
		Text(status.rawValue)
			.font(.caption2.weight(.semibold))
			.padding(.horizontal, 8)
			.padding(.vertical, 3)
			.background(status == .sold ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
			.foregroundStyle(status == .sold ? .green : .orange)
			.clipShape(Capsule())
	}
}
