//
//  ReminderSection.swift
//  HabitTracker
//
//  Created by Edil on 03/08/2026.
//

import SwiftUI


struct ReminderSection: View {
    
    
    @State private var enabled: Bool
    
    @State private var time: Date
    
    
    let onSave:
    (
        Bool,
        Date
    ) -> Void
    
    
    
    init(
        enabled: Bool,
        time: Date,
        onSave:
        @escaping(
            Bool,
            Date
        )->Void
    ) {
        
        _enabled =
        State(
            initialValue: enabled
        )
        
        _time =
        State(
            initialValue: time
        )
        
        self.onSave = onSave
    }
    
    
    
    var body: some View {
        
        
        VStack(
            alignment:.leading,
            spacing:16
        ) {
            
            
            HStack {
                
                
                Label(
                    "Reminder",
                    systemImage:"bell"
                )
                
                
                Spacer()
                
                
                Toggle(
                    "",
                    isOn:$enabled
                )
                .onChange(
                    of: enabled
                ) {
                    
                    onSave(
                        enabled,
                        time
                    )
                }
                
            }
            
            
            
            if enabled {
                
                
                DatePicker(
                    "Reminder Time",
                    selection:$time,
                    displayedComponents:.hourAndMinute
                )
                .onChange(
                    of: time
                ) {
                    
                    onSave(
                        enabled,
                        time
                    )
                }
                
                
                Button {
                    
                    enabled = false
                    
                    onSave(
                        false,
                        time
                    )
                    
                } label: {
                    
                    Label(
                        "Remove Reminder",
                        systemImage:"trash"
                    )
                    .foregroundStyle(AppColors.error)
                    
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
    
}
