import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool

    private let steps = [
        ("1", "Install PaperMade", "PaperMade includes the Safari extension inside the iPhone app."),
        ("2", "Enable Safari Extension", "Open iPhone Settings → Safari → Extensions and enable PaperMade."),
        ("3", "Allow Supported Sites", "Allow PaperMade on FOMO, Axiom, Pump.fun and GMGN."),
        ("4", "Sign In", "Sign into papermade.xyz in Safari so your paper account can sync."),
        ("5", "Paper Trade", "Open a supported token page and tap the PaperMade pill at the bottom.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 54, weight: .black))
                            .foregroundStyle(.green)

                        Text("Welcome to PaperMade")
                            .font(.system(size: 29, weight: .black))
                            .multilineTextAlignment(.center)

                        Text("Real charts. Fake money. Better traders.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 10) {
                        ForEach(steps, id: \.0) { step in
                            HStack(alignment: .top, spacing: 12) {
                                Text(step.0)
                                    .font(.headline.bold())
                                    .foregroundStyle(.black)
                                    .frame(width: 30, height: 30)
                                    .background(.green, in: Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.1)
                                        .font(.headline)
                                    Text(step.2)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 0)
                            }
                            .padding()
                            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Label("Paper trading only", systemImage: "checkmark.shield")
                        Label("No seed phrase or private key", systemImage: "key.slash")
                        Label("No wallet custody or blockchain signing", systemImage: "signature")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                    Button {
                        isPresented = false
                    } label: {
                        Text("Got It")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding()
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
