//
//  StackedCards.swift
//  StackedCardScrollView
//
//  Created by Javier Rodríguez Gómez on 16/5/24.
//

import SwiftUI

struct StackedCards<Content: View, Data: RandomAccessCollection>: View where Data.Element: Identifiable {
	var items: Data
	var stackedDisplayCount = 2 // this represents the number of extra cards that will be displayed following the active card view
	var opacityDisplayCount = 2
	var spacing: CGFloat = 5
	var itemHeight: CGFloat
	@ViewBuilder var content: (Data.Element) -> Content
	
    var body: some View {
		GeometryReader {
			let size = $0.size
			let topPadding = size.height - itemHeight
			
			ScrollView {
				VStack(spacing: spacing) {
					ForEach(items) { item in
						content(item)
							.frame(height: itemHeight)
						// aquí está la magia
							.visualEffect { content, geometryProxy in
								content
									.opacity(opacity(geometryProxy))
									.scaleEffect(scale(geometryProxy), anchor: .bottom)
									.offset(y: offset(geometryProxy))
							}
							.zIndex(zIndex(item))
					}
				}
				.scrollTargetLayout()
			}
			.scrollIndicators(.hidden)
			.scrollTargetBehavior(.viewAligned(limitBehavior: .always))
			.safeAreaPadding(.top, topPadding)
		}
    }
	
	// ZIndex to reverse the stack
	func zIndex(_ item: Data.Element) -> Double {
		if let index = items.firstIndex(where: { $0.id == item.id }) as? Int {
			return Double(items.count) - Double(index)
		}
		return 0
	}
	
	// Offset & scaling values for each item to make it look like a stack
	func offset(_ proxy: GeometryProxy) -> CGFloat {
		let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
		let progress = minY / itemHeight
		let maxOffset = CGFloat(stackedDisplayCount) * offsetForEachItem
		let offset = max(min(progress * offsetForEachItem, maxOffset), 0)
		return minY < 0 ? 0 : -minY + offset
	}
	
	func scale(_ proxy: GeometryProxy) -> CGFloat {
		let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
		let progress = minY / itemHeight
		let maxScale = CGFloat(stackedDisplayCount) * scaleForEachItem
		let scale = max(min(progress * scaleForEachItem, maxScale), 0)
		return 1 - scale
	}
	
	func opacity(_ proxy: GeometryProxy) -> CGFloat {
		let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
		let progress = minY / itemHeight
		let opacityForItem = 1 / CGFloat(opacityDisplayCount + 1)
		
		let maxOpacity = CGFloat(opacityForItem) * CGFloat(opacityDisplayCount + 1)
		let opacity = max(min(progress * opacityForItem, maxOpacity), 0)
		return progress < CGFloat(opacityDisplayCount + 1) ? 1 - opacity : 0
	}
	
	var offsetForEachItem: CGFloat {
		8
	}
	
	var scaleForEachItem: CGFloat {
		0.08
	}
}

#Preview {
    ContentView()
}
