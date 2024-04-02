//
//  LimitedTextField.swift
//  TextFieldWithLengthIndicator
//
//  Created by Javier Rodríguez Gómez on 2/4/24.
//

import SwiftUI

struct LimitedTextField: View {
	var config: Config
	var hint: String
	@Binding var value: String
	
	@FocusState private var isKeyboardShowing: Bool
	
    var body: some View {
		VStack(alignment: config.progressConfig.alignment, spacing: 12) {
			ZStack(alignment: .top) {
				RoundedRectangle(cornerRadius: config.borderConfig.radius)
					.fill(.clear)
					.frame(height: config.autoResizes ? 0 : nil)
					.contentShape(.rect(cornerRadius: config.borderConfig.radius))
					.onTapGesture {
						// Show keyboard: TextField with the axis property only increases the height as needed; thus, if the textfield is set to use the entire available height, tapping outside the textfield will not open the keyboard, however, placing a tappable view beneath the textfield that occupies the entire height will open the keyboard when we tap on it
						isKeyboardShowing = true
					}
				
				TextField(hint, text: $value, axis: .vertical)
					.focused($isKeyboardShowing)
					.onChange(of: value, initial: true) {
						guard !config.allowsExcessTyping else { return }
						value = String(value.prefix(config.limit))
					}
			}
			.padding(.horizontal, 15)
			.padding(.vertical, 10)
			.background {
				RoundedRectangle(cornerRadius: config.borderConfig.radius)
					.stroke(progressColor.gradient, lineWidth: config.borderConfig.width)
			}
			
			// Progress bar / text indicator
			HStack(alignment: .top, spacing: 12) {
				if config.progressConfig.showsRing {
					ZStack {
						Circle()
							.stroke(.ultraThinMaterial, lineWidth: 5)
						Circle()
							.trim(from: 0, to: progress)
							.stroke(progressColor.gradient, lineWidth: 5)
							.rotationEffect(.init(degrees: -90))
					}
					.frame(width: 20, height: 20)
				}
				
				if config.progressConfig.showsText {
					Text("\(value.count)/\(config.limit)")
						.foregroundStyle(progressColor.gradient)
				}
			}
		}
    }
	
	// This is the configuration for the text field, which contains all the necessary customisation, which you can even include if you want anything in particular
	
	var progress: CGFloat {
		max(min(CGFloat(value.count) / CGFloat(config.limit), 1), 0)
	}
	
	var progressColor: Color {
		progress < 0.6 ? config.tint : progress == 1.0 ? .red : .orange
	}
	
	struct Config {
		var limit: Int
		var tint: Color = .blue
		var autoResizes: Bool = false
		var allowsExcessTyping: Bool = false
		var progressConfig: ProgressConfig = .init()
		var borderConfig: BorderConfig = .init()
	}
	
	struct ProgressConfig {
		var showsRing: Bool = true
		var showsText: Bool = false
		var alignment: HorizontalAlignment = .trailing
	}
	
	struct BorderConfig {
		var show: Bool = true
		var radius: CGFloat = 12
		var width: CGFloat = 0.8
	}
}

#Preview {
    ContentView()
}
