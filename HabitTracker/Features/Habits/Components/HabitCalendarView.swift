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
    
    
    private var monthDates: [Date] {
        
        let today = Date()
        
        guard let range = calendar.range(
            of: .day,
            in: .month,
            for: today
        ) else {
            return []
        }
        
        
        return range.compactMap {
            
            calendar.date(
                byAdding: .day,
                value: $0 - 1,
                to: calendar.date(
                    from: calendar.dateComponents(
                        [.year,.month],
                        from: today
                    )
                )!
            )
        }
    }
    
    
    
    var body: some View {
        
        VStack(
            alignment:.leading,
            spacing:16
        ) {
            
            
            Text(
                Date.now.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .font(
                AppFont.headline()
            )
            
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
                        .foregroundStyle(.secondary)
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
            .fill(.white)
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
        
        
        RoundedRectangle(
            cornerRadius:5
        )
        .fill(
            completed
            ?
            Color.green
            :
            Color.gray.opacity(0.15)
        )
        .frame(
            height:28
        )
        
    }
    
    private var calendarDays: [Date?] {

        let today = Date()

        guard
            let firstDay = calendar.date(
                from: calendar.dateComponents([.year, .month], from: today)
            ),
            let range = calendar.range(of: .day, in: .month, for: today)
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
}
