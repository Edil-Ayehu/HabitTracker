//
//  HabitTrackerWidgetBundle.swift
//  HabitTrackerWidget
//
//  Created by Edil on 24/08/2026.
//

import WidgetKit
import SwiftUI

@main
struct HabitTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitTrackerWidget()
        HabitTrackerWidgetControl()
        HabitTrackerWidgetLiveActivity()
    }
}
