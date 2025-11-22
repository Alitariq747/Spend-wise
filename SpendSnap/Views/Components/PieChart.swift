//
//  PieChart.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 12/10/2025.
//

import SwiftUI

struct PieChart: View {
    struct Segment: Identifiable {
        let id = UUID()
        let fraction: Double   // 0…1
        let color: Color
    }

    let segments: [Segment]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let r = min(w, h) / 2
            let c = CGPoint(x: w / 2, y: h / 2)

            ZStack {
                ForEach(buildSlices(segments), id: \.id) { s in
                    Path { p in
                        p.move(to: c)
                        p.addArc(center: c,
                                 radius: r,
                                 startAngle: .degrees(s.startDeg - 90), // start at 12 o'clock
                                 endAngle:   .degrees(s.endDeg - 90),
                                 clockwise: false)
                        p.closeSubpath()
                    }
                    .fill(s.color)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private struct Slice {
        let id = UUID()
        let startDeg: Double
        let endDeg: Double
        let color: Color
    }

    private func buildSlices(_ segs: [Segment]) -> [Slice] {
        var out: [Slice] = []
        var cursor = 0.0
        for s in segs {
            let f = max(0, min(1, s.fraction))
            let start = cursor * 360
            let end   = (cursor + f) * 360
            out.append(Slice(startDeg: start, endDeg: end, color: s.color))
            cursor += f
        }
        // Optional remainder (light gray) if total < 1
        if cursor < 1.0 {
            out.append(Slice(startDeg: cursor * 360, endDeg: 360, color: Color(.secondarySystemBackground)))
        }
        return out
    }
}


#Preview {
    PieChart(segments: [
           .init(fraction: 0.40, color: .blue),
           .init(fraction: 0.25, color: .green),
           .init(fraction: 0.20, color: .orange),
           .init(fraction: 0.10, color: .purple)
       ])
       .frame(width: 180, height: 180)
       .padding()
}
