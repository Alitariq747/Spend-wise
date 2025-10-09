//
//  MonthPicker.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import SwiftUI

struct MonthPicker: View {
  @Binding var month: Date
  var limitToCurrentMonth = true

  var body: some View {
    HStack(spacing: 12) {
      Button { withAnimation(.snappy) { month = MonthUtil.addMonths(month, -1) } } label: {
          Image(systemName: "chevron.left")
              .font(.headline)
              .symbolRenderingMode(.monochrome)
              .foregroundStyle(.black)
      }
      
   
      Text(MonthUtil.fmt.string(from: month))
        .font(.headline).frame(maxWidth: .infinity)

      Button {
        withAnimation(.snappy) { month = MonthUtil.addMonths(month, 1) }
      } label: {
        Image(systemName: "chevron.right").font(.headline)
              .symbolRenderingMode(.monochrome)
              .foregroundStyle(.black)
      }
     
      .disabled(limitToCurrentMonth && MonthUtil.monthKey(month) == MonthUtil.monthKey(Date()))
      .opacity(limitToCurrentMonth && MonthUtil.monthKey(month) == MonthUtil.monthKey(Date()) ? 0.2 : 1)
    }
    .padding(.vertical, 16)
    .padding(.horizontal, 12)
    .background(.white, in: RoundedRectangle(cornerRadius: 16))
  }
}

#Preview {
    MonthPicker(month: .constant(Calendar.current.date(from: .init(year: 2025, month: 9))!), limitToCurrentMonth: true)
}
