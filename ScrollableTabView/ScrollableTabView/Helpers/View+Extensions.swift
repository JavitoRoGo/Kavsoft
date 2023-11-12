//
//  View+Extensions.swift
//  ScrollableTabView
//
//  Created by Javier Rodríguez Gómez on 11/11/23.
//

import SwiftUI

// Offset Key
struct OffsetKey: PreferenceKey {
	static var defaultValue: CGFloat = .zero
	
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}

extension View {
	@ViewBuilder
	func offsetX(completion: @escaping (CGFloat) -> ()) -> some View {
		self
			.overlay {
				GeometryReader {
					let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
					
					Color.clear
						.preference(key: OffsetKey.self, value: minX)
						.onPreferenceChange(OffsetKey.self, perform: completion)
				}
			}
	}
	
	// Tab bar masking
	@ViewBuilder
	func tabMask(_ tabProgress: CGFloat) -> some View {
		ZStack {
			self
				.foregroundStyle(.gray)
			
			self
				.symbolVariant(.fill)
				.mask {
					GeometryReader {
						let size = $0.size
						let capsuleWidth = size.width / CGFloat(Tab.allCases.count)
						Capsule()
							.frame(width: capsuleWidth)
							.offset(x: tabProgress * (size.width - capsuleWidth))
					}
				}
		}
	}
}


#Preview {
	ContentView()
}
