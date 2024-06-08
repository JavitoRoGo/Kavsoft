//
//  HackerTextView.swift
//  HackerTextEffect
//
//  Created by Javier Rodríguez Gómez on 8/6/24.
//

import SwiftUI

struct HackerTextView: View {
	// Config
	var text: String
	var trigger: Bool
	var transition: ContentTransition = .interpolate
	var duration: CGFloat = 1.0
	var speed: CGFloat = 0.1
	// View properties
	@State private var animatedText = ""
	@State private var randomCharacters: [Character] = {
		let string = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-?/#$@!&*()="
		return Array(string)
	}()
	@State private var animationID = UUID().uuidString
	
    var body: some View {
        Text(animatedText)
			.fontDesign(.monospaced)
			.truncationMode(.tail)
		// when a character in the text view changes, the content transition applies a transition effect to the text view, such as a rolling text effect
			.contentTransition(transition)
			.animation(.easeInOut(duration: 0.1), value: animatedText)
			.onAppear {
				guard animatedText.isEmpty else { return }
				setRandomCharacters()
				animateText()
			}
			.customOnChange(value: trigger) { newValue in
				animateText()
			}
			.customOnChange(value: text) { newValue in
				animatedText = text
				animationID = UUID().uuidString
				setRandomCharacters()
				animateText()
			}
    }
	
	private func animateText() {
		// code for animating the text
		let currentID = animationID
		for index in text.indices {
			let delay = CGFloat.random(in: 0...duration)
			var timerDuration: CGFloat = 0
			
			let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
				if currentID != animationID {
					timer.invalidate()
				} else {
					timerDuration += speed
					if timerDuration >= delay {
						// So, each character in the text view will have a timer that will update the text character with a random character at a given speed, and when the estimated delay time is reached, the text character will be set to the real character, resulting in the hacker text effect
						if text.indices.contains(index) {
							let actualCharacter = text[index]
							replaceCharacter(at: index, character: actualCharacter)
						}
						
						timer.invalidate()
					} else {
						guard let randomCharacter = randomCharacters.randomElement() else { return }
						replaceCharacter(at: index, character: randomCharacter)
					}
				}
			}
			timer.fire()
		}
	}
	
	private func setRandomCharacters() {
		animatedText = text
		for index in animatedText.indices {
			guard let randomCharacter = randomCharacters.randomElement() else { return }
			replaceCharacter(at: index, character: randomCharacter)
		}
	}
	
	// Changes character at the given index
	func replaceCharacter(at index: String.Index, character: Character) {
		guard animatedText.indices.contains(index) else { return }
		let indexCharacter = String(animatedText[index])
		
		if indexCharacter.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
			animatedText.replaceSubrange(index...index, with: String(character))
		}
	}
}

#Preview {
    ContentView()
}


// Custom onChange modifier to support iOS 16 and later
fileprivate extension View {
	@ViewBuilder
	func customOnChange<T: Equatable>(value: T, result: @escaping (T) -> ()) -> some View {
		if #available(iOS 17, *) {
			self
				.onChange(of: value) { oldValue, newValue in
					result(newValue)
				}
		} else {
			self
				.onChange(of: value, perform: { value in
					result(value)
				})
		}
	}
}
