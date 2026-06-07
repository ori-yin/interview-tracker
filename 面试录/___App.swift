//
//  面试录App.swift
//  面试录
//
//  Created by ori_mac on 2026/5/31.
//

import SwiftUI
import SwiftData

@main
struct 面试录App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: JobApplication.self)
    }
}
