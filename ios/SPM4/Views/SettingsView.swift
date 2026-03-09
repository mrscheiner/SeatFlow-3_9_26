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
            VStack(spacing: 0) {
                settingsHeader

                List {
                    Section("Season Passes") {
                        ForEach(store.seasonPasses) { pass in
                            HStack(spacing: 12) {
                                let logoURL = LeagueData.team(for: pass.teamId)?.logoURL ?? ""
                                if !logoURL.isEmpty, let url = URL(string: logoURL) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable().aspectRatio(contentMode: .fit)
                                        } else {
                                            Circle()
                                                .fill(TeamThemeProvider.theme(for: pass.teamId).primary)
                                                .overlay {
                                                    Text(String(pass.teamName.prefix(2)))
                                                        .font(.caption.bold())
                                                        .foregroundStyle(.white)
                                                }
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                } else {
                                    Circle()
                                        .fill(TeamThemeProvider.theme(for: pass.teamId).primary)
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Text(String(pass.teamName.prefix(2)))
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                }
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

                                Button(role: .destructive) {
                                    deletePassId = pass.id
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.body)
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.switchToPass(pass.id)
                            }
                        }

                        Button {
                            showEditPass = true
                        } label: {
                            Label("Edit Current Pass", systemImage: "pencil")
                        }

                        Button {
                            showSetup = true
                        } label: {
                            Label("Add New Pass", systemImage: "plus.circle")
                        }
                    }

                    Section {
                        Button {
                            showExportOptions = true
                        } label: {
                            Label("Export Sales Data", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            copyJSONToClipboard()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Copy Data to Clipboard", systemImage: "doc.on.doc")
                                Text("Copies your sales data so you can paste it into another app")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Button {
                            showImportPicker = true
                        } label: {
                            Label("Import Sales Data", systemImage: "square.and.arrow.down")
                        }
                    } header: {
                        Text("Data")
                    }

                    Section("Backup") {
                        Button {
                            store.createBackup(label: "Manual Backup")
                            store.showToastMessage("Backup completed successfully")
                        } label: {
                            Label("Create Backup", systemImage: "clock.arrow.circlepath")
                        }

                        Button {
                            showRewind = true
                        } label: {
                            Label("Rewind (Restore)", systemImage: "arrow.uturn.backward")
                        }
                    }

                    Section("About") {
                        HStack(spacing: 12) {
                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Seatfolio")
                                    .font(.body.weight(.semibold))
                                Text("Version 4.0.0")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)

                        HStack {
                            Text("Sales")
                            Spacer()
                            Text("\(store.activePass?.sales.count ?? 0)")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Games")
                            Spacer()
                            Text("\(store.activePass?.games.count ?? 0)")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Events")
                            Spacer()
                            Text("\(store.appEvents.count)")
                                .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fan Disclaimer")
                                .font(.subheadline.weight(.semibold))
                            Text("Seatfolio is created for sports fans. Seatfolio is not affiliated with or endorsed by any sports league, team, or organization.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Privacy") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data Privacy")
                                .font(.subheadline.weight(.semibold))
                            Text("Seatfolio does not collect, store, or transmit any personal user data. All information entered into Seatfolio is stored locally on the user's device.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    Section {
                        BottomLogoView()
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .alert("Are you sure you want to delete this Season Pass?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let id = deletePassId {
                        store.deletePass(id)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete the season pass and all its data.")
            }
            .confirmationDialog("Export As", isPresented: $showExportOptions) {
                Button("Share as JSON") { exportJSON() }
                Button("Share as CSV") { exportCSV() }
                Button("Copy JSON to Clipboard") { copyJSONToClipboard() }
                Button("Copy CSV to Clipboard") { copyCSVToClipboard() }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showSetup) {
                SetupView()
            }
            .sheet(isPresented: $showEditPass) {
                EditPassView()
            }
            .sheet(isPresented: $showRewind) {
                RewindView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportedFileURL {
                    ShareSheetView(url: url)
                }
            }
            .fileImporter(isPresented: $showImportPicker, allowedContentTypes: [.json]) { result in
                handleImport(result)
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Sales data copied to clipboard. You can now paste it into another app.")
            }
        }
    }

    private var settingsHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let pass = store.activePass {
                HStack(spacing: 10) {
                    if let team = LeagueData.team(for: pass.teamId), let url = URL(string: team.logoURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Circle().fill(.white.opacity(0.3))
                            }
                        }
                        .frame(width: 36, height: 36)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pass.teamName)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("\(pass.seasonLabel) Season")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer()
                }
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

    private func copyJSONToClipboard() {
        guard let json = store.exportJSON() else { return }
        UIPasteboard.general.string = json
        store.showToastMessage("Sales data copied to clipboard")
    }

    private func copyCSVToClipboard() {
        guard let csv = store.exportCSV() else { return }
        UIPasteboard.general.string = csv
        store.showToastMessage("CSV data copied to clipboard")
    }

    private func exportJSON() {
        guard let json = store.exportJSON() else { return }
        let fileName = "seatfolio_export_\(Date().formatted(.dateTime.year().month().day())).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? json.write(to: url, atomically: true, encoding: .utf8)
        exportedFileURL = url
        showShareSheet = true
        store.showToastMessage("Export ready")
    }

    private func exportCSV() {
        guard let csv = store.exportCSV() else { return }
        let fileName = "seatfolio_export_\(Date().formatted(.dateTime.year().month().day())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        exportedFileURL = url
        showShareSheet = true
        store.showToastMessage("Export ready")
    }

    private func handleImport(_ result: Result<URL, Error>) {
        guard case .success(let url) = result else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? String(contentsOf: url, encoding: .utf8) else { return }
        if store.importJSON(data) {
            store.showToastMessage("Data imported successfully")
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
