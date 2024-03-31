//
//  OrderStatus.swift
//  OrderStatus
//
//  Created by Javier Rodríguez Gómez on 30/3/24.
//

import WidgetKit
import SwiftUI

struct OrderStatus: Widget {
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: OrderAttributes.self) { context in
			// Live activity view
			// NOTE: Live activity max height = 220 pixels
			ZStack {
				RoundedRectangle(cornerRadius: 15, style: .continuous)
					.fill(.green.gradient)
				
				// Order Status UI
				VStack {
					HStack {
						Image(.logoExpanded)
							.resizable()
							.scaledToFit()
							.frame(width: 40, height: 40)
							.clipShape(.circle)
						Text("In store pickup")
							.foregroundStyle(.white.opacity(0.6))
							.frame(maxWidth: .infinity, alignment: .leading)
						HStack(spacing: -2) {
							ForEach(["Burger", "Shake"], id: \.self) { image in
								Image(image)
									.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(width: 30, height: 30)
									.background {
										Circle()
											.fill(.green)
											.padding(-2)
									}
									.background {
										Circle()
											.stroke(.white, lineWidth: 1.5)
											.padding(-2)
									}
							}
						}
					}
					
					HStack(alignment: .bottom, spacing: 0) {
						VStack(alignment: .leading, spacing: 4) {
							Text(message(status: context.state.status))
								.font(.title3)
								.foregroundStyle(.white)
							Text(subMessage(status: context.state.status))
								.font(.caption2)
								.foregroundStyle(.gray)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						HStack(alignment: .bottom, spacing: 0) {
							ForEach(Status.allCases, id: \.self) { type in
								Image(systemName: type.rawValue)
									.font(context.state.status == type ? .title2 : .body)
									.foregroundStyle(context.state.status == type ? .green : .white.opacity(0.7))
									.frame(width: context.state.status == type ? 45 : 32, height: context.state.status == type ? 45 : 32)
									.background {
										Circle()
											.fill(context.state.status == type ? .white : .green.opacity(0.5))
									}
								// bottom arrow to look like bubble
									.background(alignment: .bottom) {
										bottomArrow(status: context.state.status, type: type)
									}
									.frame(maxWidth: .infinity)
							}
						}
						.overlay(alignment: .bottom) {
							// Image size = 45 + trailing padding = 10
							// 55/2 = 27.5
							Rectangle()
								.fill(.white.opacity(0.6))
								.frame(height: 2)
								.offset(y: 12)
								.padding(.horizontal, 27.5)
						}
						.padding(.leading, 15)
						.padding(.trailing, -10)
						.frame(maxWidth: .infinity)
					}
					.frame(maxHeight: .infinity, alignment: .bottom)
					.padding(.bottom, 10)
				}
				.padding(15)
			}
		} dynamicIsland: { context in
			// Implementing dynamic island
			DynamicIsland {
				// Expanded when long pressed
				// Expanded region can be classified into four types
				// Leading, trailing, center, bottom
				
				// Explicación de cada una de las vistas: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities
				
				DynamicIslandExpandedRegion(.leading) {
					HStack {
						Image(.logoExpanded)
//						Image(systemName: "sun.max.fill")
							.resizable()
							.scaledToFit()
							.frame(width: 40, height: 40)
							.clipShape(.circle)
						Text("Store pickup")
							.font(.system(size: 14))
							.foregroundStyle(.white)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
				DynamicIslandExpandedRegion(.trailing) {
					HStack(spacing: -2) {
						ForEach(["Burger", "Shake"], id: \.self) { image in
							Image(image)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 25, height: 25)
								.background {
									Circle()
										.fill(.green)
										.padding(-2)
								}
								.background {
									Circle()
										.stroke(.white, lineWidth: 1.5)
										.padding(-2)
								}
						}
					}
				}
				DynamicIslandExpandedRegion(.center) {
					// This app don't require any content con center
				}
				DynamicIslandExpandedRegion(.bottom) {
					dynamicIslandStatusView(context: context)
				}
			} compactLeading: {
				// For demo purposes we're showing the logo
				Image(.logoCompact)
					.resizable()
					.scaledToFit()
					.clipShape(.circle)
					.padding(4)
					.offset(x: -4)
			} compactTrailing: {
				Image(systemName: context.state.status.rawValue)
					.font(.title3)
			} minimal: {
				// Minimal will be only visible when multiple activities are there
				Image(systemName: context.state.status.rawValue)
					.font(.caption2)
			}
		}
	}
	
	@ViewBuilder
	func bottomArrow(status: Status, type: Status) -> some View {
		Image(systemName: "arrowtriangle.down.fill")
			.font(.system(size: 15))
			.scaleEffect(x: 1.3)
			.offset(y: 6)
			.opacity(status == type ? 1 : 0)
			.foregroundStyle(.white)
			.overlay {
				Circle()
					.fill(.white)
					.frame(width: 5, height: 5)
					.offset(y: 13)
			}
	}
	
	// Main title
	func message(status: Status) -> String {
		switch status {
			case .received:
				"Order received"
			case .progress:
				"Order in progress"
			case .ready:
				"Order ready"
		}
	}
	
	func subMessage(status: Status) -> String {
		switch status {
			case .received:
				"We just received your order."
			case .progress:
				"We are handcrafting your order."
			case .ready:
				"We crafted your order."
		}
	}
	
	@ViewBuilder
	func dynamicIslandStatusView(context: ActivityViewContext<OrderAttributes>) -> some View {
		HStack(alignment: .bottom, spacing: 0) {
			VStack(alignment: .leading, spacing: 4) {
				Text(message(status: context.state.status))
					.font(.callout)
					.foregroundStyle(.white)
				Text(subMessage(status: context.state.status))
					.font(.caption2)
					.foregroundStyle(.gray)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.offset(x: 5, y: 5)
			
			HStack(alignment: .bottom, spacing: 0) {
				ForEach(Status.allCases, id: \.self) { type in
					Image(systemName: type.rawValue)
						.font(context.state.status == type ? .title2 : .body)
						.foregroundStyle(context.state.status == type ? .green : .white.opacity(0.7))
						.frame(width: context.state.status == type ? 35 : 26, height: context.state.status == type ? 35 : 26)
						.background {
							Circle()
								.fill(context.state.status == type ? .white : .green.opacity(0.5))
						}
					// bottom arrow to look like bubble
						.background(alignment: .bottom) {
							bottomArrow(status: context.state.status, type: type)
						}
						.frame(maxWidth: .infinity)
				}
			}
			.overlay(alignment: .bottom) {
				// Image size = 45 + trailing padding = 10
				// 55/2 = 27.5
				Rectangle()
					.fill(.white.opacity(0.6))
					.frame(height: 2)
					.offset(y: 12)
					.padding(.horizontal, 27.5)
			}
			.offset(y: -5)
		}
	}
}
