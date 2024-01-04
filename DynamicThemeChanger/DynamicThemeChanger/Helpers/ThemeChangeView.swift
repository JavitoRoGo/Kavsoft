//
//  ThemeChangeView.swift
//  DynamicThemeChanger
//
//  Created by Javier Rodríguez Gómez on 3/1/24.
//

import SwiftUI

struct ThemeChangeView: View {
	var scheme: ColorScheme
	@AppStorage("user_theme") private var userTheme: Theme = .systemDefault
	
	// For sliding effect
	@Namespace private var animation
	
	// View properties
	@State private var circleOffset: CGSize
	init(scheme: ColorScheme) {
		self.scheme = scheme
		let isDark = scheme == .dark
		// Verifying the initial state and setting it's offset to reflect either a circle or a moon
		self._circleOffset = .init(initialValue: CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150))
	}
	
    var body: some View {
		VStack(spacing: 15) {
			Circle()
				.fill(userTheme.color(scheme).gradient)
				.frame(width: 150, height: 150)
				.mask {
					// Inverted mask
					Rectangle()
						.overlay {
							Circle()
								.offset(circleOffset)
								.blendMode(.destinationOut)
						}
				}
			Text("Choose a Style")
				.font(.title2.bold())
				.padding(.top, 25)
			Text("Pop or subtle, Day or night.\nCustomize your interface.")
				.multilineTextAlignment(.center)
			
			// Custom segmented picker
			HStack(spacing: 0) {
				ForEach(Theme.allCases, id: \.rawValue) { theme in
					Text(theme.rawValue)
						.padding(.vertical, 10)
						.frame(width: 100)
						.background {
							ZStack {
								if userTheme == theme {
									Capsule()
										.fill(.bgcolor)
										.matchedGeometryEffect(id: "ACTIVETAB", in: animation)
								}
							}
							.animation(.snappy, value: userTheme)
						}
						.contentShape(.rect)
						.onTapGesture {
							userTheme = theme
						}
				}
			}
			.padding(3)
			.background(.primary.opacity(0.06), in: .capsule)
			.padding(.top, 20)
		}
		// Max height = 410
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.frame(height: 410)
		.background(.bgcolor)
		.clipShape(.rect(cornerRadius: 30))
		.padding(.horizontal, 15)
		.environment(\.colorScheme, scheme)
		.onChange(of: scheme, initial: false) { _, newValue in
			let isDark = newValue == .dark
			withAnimation(.bouncy) {
				circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
			}
		}
    }
}

#Preview {
    ContentView()
}

// Theme
enum Theme: String, CaseIterable {
	case systemDefault = "Default"
	case light = "Light"
	case dark = "Dark"
	
	func color(_ scheme: ColorScheme) -> Color {
		switch self {
			case .systemDefault:
				scheme == .dark ? .indigo : .orange
			case .light:
				.orange
			case .dark:
				.indigo
		}
	}
	
	var colorScheme: ColorScheme? {
		switch self {
			case .systemDefault:
				nil
			case .light:
				.light
			case .dark:
				.dark
		}
	}
}
