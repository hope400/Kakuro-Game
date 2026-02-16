import SwiftUI

struct EasyLevels: View {

    private let levelNumbers = Array(1...10)

    @EnvironmentObject var gameTracker: GameTracker

    // 5 columns, square-ish buttons
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 16),
        count: 5
    )

    var body: some View {
        NavigationStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(height: 600)

                VStack(spacing: 24) {

                    Text("Easy Levels")
                        .font(.largeTitle)
                        .bold()

                    LazyVGrid(columns: columns, spacing: 16) {

                        ForEach(levelNumbers, id: \.self) { level in

                            let isCompleted =
                                gameTracker.completedLevels[.easy]?
                                .contains(level) ?? false

                            NavigationLink(destination: LevelView()) {

                                ZStack(alignment: .topTrailing) {

                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            isCompleted
                                            ? Color.green.opacity(0.25)
                                            : Color.blue.opacity(0.2)
                                        )
                                        .frame(width: 50, height: 50)

                                    Text("\(level)")
                                        .font(.title2)
                                        .foregroundStyle(.primary)

                                    if isCompleted {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .offset(x: 6, y: -6)
                                    }
                                }
                            }
                            .simultaneousGesture(
                                TapGesture().onEnded {

                                    // Set difficulty explicitly for safety
                                    gameTracker.setDifficulty(.easy)

                                    // Load selected level
                                    gameTracker.setLevel(level)

                                }
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    EasyLevels()
        .environmentObject(GameTracker())
}
