//
//  Home.swift
//  VerticalCircularCarrousel
//
//  Created by Javier Rodríguez Gómez on 2/6/24.
//

import SwiftUI

struct Home: View {
    var body: some View {
		GeometryReader {
			let size = $0.size
			
			ScrollView(.vertical) {
				LazyVStack(spacing: 0) {
					ForEach(cards) { card in
						CardView(card)
							.frame(width: 220, height: 150)
							.visualEffect { content, geometryProxy in
								content
									.offset(x: -150)
									.rotationEffect(.init(degrees: cardRotation(geometryProxy)), anchor: .trailing)
									.offset(x: 100, y: -geometryProxy.frame(in: .scrollView(axis: .vertical)).minY)
							}
							.frame(maxWidth: .infinity, alignment: .trailing)
					}
				}
				.scrollTargetLayout()
			}
			.safeAreaPadding(.vertical, (size.height * 0.5) - 75)
			.scrollIndicators(.hidden)
			.scrollTargetBehavior(.viewAligned(limitBehavior: .always))
			.background {
				Circle()
					.fill(.ultraThinMaterial)
					.frame(width: size.height, height: size.height)
					.offset(x: size.height / 2)
			}
		}
		.toolbar(.hidden, for: .navigationBar)
    }
	
	// Card View
	@ViewBuilder
	func CardView(_ card: Card) -> some View {
		ZStack {
			RoundedRectangle(cornerRadius: 25)
				.fill(card.color.gradient)
			
			VStack(alignment: .leading, spacing: 10) {
				Image(.launchImageDark)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 40)
				
				Spacer(minLength: 0)
				
				HStack(spacing: 0) {
					ForEach(0..<3, id: \.self) { _ in
						Text("****")
						Spacer(minLength: 0)
					}
					Text(card.number)
						.offset(y: -2)
				}
				.font(.callout)
				.fontWeight(.semibold)
				.foregroundStyle(.white)
				.padding(.bottom, 10)
				
				HStack {
					Text(card.name)
					Spacer(minLength: 0)
					Text(card.date)
				}
				.font(.caption.bold())
				.foregroundStyle(.white)
			}
			.padding(25)
		}
	}
	
	// Card rotation
	func cardRotation(_ proxy: GeometryProxy) -> CGFloat {
		let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
		let height = proxy.size.height
		
		let progress = minY / height
		// You can specify any angle value you desire, but I'm going with 50 degrees for each card to be turned when it isn't in the center
		let angleForEachCard: CGFloat = -50
		// This will snap the progress range of -1 to +1. We can change this value to show more than one card
		let cappedProgress = progress < 0 ? min(max(progress, -3), 0) : max(min(progress, 3), 0)
		
		return cappedProgress * angleForEachCard
	}
}

#Preview {
    ContentView()
}
