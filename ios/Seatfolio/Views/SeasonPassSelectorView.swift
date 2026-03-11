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
                    ForEach(store.seasonPasses, id: \.id) { pass in
                        passRow(pass)
                    }
                }

                Section {
                    Button {
                        showAddPass = true
                    } label: {
                        Label("Add Season Pass", systemImage: "plus")
                    }
                }

            }
            .navigationTitle("Season Passes")
        }
    }

    private func passRow(_ pass: SeasonPass) -> some View {

        HStack(spacing: 14) {

            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {

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

        .contentShape(Rectangle())

        .onTapGesture {
            store.activePassId = pass.id
            dismiss()
        }

    }

}
