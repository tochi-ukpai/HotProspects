//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Theós on 27/06/2023.
//

import SwiftUI

@main
struct HotProspectsApp: App {
    @StateObject var prospects = Prospects()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(prospects)
        }
    }
}
