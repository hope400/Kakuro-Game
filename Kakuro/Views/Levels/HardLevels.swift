import SwiftUI

struct HardLevels: View {

    private let levelNumbers = Array(1...10)

    @EnvironmentObject var gameTracker: GameTracker

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
                    Text("Hard Levels")
                        .font(.largeTitle)
                        .bold()

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(levelNumbers, id: \.self) { level in

                            // completion check
                            let isCompleted =
                                gameTracker.completedLevels[gameTracker.difficulty]?
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
                                        .foregroundColor(.primary)

                                    if isCompleted {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .offset(x: 6, y: -6)
                                    }
                                }
                            }
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    gameTracker.setDifficulty(.hard)
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
    HardLevels()
        .environmentObject(GameTracker())
}
