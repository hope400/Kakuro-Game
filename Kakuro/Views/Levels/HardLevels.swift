import SwiftUI


struct HardLevels: View {

    private let levelNumbers = Array(1...10)

    @EnvironmentObject var gameTracker: GameSession

    // navigation + alerts
    @State private var navigateToLevel = false
    @State private var showAccessAlert = false
    @State private var selectedLevel = 1

    // 5 columns
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 16),
        count: 5
    )

    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.ultraThinMaterial)
                .frame(height: 600)

            VStack(spacing: 24) {

                Text("Hard Levels")
                    .font(.largeTitle)
                    .bold()

                LazyVGrid(columns: columns, spacing: 16) {

                    ForEach(levelNumbers, id: \.self) { level in

                        let isCompleted =
                            gameTracker.completedLevels[.hard]?
                            .contains(level) ?? false

                        let isLocked =
                            gameTracker.isGuestMode && level > 5

                        Button {

                            gameTracker.setDifficulty(.hard)

                            let allowed = gameTracker.selectLevel(level)

                            if allowed {
                                selectedLevel = level
                                navigateToLevel = true
                            } else {
                                showAccessAlert = true
                            }

                        } label: {

                            ZStack(alignment: .topTrailing) {

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        isCompleted
                                        ? Color.green.opacity(0.25)
                                        : Color.blue.opacity(0.2)
                                    )
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Text("\(level)")
                                            .font(.title2)
                                            .foregroundStyle(.primary)
                                    }

                                if isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .offset(x: 6, y: -6)
                                }

                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                        .offset(x: 6, y: -6)
                                }
                            }
                            .opacity(isLocked ? 0.4 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }

        // controlled navigation
        .navigationDestination(isPresented: $navigateToLevel) {
            LevelView()
        }

        // guest restriction alert
        .alert("Login required", isPresented: $showAccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Guest players can only play levels 1–5.")
        }

        .onAppear {
            _ = gameTracker.loadGame()
        }
    }
}

#Preview {
    HardLevels()
        .environmentObject(GameSession())
}

#Preview {
    HardLevels()
        .environmentObject(GameSession())
}
