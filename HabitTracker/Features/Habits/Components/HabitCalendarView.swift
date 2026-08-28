//
//  HabitCalendarView.swift
//  HabitTracker
//

import SwiftUI

struct HabitCalendarView: View {
    let entries: [HabitEntry]
    
    private let calendar = Calendar.current
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State private var displayedMonth = Date()
    
    var habitFrequency: HabitFrequency {
        entries.first?.habit.frequency ?? .daily
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Month Navigation Header
            HStack {
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(AppColors.primary)
                }
                
                Spacer()
                
                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(AppFont.headline())
                
                Spacer()
                
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColors.primary)
                }
            }
            
            // Weekday Column Headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
                
                ForEach(calendarDays.indices, id: \.self) { index in
                    if let date = calendarDays[index] {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 34)
                    }
                }
            }
            
            Divider()
            
            // Legend Footer
            HStack(spacing: 12) {
                if habitFrequency == .weekly {
                    legendItem(color: Color.purple.opacity(0.3), title: "Weekly Ribbon")
                    legendItem(color: Color.purple, title: "Check-in Day")
                } else if habitFrequency == .monthly {
                    legendItem(color: Color.indigo.opacity(0.25), title: "Monthly Highlight")
                    legendItem(color: Color.indigo, title: "Check-in Day")
                } else {
                    legendItem(color: AppColors.calendarComplete, title: "Completed")
                }
                legendItem(color: Color.cyan, title: "Frozen 🛡️")
            }
            .font(.system(size: 10))
            .foregroundStyle(AppColors.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.card)
        )
    }
    
    @ViewBuilder
    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
        }
    }
    
    @ViewBuilder
    private func dayCell(_ date: Date) -> some View {
        let cellInfo = cellState(for: date)
        
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(cellInfo.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(cellInfo.borderColor, lineWidth: cellInfo.isExactCheckIn ? 1.5 : 0)
                )
            
            VStack(spacing: 1) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 11, weight: cellInfo.isExactCheckIn ? .bold : .regular))
                    .foregroundStyle(cellInfo.textColor)
                
                if let icon = cellInfo.badgeIcon {
                    Image(systemName: icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(cellInfo.textColor)
                }
            }
        }
        .frame(height: 34)
    }
    
    private struct CellStateInfo {
        let backgroundColor: Color
        let borderColor: Color
        let textColor: Color
        let isExactCheckIn: Bool
        let badgeIcon: String?
    }
    
    private func cellState(for date: Date) -> CellStateInfo {
        switch habitFrequency {
        case .daily:
            guard let entry = entries.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) else {
                return CellStateInfo(backgroundColor: Color.gray.opacity(0.12), borderColor: .clear, textColor: AppColors.textPrimary, isExactCheckIn: false, badgeIcon: nil)
            }
            if entry.isFrozen {
                return CellStateInfo(backgroundColor: Color.cyan, borderColor: .cyan, textColor: .white, isExactCheckIn: true, badgeIcon: "shield.fill")
            }
            let isDone = entry.completed
            let bg = isDone ? AppColors.calendarComplete : AppColors.calendarEmpty
            return CellStateInfo(backgroundColor: bg, borderColor: .clear, textColor: isDone ? .white : AppColors.textPrimary, isExactCheckIn: isDone, badgeIcon: isDone ? "checkmark" : nil)
            
        case .weekly:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
                return CellStateInfo(backgroundColor: Color.gray.opacity(0.12), borderColor: .clear, textColor: AppColors.textPrimary, isExactCheckIn: false, badgeIcon: nil)
            }
            let startOfWeek = weekInterval.start
            let endOfWeek = weekInterval.end
            
            if let entry = entries.first(where: { $0.date >= startOfWeek && $0.date < endOfWeek }) {
                if entry.isFrozen {
                    return CellStateInfo(backgroundColor: Color.cyan.opacity(0.3), borderColor: .cyan, textColor: AppColors.textPrimary, isExactCheckIn: false, badgeIcon: "shield.fill")
                }
                if entry.completed {
                    let isExact = calendar.isDate(entry.date, inSameDayAs: date)
                    let bg = isExact ? Color.purple : Color.purple.opacity(0.22)
                    let textCol = isExact ? Color.white : AppColors.textPrimary
                    return CellStateInfo(backgroundColor: bg, borderColor: Color.purple, textColor: textCol, isExactCheckIn: isExact, badgeIcon: isExact ? "checkmark" : nil)
                }
            }
            return CellStateInfo(backgroundColor: Color.gray.opacity(0.12), borderColor: .clear, textColor: AppColors.textPrimary, isExactCheckIn: false, badgeIcon: nil)
            
        case .monthly:
            guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
                return CellStateInfo(backgroundColor: Color.gray.opacity(0.12), borderColor: .clear, textColor: AppColors.textPrimary, isExactCheckIn: false, badgeIcon: nil)
            }
            let startOfMonth = monthInterval.start
            let endOfMonth = monthInterval.end
            
            if let entry = entries.first(where: { $0.date >= startOfMonth && $0.date < endOfMonth }) {
                if entry.isFrozen {
                    return CellStateInfo(backgroundColor: Color.cyan.opacity(0.3), borderColor: .cyan, textColor: AppColors.textPrimary, isExactCheckIn: false, badgeIcon: "shield.fill")
                }
                if entry.completed {
                    let isExact = calendar.isDate(entry.date, inSameDayAs: date)
                    let bg = isExact ? Color.indigo : Color.indigo.opacity(0.2)
                    let textCol = isExact ? Color.white : AppColors.textPrimary
                    return CellStateInfo(backgroundColor: bg, borderColor: Color.indigo, textColor: textCol, isExactCheckIn: isExact, badgeIcon: isExact ? "star.fill" : nil)
                }
            }
            return CellStateInfo(backgroundColor: Color.gray.opacity(0.12), borderColor: .clear, textColor: AppColors.textPrimary, isExactCheckIn: false, badgeIcon: nil)
        }
    }
    
    private var calendarDays: [Date?] {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let range = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }
        
        var weekday = calendar.component(.weekday, from: firstDay)
        weekday = weekday == 1 ? 7 : weekday - 1
        var days: [Date?] = Array(repeating: nil, count: weekday - 1)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
}
