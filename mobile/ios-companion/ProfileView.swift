import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: PaperMadeStore

    private var profile: PaperMadeProfile {
        store.profile
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.green.opacity(0.14))
                        .frame(width: 86, height: 86)
                        .overlay {
                            Text(initials)
                                .font(.title.bold())
                                .foregroundStyle(.green)
                        }

                    Text(profile.displayName.isEmpty ? fallbackName : profile.displayName)
                        .font(.title2.bold())

                    if !profile.discordUsername.isEmpty {
                        Text("@\(profile.discordUsername)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !profile.bio.isEmpty {
                        Text(profile.bio)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                }

                HStack(spacing: 10) {
                    infoCard("CHAIN", profile.favoriteChain.isEmpty ? "—" : profile.favoriteChain)
                    infoCard("STYLE", profile.tradingStyle.isEmpty ? "—" : profile.tradingStyle)
                }

                if !profile.xHandle.isEmpty {
                    Link(destination: URL(string: "https://x.com/\(profile.xHandle.replacingOccurrences(of: "@", with: ""))")!) {
                        Label("@\(profile.xHandle.replacingOccurrences(of: "@", with: ""))", systemImage: "link")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Achievements")
                            .font(.headline)
                        Spacer()
                        Text("\(profile.badges.filter(\.unlocked).count) unlocked")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if profile.badges.isEmpty {
                        Text("Badge data hasn't synced into the app yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(profile.badges.filter(\.unlocked)) { badge in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(badge.title)
                                        .fontWeight(.semibold)
                                    Text(badge.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(badge.rarity.uppercased())
                                    .font(.caption2.bold())
                                    .foregroundStyle(.green)
                            }
                            .padding()
                            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle("Profile")
        .task {
            store.reloadSharedSnapshots()
        }
    }

    private var fallbackName: String {
        profile.discordUsername.isEmpty ? "PaperMade Trader" : profile.discordUsername
    }

    private var initials: String {
        let name = profile.displayName.isEmpty ? fallbackName : profile.displayName
        let pieces = name.split(separator: " ").prefix(2)
        let text = pieces.compactMap { $0.first }.map(String.init).joined()
        return text.isEmpty ? "PM" : text.uppercased()
    }

    private func infoCard(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 14))
    }
}
