//
//  ContentView.swift
//  AnimatedSwiftCharts
//
//  Created by Javier Rodríguez Gómez on 5/4/24.
//

import Charts
import SwiftUI

struct ContentView: View {
	@State private var appDownloads = sampleDownloads
	@State private var isAnimated = false
	@State private var trigger = false
	
    var body: some View {
		NavigationStack {
			VStack {
				Chart {
					ForEach(appDownloads) { download in
						// Animating step 2: use the property to display values
						SectorMark(
							angle: .value("Downloads", download.isAnimated ? download.value : 0)
						)
						.foregroundStyle(by: .value("Month", download.month))
						.opacity(download.isAnimated ? 1 : 0)
					}
				}
				// Animating step 3: for LineMark, BarMark and AreaMark, declare the y-axis domain range with the max value or any suitable value
				.chartYScale(domain: 0...12000)
				.frame(height: 250)
				.padding()
				.background(.background, in: .rect(cornerRadius: 10))
				
				Spacer(minLength: 0)
			}
			.padding()
			.background(.gray.opacity(0.12))
			.navigationTitle("Animated Charts")
			.onAppear(perform: animateChart)
			.onChange(of: trigger, initial: false) {
				resetChartAnimation()
				animateChart()
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Trigger") {
						trigger.toggle()
					}
				}
			}
		}
    }
	
	// Animating step 4: animate each item with a delay to create the chart animation
	private func animateChart() {
		guard !isAnimated else { return }
		isAnimated = true
		
		// Just like how we can update data when we pass a binding value to ForEach, we can apply the same method to change or update the data without subscripting an array with indices
		$appDownloads.enumerated().forEach { index, element in
			let delay = Double(index) * 0.05
			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
				withAnimation(.smooth) {
					element.wrappedValue.isAnimated = true
				}
			}
		}
	}
	
	private func resetChartAnimation() {
		$appDownloads.forEach { download in
			download.wrappedValue.isAnimated = false
		}
		
		isAnimated = false
	}
}

#Preview {
    ContentView()
}
