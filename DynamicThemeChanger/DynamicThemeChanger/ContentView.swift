//
//  ContentView.swift
//  DynamicThemeChanger
//
//  Created by Javier Rodríguez Gómez on 3/1/24.
//

import SwiftUI

struct ContentView: View {
	@State private var changeTheme = false
	@AppStorage("user_theme") private var userTheme: Theme = .systemDefault
	@Environment(\.colorScheme) private var scheme
	
    var body: some View {
		NavigationStack {
			List {
				Section("Appearance") {
					Button("Change Theme") {
						changeTheme.toggle()
					}
				}
			}
			.navigationTitle("Settings")
		}
		.preferredColorScheme(userTheme.colorScheme)
		.sheet(isPresented: $changeTheme) {
			ThemeChangeView(scheme: scheme)
				.presentationDetents([.height(410)])
				.presentationBackground(.clear)
		}
    }
}

#Preview {
    ContentView()
}
