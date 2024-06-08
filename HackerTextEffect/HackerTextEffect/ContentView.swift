//
//  ContentView.swift
//  HackerTextEffect
//
//  Created by Javier Rodríguez Gómez on 8/6/24.
//

import SwiftUI

struct ContentView: View {
	@State private var trigger = false
	@State private var text = "Hello World!"
	
    var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HackerTextView(
				text: text,
				trigger: trigger,
				transition: .identity,
				speed: 0.01
			)
				.font(.largeTitle.bold())
				.lineLimit(2)
			
			Button {
				if text == "Hello World!" {
					text = "This is Hacker\nText View."
				} else if text == "This is Hacker\nText View." {
					text = "Made With SwiftUI\nBy @YoMismo"
				} else {
					text = "Hello World!"
				}
				trigger.toggle()
			} label: {
				Text("Trigger")
					.fontWeight(.semibold)
					.padding(.horizontal, 15)
					.padding(.vertical, 2)
			}
			.buttonStyle(.borderedProminent)
			.buttonBorderShape(.capsule)
			.frame(maxWidth: .infinity)
			.padding(.top, 30)
        }
        .padding(15)
		.frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}
