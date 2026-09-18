import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: PaperMadeStore
    @State private var monthOffset = 0

    private var selectedMonth: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    private var monthTitle: String {
        selectedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var dayPnL: [Date: Double] {
        var result: [Date: Double] = [:]
        let cal = Calendar.current

        // Prefer the persistent daily ledger because it survives journal trimming.
        for (key, row) in store.snapshot.calendarDays {
            let parts = key.split(separator: "-").compactMap { Int($0) }
            guard parts.count == 3 else { continue }
            var components = DateComponents()
            components.year = parts[0]
            components.month = parts[1]
            components.day = parts[2]
            if let date = cal.date(from: components) {
                result[cal.startOfDay(for: date)] = row.pnl
            }
        }

        // Fill any older/missing ledger days from the detailed closed-trade journal.
        for trade in store.closedTrades {
            let day = cal.startOfDay(for: trade.exitAt)
            if result[day] == nil {
                result[day, default: 0] += trade.realizedPnl
            }
        }

        return result
    }

    private var days: [Date?] {
        let cal = Calendar.current
        guard
            let interval = cal.dateInterval(of: .month, for: selectedMonth),
            let range = cal.range(of: .day, in: .month, for: selectedMonth)
        else { return [] }

        let first = interval.start
        let weekday = cal.component(.weekday, from: first)
        var output: [Date?] = Array(repeating: nil, count: max(0, weekday - 1))

        for day in range {
            output.append(cal.date(byAdding: .day, value: day - 1, to: first))
        }

        while output.count % 7 != 0 {
            output.append(nil)
        }
        return output
    }

    private var monthTotal: Double {
        let cal = Calendar.current
        return dayPnL.reduce(0) { partial, item in
            cal.isDate(item.key, equalTo: selectedMonth, toGranularity: .month)
                ? partial + item.value
                : partial
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Button {
                        monthOffset -= 1
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    VStack(spacing: 3) {
                        Text(monthTitle)
                            .font(.headline)
                        Text(monthTotal.formatted(.currency(code: "USD").sign(strategy: .always())))
                            .font(.caption.bold())
                            .foregroundStyle(monthTotal >= 0 ? .green : .red)
                    }

                    Spacer()

                    Button {
                        monthOffset += 1
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)

                let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(["S","M","T","W","T","F","S"], id: .self) { day in
                        Text(day)
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }

                    ForEach(Array(days.enumerated()), id: .offset) { _, date in
                        DayCell(date: date, pnl: date.flatMap { dayPnL[Calendar.current.startOfDay(for: $0)] })
                    }
                }
                .padding(.horizontal)

                if store.closedTrades.isEmpty && store.snapshot.calendarDays.isEmpty {
                    ContentUnavailableView(
                        "No Realized P&L Yet",
                        systemImage: "calendar",
                        description: Text("Closed paper trades will populate your mobile P&L calendar.")
                    )
                    .padding(.top, 24)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("P&L Calendar")
        .task {
            store.reloadSharedSnapshots()
        }
    }
}

private struct DayCell: View {
    let date: Date?
    let pnl: Double?

    var body: some View {
        Group {
            if let date {
                VStack(spacing: 4) {
                    Text(date.formatted(.dateTime.day()))
                        .font(.caption.bold())

                    if let pnl {
                        Text(shortMoney(pnl))
                            .font(.caption2.bold())
                            .foregroundStyle(pnl >= 0 ? .green : .red)
                    } else {
                        Text(" ")
                            .font(.caption2)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    (pnl ?? 0) == 0
                        ? Color.white.opacity(0.04)
                        : (pnl ?? 0) >= 0
                            ? Color.green.opacity(0.11)
                            : Color.red.opacity(0.11),
                    in: RoundedRectangle(cornerRadius: 10)
                )
            } else {
                Color.clear
                    .frame(minHeight: 52)
            }
        }
    }

    private func shortMoney(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "-"
        return "\(sign)$\(String(format: "%.2f", abs(value)))"
    }
}
