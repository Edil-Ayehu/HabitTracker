//
//  HabitCalendarView.swift
//  HabitTracker
//
//  Created by Edil on 03/08/2026.
//

import SwiftUI


struct HabitCalendarView: View {
    
    let entries: [HabitEntry]
    
    
    private let calendar = Calendar.current
    
    private let weekDays = [
        "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
    ]
    
    @State private var displayedMonth = Date()

    
    
    
    var body: some View {
        
        VStack(
            alignment:.leading,
            spacing:16
        ) {
        
            
            HStack {

                Button {

                    displayedMonth = Calendar.current.date(
                        byAdding: .month,
                        value: -1,
                        to: displayedMonth
                    )!

                } label: {

                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(
                    displayedMonth.formatted(
                        .dateTime.month(.wide).year()
                    )
                )
                .font(AppFont.headline())

                Spacer()

                Button {

                    displayedMonth = Calendar.current.date(
                        byAdding: .month,
                        value: 1,
                        to: displayedMonth
                    )!

                } label: {

                    Image(systemName: "chevron.right")
                }
            }
            
            LazyVGrid(
                columns:
                    Array(
                        repeating:
                            GridItem(.flexible()),
                        count:7
                    ),
                spacing:8
            ) {
                
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
            
                ForEach(calendarDays.indices, id: \.self) { index in

                    if let date = calendarDays[index] {

                        dayCell(date)

                    } else {

                        Color.clear
                            .frame(height: 28)
                    }
                }
            }
            
            
            
        }
        .padding()
        .background(
            RoundedRectangle(
                cornerRadius:20
            )
            .fill(AppColors.card)
        )
    }
    
    
    
    @ViewBuilder
    private func dayCell(
        _ date: Date
    ) -> some View {
        
        
        let completed =
        entries.contains {
            
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
            &&
            $0.completed
        }
        
        ZStack {

            RoundedRectangle(cornerRadius: 6)
                .fill(color(for: date))

            Text("\(calendar.component(.day, from: date))")
                .font(.caption2)
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(height: 34)
        
    
        
    }
    
    private var calendarDays: [Date?] {

        guard
            let firstDay = calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: displayedMonth
                )
            ),
            let range = calendar.range(
                of: .day,
                in: .month,
                for: displayedMonth
            )
        else {
            return []
        }

        // Monday = 1 ... Sunday = 7
        var weekday = calendar.component(.weekday, from: firstDay)

        // Calendar returns:
        // Sunday = 1
        // Monday = 2
        // ...
        // Saturday = 7

        weekday = weekday == 1 ? 7 : weekday - 1

        var days: [Date?] = Array(repeating: nil, count: weekday - 1)

        for day in range {

            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDay
            ) {
                days.append(date)
            }
        }

        return days
    }
    
    private func color(for date: Date) -> Color {

        guard let entry = entries.first(
            where: {
                calendar.isDate($0.date, inSameDayAs: date)
            }
        ) else {
            return Color.gray.opacity(0.12)
        }

        if entry.isFrozen {
            return Color.cyan
        }

        let progress: Double

        switch entry.habit.habitType {

        case .binary:
            progress = entry.completed ? 1 : 0

        case .measurable:

            let goal = Double(entry.habit.goal ?? 1)

            progress = Double(entry.progress) / goal
        }

        switch progress {

        case 0:
            return AppColors.calendarEmpty

        case 0..<0.25:
            return AppColors.calendarLow

        case 0.25..<0.5:
            return AppColors.calendarMedium

        case 0.5..<0.75:
            return AppColors.calendarHigh

        default:
            return AppColors.calendarComplete
        }
    }
}
