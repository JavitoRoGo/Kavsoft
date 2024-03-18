//
//  ContentView.swift
//  HorizontalWheelPicker
//
//  Created by Javier Rodríguez Gómez on 18/3/24.
//

import SwiftUI

struct ContentView: View {
	@State private var config: WheelPicker.Config = .init(count: 30, steps: 5, spacing: 15, multiplier: 10)
	@State private var value: CGFloat = 0
	
    var body: some View {
		NavigationStack {
			VStack {
				HStack(alignment: .lastTextBaseline, spacing: 5) {
					Text(verbatim: "\(value)")
						.font(.largeTitle.bold())
						.contentTransition(.numericText(value: value))
						.animation(.snappy, value: value)
					Text("lbs")
						.font(.title2)
						.fontWeight(.semibold)
						.textScale(.secondary)
						.foregroundStyle(.gray)
				}
				.padding(.bottom, 30)
				
				WheelPicker(config: config, value: $value)
					.frame(height: 60)
					.padding(.bottom, 50)
				
				Form {
					Section("Count") {
						Picker("Count", selection: $config.count) {
							Text("10").tag(10)
							Text("20").tag(20)
							Text("30").tag(30)
						}
						.pickerStyle(.segmented)
						.labelsHidden()
					}
					Section("Steps") {
						Picker("Count", selection: $config.steps) {
							Text("5").tag(5)
							Text("10").tag(10)
						}
						.pickerStyle(.segmented)
						.labelsHidden()
					}
					Section("Multiplier") {
						Picker("Count", selection: $config.multiplier) {
							Text("1").tag(1)
							Text("10").tag(10)
						}
						.pickerStyle(.segmented)
						.labelsHidden()
					}
					Section("Spacing") {
						Slider(value: $config.spacing, in: 5...20)
					}
				}
			}
			.navigationTitle("Wheel Picker")
		}
    }
}

#Preview {
    ContentView()
}
