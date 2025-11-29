//
//  SpendWiseWidgetsBundle.swift
//  SpendWiseWidgets
//
//  Created by Ahmad Ali Tariq on 26/11/2025.
//

import WidgetKit
import SwiftUI

@main
struct SpendWiseWidgetsBundle: WidgetBundle {
    var body: some Widget {
      
        MonthOverviewWidget()
        WeeklySpentWidget()
    }
}

struct MonthOverviewWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MonthOverviewWidget",
            provider: MonthOverviewProvider()
        ) { entry in
            MonthOverviewWidgetView(entry: entry)
        }
        .configurationDisplayName("Month Overview")
        .description("See this month’s budget and spending at a glance.")
        .supportedFamilies([.systemMedium])
    }
}
