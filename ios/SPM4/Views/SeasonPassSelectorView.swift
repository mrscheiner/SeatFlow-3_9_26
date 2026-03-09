import SwiftUI

struct SeasonPassSelectorView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showAddPass = false
    @State private var showDeleteAlert = false
    @State private var deletePassId: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.seasonPasses) { pass in
                        HStack(spacing: 14) {
                            let theme = TeamThemeProvider.theme(for: pass.teamId)
                            let logoURL = LeagueData.team(for: pass.teamId)?.logoURL ?? ""
                            if !logoURL.isEmpty, let url = URL(string: logoURL) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } else {
                                        Circle()
                                            .fill(LinearGradient(colors: [theme.primary, theme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .overlay {
                                                Text(String(pass.teamName.prefix(2)).uppercased())
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.white)
                                            }
                                    }
                                }
                                .frame(width: 44, height: 44)
                            } else {
                                Circle()
                                    .fill(LinearGradient(colors: [theme.primary, theme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Text(String(pass.teamName.prefix(2)).uppercased())
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(pass.teamName)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text(pass.seasonLabel)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if pass.id == store.activePassId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title3)
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
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.switchToPass(pass.id)
                            dismiss()
                        }
                    }
                }

                Section {
                    Button {
                        showAddPass = true
                    } label: {
                        Label("Add New Season Pass", systemImage: "plus.circle.fill")
                            .font(.body.weight(.medium))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Season Passes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Are you sure you want to delete this Season Pass?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let id = deletePassId {
                        store.deletePass(id)
                        if store.seasonPasses.isEmpty {
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete the season pass and all its data.")
            }
            .sheet(isPresented: $showAddPass) {
                SetupView()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
