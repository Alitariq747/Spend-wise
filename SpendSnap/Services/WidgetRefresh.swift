//
//  WidgetRefresh.swift
//  SpendSnap
//

import WidgetKit


enum WidgetRefresh {


    static func reloadAll() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
