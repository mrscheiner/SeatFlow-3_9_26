import SwiftUI

struct RewindView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showRestoreAlert = false
    @State private var selectedBackup: Backup?

    private var backups: [Backup] {
        store.activePass?.backups.sorted { $0.timestamp > $1.timestamp } ?? []
    }

    var body: some View {
        NavigationStack {
            Group {
                if backups.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 44))
                            .foregroundStyle(.tertiary)
                        Text("No Backups")
                            .font(.title3.weight(.semibold))
                        Text("Backups are created automatically when you add or edit sales, events, or passes.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(backups) { backup in
                            Button {
                                selectedBackup = backup
                                showRestoreAlert = true
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(backup.label)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.primary)
                                            .lineLimit(3)
                                        Spacer()
                                        Image(systemName: "arrow.uturn.backward.circle")
                                            .foregroundStyle(.blue)
                                    }

                                    HStack(spacing: 16) {
                                        Label(TimezoneHelper.formatEST(backup.timestamp), systemImage: "clock")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Label("\(backup.salesCount) sales", systemImage: "ticket")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Label("\(backup.eventsCount) events", systemImage: "star")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Rewind")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Restore Backup?", isPresented: $showRestoreAlert) {
                Button("Restore", role: .destructive) {
                    guard let backup = selectedBackup else { return }
                    store.restoreBackup(backup)
                    let rewindMsg = restoreMessageFromLabel(backup.label)
                    store.showToastMessage(rewindMsg)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if let backup = selectedBackup {
                    let currentSales = store.activePass?.sales.count ?? 0
                    let currentEvents = store.appEvents.count
                    let salesDiff = currentSales - backup.salesCount
                    let eventsDiff = currentEvents - backup.eventsCount
                    let salesMsg = salesDiff > 0 ? "Remove \(salesDiff) sale(s)" : salesDiff < 0 ? "Add \(abs(salesDiff)) sale(s)" : ""
                    let eventsMsg = eventsDiff > 0 ? "Remove \(eventsDiff) event(s)" : eventsDiff < 0 ? "Add \(abs(eventsDiff)) event(s)" : ""
                    let changesStr = [salesMsg, eventsMsg].filter { !$0.isEmpty }.joined(separator: ", ")
                    let changes = changesStr.isEmpty ? "Data values may differ" : changesStr
                    Text("\(backup.label)\n\n\(changes)\nRestores to: \(backup.salesCount) sales, \(backup.eventsCount) events\n\(TimezoneHelper.formatEST(backup.timestamp))\n\nThis cannot be undone.")
                } else {
                    Text("Select a backup to restore.")
                }
            }
        }
    }

    private func restoreMessageFromLabel(_ label: String) -> String {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("Before adding") {
            let detail = String(trimmed.dropFirst("Before adding".count)).trimmingCharacters(in: .whitespaces)
            return "Rewound: removed \(detail)"
        } else if trimmed.hasPrefix("Before updating") {
            let detail = String(trimmed.dropFirst("Before updating".count)).trimmingCharacters(in: .whitespaces)
            return "Rewound: reverted \(detail)"
        } else if trimmed.hasPrefix("Before deleting") {
            let detail = String(trimmed.dropFirst("Before deleting".count)).trimmingCharacters(in: .whitespaces)
            return "Rewound: restored \(detail)"
        } else {
            return "Restored to previous state"
        }
    }
}
