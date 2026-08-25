//
//  HabitWidgetViews.swift
//  HabitTrackerWidget
//

import SwiftUI

struct HabitSmallWidgetView: View {
    let data: HabitWidgetData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Habits", systemImage: "sparkles")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.indigo)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
                    Text("\(data.currentStreak)")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.orange.opacity(0.15))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(data.completionRate) / 100.0)
                        .stroke(Color.indigo, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(data.completionRate)%")
                            .font(.system(size: 18, weight: .bold))
                        Text("\(data.completedHabits)/\(data.totalHabits)")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 72, height: 72)
                Spacer()
            }
            
            Spacer()
            
            Text(data.completedHabits == data.totalHabits && data.totalHabits > 0 ? "🎉 All Completed!" : "Keep Going!")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
    }
}

struct HabitMediumWidgetView: View {
    let data: HabitWidgetData
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Progress Column
            VStack(alignment: .leading, spacing: 6) {
                Label("Today's Goal", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.indigo)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 7)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(data.completionRate) / 100.0)
                        .stroke(Color.indigo, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(data.completionRate)%")
                            .font(.system(size: 16, weight: .bold))
                        Text("\(data.completedHabits)/\(data.totalHabits)")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 64, height: 64)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 11))
                    Text("\(data.currentStreak) Day Streak")
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .frame(width: 110)
            
            Divider()
            
            // Right Habits List
            VStack(alignment: .leading, spacing: 8) {
                Text("Habits")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                
                if data.items.isEmpty {
                    Text("No habits scheduled for today.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxHeight: .infinity)
                } else {
                    VStack(spacing: 6) {
                        ForEach(data.items.prefix(3)) { item in
                            HStack(spacing: 8) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.indigo)
                                    .frame(width: 18)
                                
                                Text(item.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundStyle(item.completed ? Color.green : Color.gray.opacity(0.4))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding(12)
    }
}

struct HabitLockScreenCircularView: View {
    let data: HabitWidgetData
    
    var body: some View {
        ZStack {
            Gauge(value: Double(data.completionRate), in: 0...100) {
                Image(systemName: "checkmark")
            } currentValueLabel: {
                Text("\(data.completionRate)%")
                    .font(.system(size: 12, weight: .bold))
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}

struct HabitLockScreenRectangularView: View {
    let data: HabitWidgetData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Streak: \(data.currentStreak) days")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            Text("\(data.completedHabits) of \(data.totalHabits) Habits Done")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            
            ProgressView(value: Double(data.completionRate), total: 100)
                .tint(Color.indigo)
        }
    }
}
