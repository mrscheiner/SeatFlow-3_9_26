import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {

    @Environment(DataStore.self) private var store

    @State private var showSetup = false
    @State private var showEditPass = false
    @State private var showRewind = false
    @State private var showDeleteAlert = false
    @State private var deletePassId: String?

    @State private var showExportOptions = false
    @State private var showImportPicker = false
    @State private var showCopiedAlert = false
    @State private var exportedFileURL: URL?
    @State private var showShareSheet = false

    private var theme: TeamTheme { store.currentTheme }

    var body: some View {
        NavigationStack {
            List {

                seasonPassSection

                Section("Data") {

                    Button("Export Data") {
                        showExportOptions = true
                    }

                    Button("Import Data") {
                        showImportPicker = true
                    }

                    Button("Rewind / Restore Backup") {
                        showRewind = true
                    }

                }

            }
            .navigationTitle("Settings")
        }
    }

    private var seasonPassSection: some View {

        Section("Season Passes") {

            ForEach(store.seasonPasses, id: \.id) { pass in

                HStack(spacing: 12) {

                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 2) {

                        Text(pass.teamName)
                            .font(.body.weight(.medium))

                        Text(pass.seasonLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                    }

                    Spacer()

                    if pass.id == store.activePassId {

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)

                    }

                }

            }

        }

    }

}

