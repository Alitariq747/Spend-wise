//
//  MonthPicker.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI

struct MonthPicker: View {
  @Environment(\.colorScheme) private var colorScheme
    
  @Binding var month: Date
  var limitToCurrentMonth = true

  var body: some View {
    HStack(spacing: 8) {
      Button { withAnimation(.snappy) { month = MonthUtil.addMonths(month, -1) } } label: {
          Image(systemName: "chevron.left.circle")
              .font(.subheadline)
              .symbolRenderingMode(.monochrome)
              .foregroundStyle(.primary)
      }
      .buttonStyle(.plain)
   
      Text(MonthUtil.fmt.string(from: month))
        .font(.headline)

      Button {
        withAnimation(.snappy) { month = MonthUtil.addMonths(month, 1) }
      } label: {
        Image(systemName: "chevron.right.circle").font(.subheadline)
              .symbolRenderingMode(.monochrome)
              .foregroundStyle(.primary)
      }
      .buttonStyle(.plain)
      .disabled(limitToCurrentMonth && MonthUtil.monthKey(month) == MonthUtil.monthKey(Date()))
      .opacity(limitToCurrentMonth && MonthUtil.monthKey(month) == MonthUtil.monthKey(Date()) ? 0.2 : 1)
    }
    .padding(.vertical, 16)
    .padding(.horizontal, 12)
   

  }
}

#Preview {
    MonthPicker(month: .constant(Calendar.current.date(from: .init(year: 2025, month: 9))!), limitToCurrentMonth: true)
}
