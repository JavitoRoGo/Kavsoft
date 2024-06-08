//
//  FlipClockTextEffect.swift
//  FlipClockEffect
//
//  Created by Javier Rodríguez Gómez on 30/5/24.
//

import SwiftUI

struct FlipClockTextEffect: View {
	@Binding var value: Int
	// Config
	var size: CGSize
	var fontSize: CGFloat
	var cornerRadius: CGFloat
	var foreground: Color
	var background: Color
	var animationDuration: CGFloat = 0.8
	
	// View properties
	@State private var nextValue = 0
	@State private var currentValue = 0
	@State private var rotation: CGFloat = 0
	
    var body: some View {
		let halfHeight = size.height * 0.5
		ZStack {
			UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: cornerRadius)
				.fill(background.shadow(.inner(radius: 1)))
				.frame(height: halfHeight)
				.overlay(alignment: .top) {
					TextView(nextValue)
						.frame(width: size.width, height: size.height)
						.drawingGroup()
				}
				.clipped()
				.frame(maxHeight: .infinity, alignment: .top)
			
			UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: cornerRadius)
				.fill(background.shadow(.inner(radius: 1)))
				.frame(height: halfHeight)
				.modifier(
					RotationModifier(
						rotation: rotation,
						currentValue: currentValue,
						nextValue: nextValue,
						fontSize: fontSize,
						foreground: foreground,
						size: size
					)
				)
				.clipped()
				.rotation3DEffect(
					.degrees(rotation),
					axis: (x: 1.0, y: 0.0, z: 0.0),
					anchor: .bottom,
					anchorZ: 0,
					perspective: 0.4
				)
				.frame(maxHeight: .infinity, alignment: .top)
				.zIndex(10)
			
			UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, topTrailingRadius: 0)
				.fill(background.shadow(.inner(radius: 1)))
				.frame(height: halfHeight)
				.overlay(alignment: .bottom) {
					TextView(currentValue)
						.frame(width: size.width, height: size.height)
						.drawingGroup()
				}
				.clipped()
				.frame(maxHeight: .infinity, alignment: .bottom)
		}
		.frame(width: size.width, height: size.height)
		.onChange(of: value, initial: true) { oldValue, newValue in
			// So, if the value changes, I instantly update the next value so that the background view receives the updated value and triggers the animation that flips the view from old to new. Once the animation is finished, I will change the current value to the new value and reset the rotation to zero. By doing this, the view will animate whenever the value changes.
			// If a value is modified during the animation period, it will be updated automatically without interfering with the flip effect.
			currentValue = oldValue
			nextValue = newValue
			guard rotation == 0 else {
				currentValue = newValue
				return
			}
			guard oldValue != newValue else { return }
			withAnimation(.easeInOut(duration: animationDuration), completionCriteria: .logicallyComplete) {
				rotation = -180
			} completion: {
				rotation = 0
				currentValue = value
			}

		}
    }
	
	// Reusable view
	@ViewBuilder
	func TextView(_ value: Int) -> some View {
		Text("\(value)")
			.font(.system(size: fontSize).bold())
			.foregroundStyle(foreground)
			.lineLimit(1)
	}
}

#Preview {
    ContentView()
}

fileprivate struct RotationModifier: ViewModifier, Animatable {
	var rotation: CGFloat
	var currentValue: Int
	var nextValue: Int
	var fontSize: CGFloat
	var foreground: Color
	var size: CGSize
	
	var animatableData: CGFloat {
		get { rotation }
		set { rotation = newValue }
	}
	
	func body(content: Content) -> some View {
		content
			.overlay(alignment: .top) {
				Group {
					if -rotation > 90 {
						Text("\(nextValue)")
							.font(.system(size: fontSize).bold())
							.foregroundStyle(foreground)
						// to obtain the correct orientation, we must flip the view because it has been rotated
							.scaleEffect(x: 1, y: -1)
							.transition(.identity)
							.lineLimit(1)
					} else {
						Text("\(currentValue)")
							.font(.system(size: fontSize).bold())
							.foregroundStyle(foreground)
							.scaleEffect(x: 1, y: 1)
							.transition(.identity)
							.lineLimit(1)
					}
				}
				.frame(width: size.width, height: size.height)
				.drawingGroup()
			}
	}
}
