//
//  ContentView.swift
//  StackedCardScrollView
//
//  Created by Javier Rodríguez Gómez on 16/5/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		ZStack {
			GeometryReader { _ in
				LinearGradient(colors: [.gray, .blue], startPoint: .top, endPoint: .bottom)
					.ignoresSafeArea()
			}
			Home()
		}
		.environment(\.colorScheme, .dark)
    }
}

#Preview {
    ContentView()
}
