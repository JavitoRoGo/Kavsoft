//
//  ContentView.swift
//  ParallaxScroll
//
//  Created by Javier Rodríguez Gómez on 4/1/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NavigationStack {
			Home()
				.navigationTitle("Parallax Scroll")
		}
    }
}

#Preview {
    ContentView()
}
