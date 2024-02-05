//
//  HeroEffectApp.swift
//  HeroEffect
//
//  Created by Javier Rodríguez Gómez on 4/2/24.
//

import SwiftUI

@main
struct HeroEffectApp: App {
    var body: some Scene {
        WindowGroup {
			HeroWrapper {
				ContentView()
			}
        }
    }
}
