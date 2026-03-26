import SwiftUI

struct GameTimerView: View {

    @EnvironmentObject var gameTracker: GameSession

    var body: some View {

        TimelineView(.periodic(from: .now, by: 1)) { context in

            Text(formatTime(gameTracker.remainingTime))
                .font(.title2)
                .monospacedDigit()
                .onChange(of: context.date) { _ in
                    gameTracker.updateTimer()
                }
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
