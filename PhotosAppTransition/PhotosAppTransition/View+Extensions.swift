//
//  View+Extensions.swift
//  PhotosAppTransition
//
//  Created by Javier Rodríguez Gómez on 11/5/24.
//

import SwiftUI

extension View {
	// This modifier will extract the item0s position in the scrollview as well as the scrollview boundaries values, which we can then use to determine whether the item is visible or not
	@ViewBuilder
	func didFrameChange(result: @escaping (CGRect, CGRect) -> ()) -> some View {
		self
			.overlay {
				GeometryReader {
					let frame = $0.frame(in: .scrollView(axis: .vertical))
					let bounds = $0.bounds(of: .scrollView(axis: .vertical)) ?? .zero
					
					Color.clear
						.preference(key: FrameKey.self, value: .init(frame: frame, bounds: bounds))
						.onPreferenceChange(FrameKey.self, perform: { value in
							result(value.frame, value.bounds)
						})
				}
			}
	}
}

struct ViewFrame: Equatable {
	var frame: CGRect = .zero
	var bounds: CGRect = .zero
}

struct FrameKey: PreferenceKey {
	static var defaultValue: ViewFrame = .init()
	static func reduce(value: inout ViewFrame, nextValue: () -> ViewFrame) {
		value = nextValue()
	}
}
