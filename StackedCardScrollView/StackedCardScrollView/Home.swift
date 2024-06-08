//
//  Home.swift
//  StackedCardScrollView
//
//  Created by Javier Rodríguez Gómez on 16/5/24.
//

import SwiftUI

struct Home: View {
    var body: some View {
		VStack {
			StackedCards(items: items, stackedDisplayCount: 2, itemHeight: 70) { item in
				CardView(item)
			}
			.padding(.bottom, 20)
			
			BottomActionBar()
		}
		.padding(20)
    }
	
	// Card view
	@ViewBuilder
	func CardView(_ item: Item) -> some View {
		HStack(spacing: 22) {
			Image(systemName: item.title)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: 30, height: 30)
			VStack(alignment: .leading, spacing: 4) {
				Text(item.logo)
					.font(.callout)
					.fontWeight(.bold)
				Text(item.description)
					.font(.caption)
					.lineLimit(1)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(10)
		.frame(maxHeight: .infinity)
		.background(.ultraThinMaterial)
		.clipShape(.rect(cornerRadius: 20))
	}
	
	// Bottom action bar
	@ViewBuilder
	func BottomActionBar() -> some View {
		HStack {
			Button {} label: {
				Image(systemName: "flashlight.off.fill")
					.font(.title3)
					.frame(width: 35, height: 35)
			}
			.buttonStyle(.borderedProminent)
			.tint(.white.opacity(0.2))
			.buttonBorderShape(.circle)
			
			Spacer(minLength: 0)
			
			Button {} label: {
				Image(systemName: "camera.fill")
					.font(.title3)
					.frame(width: 35, height: 35)
			}
			.buttonStyle(.borderedProminent)
			.tint(.white.opacity(0.2))
			.buttonBorderShape(.circle)
		}
	}
}

#Preview {
    ContentView()
}
