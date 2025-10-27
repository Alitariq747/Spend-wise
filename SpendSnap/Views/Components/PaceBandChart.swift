//
//  PaceBandChart.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 17/10/2025.
//

import SwiftUI


import Charts

struct PaceBandChart: View {
    let bands: [PaceBand]   // from makeBands(points)

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .semibold))
                Text("Actual VS Target")
                    .font(.system(size: 12, weight: .semibold))
            }
            Chart {
                ForEach(bands) { b in
                    AreaMark(
                        x: .value("Day", b.day),
                        yStart: .value("Low",  b.yStart),
                        yEnd:   .value("High", b.yEnd)
                    )
                    .foregroundStyle(by: .value("State", b.state.rawValue))
                }
            }
            .chartForegroundStyleScale([
                "Under": Color.green.opacity(0.22),
                "Over":  Color.red.opacity(0.22)
            ])
            .chartXAxis { AxisMarks(values: .stride(by: 7)) }
            .chartYAxis { AxisMarks(position: .leading) }
            .frame(height: 220)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
    }
}


//#Preview {
//    PaceBandChart()
//}
