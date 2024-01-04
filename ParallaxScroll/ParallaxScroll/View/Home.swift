//
//  Home.swift
//  ParallaxScroll
//
//  Created by Javier Rodríguez Gómez on 4/1/24.
//

import SwiftUI

struct Home: View {
    var body: some View {
		ScrollView(.vertical) {
			LazyVStack(spacing: 15) {
				DummySection(title: "Social Media")
				
				DummySection(title: "Sales", isLong: true)
				
				// Parallax image
				ParallaxImageView(usesFullWidth: true) { size in
					Image(.map)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: size.width, height: size.height)
				}
				.frame(height: 300)
				
				DummySection(title: "Social Media")
				
				DummySection(title: "Sales", isLong: true)
				
				ParallaxImageView(maximumMovement: 150, usesFullWidth: false) { size in
					Image(.opened)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: size.width, height: size.height)
				}
				.frame(height: 400)
				
				DummySection(title: "Social Media")
				
				DummySection(title: "Sales", isLong: true)
			}
			.padding(15)
		}
		.navigationBarTitleDisplayMode(.inline)
    }
	
	// Dummy section
	@ViewBuilder
	func DummySection(title: String, isLong: Bool = false) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.title.bold())
			
			Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit. \(isLong ? "But I must explain to you how all this mistaken idea of reprobating pleasure and extolling pain arose. because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful." : "")")
				.multilineTextAlignment(.leading)
				.kerning(1.2)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#Preview {
    ContentView()
}

struct ParallaxImageView<Content: View>: View {
	var maximumMovement: CGFloat = 100
	// The new iOS 17 API allows us to set the view to fill the specified axis to its full extent
	var usesFullWidth = false
	@ViewBuilder var content: (CGSize) -> Content
	var body: some View {
		GeometryReader {
			let size = $0.size
			// Movement animation properties
			let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
			// with the new named coordinate space, we can read the scrollview's height without the use of GeometryReader
			let scrollViewHeight = $0.bounds(of: .scrollView)?.size.height ?? 0
			// It returns the scrollview height. Using this height together with minY, we can define a progress range of 0 to 1, which will allow us to move the image and give us the parallax effect
			let maximumMovement = min(maximumMovement, (size.height * 0.35))
			let stretchedSize: CGSize = .init(width: size.width, height: size.height + maximumMovement)
			
			// It starts at 1.0 from the bottom and ends at 0.0 at the top
			let progress = minY / scrollViewHeight
			let cappedProgress = max(min(progress, 1.0), -1.0)
			let movementOffset = cappedProgress * -maximumMovement
			
			content(stretchedSize)
				.offset(y: movementOffset)
				.frame(width: stretchedSize.width, height: stretchedSize.height)
				.frame(width: size.width, height: size.height)
				.clipped()
		}
		.containerRelativeFrame(usesFullWidth ? [.horizontal] : [])
	}
}
