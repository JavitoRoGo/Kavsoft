//
//  ContentView.swift
//  TextFieldWithLengthIndicator
//
//  Created by Javier Rodríguez Gómez on 2/4/24.
//

import SwiftUI

struct ContentView: View {
	@State private var text = ""
	@State private var autoResizes = true
	@State private var allowsExcessTyping = false
	@State private var showsRing = true
	@State private var cornerRadius: CGFloat = 12
	
	var config: LimitedTextField.Config {
		.init(limit: 40, tint: .secondary, autoResizes: autoResizes, allowsExcessTyping: allowsExcessTyping, progressConfig: .init(showsRing: showsRing, showsText: !showsRing), borderConfig: .init(radius: cornerRadius))
	}
	
    var body: some View {
		NavigationStack {
			VStack {
				LimitedTextField(config: config, hint: "Type here", value: $text)
				.autocorrectionDisabled()
				.frame(maxHeight: 150)
				
				Form {
					Section("Indicator Type") {
						Picker("Indicator type", selection: $showsRing) {
							Text("Ring")
								.tag(true)
							Text("Text")
								.tag(false)
						}
						.pickerStyle(.segmented)
						.labelsHidden()
					}
					Section {
						Toggle("Auto Resize TextField", isOn: $autoResizes)
						Toggle("Allows Excess Typing", isOn: $allowsExcessTyping)
					}
					Section("Border Radius") {
						Slider(value: $cornerRadius, in: 1...40)
					}
				}
				.clipShape(.rect(cornerRadius: cornerRadius))
			}
			.padding()
			.navigationTitle("Limited TextField")
		}
    }
}

#Preview {
    ContentView()
}
