//
//  Hero.swift
//  HeroEffect
//
//  Created by Javier Rodríguez Gómez on 4/2/24.
//

import SwiftUI

// Hero wrapper
// This wrapper will create the necessary overlay window for handling hero animations, and the app entry point must be wrapped with this
struct HeroWrapper<Content: View>: View {
	@ViewBuilder var content: Content
	
	// View properties
	@Environment(\.scenePhase) private var scene
	@State private var overlayWindow: PassthroughWindow?
	@StateObject private var heroModel: HeroModel = .init()
	
    var body: some View {
        content
			.customOnChange(value: scene) { newValue in
				if newValue == .active { }
			}
			.environmentObject(heroModel)
    }
	
	// Adding overlay window
	func addOverlayWindow() {
		for scene in UIApplication.shared.connectedScenes {
			// Finding active scene
			// the reason for manually finding the active scene is so that this effect can support iPadOS with multiple window sessions
			if let windowScene = scene as? UIWindowScene,
			   scene.activationState == .foregroundActive,
			   overlayWindow == nil {
				let window = PassthroughWindow(windowScene: windowScene)
				window.backgroundColor = .clear
				window.isUserInteractionEnabled = false
				window.isHidden = false
				let rootController = UIHostingController(rootView: HeroLayerView().environmentObject(heroModel))
				rootController.view.frame = windowScene.screen.bounds
				rootController.view.backgroundColor = .clear
				
				window.rootViewController = rootController
				
				self.overlayWindow = window
			}
		}
		
		if overlayWindow == nil {
			print("NO WINDOW SCENE FOUND")
		}
	}
}

struct SourceView<Content: View>: View {
	let id: String
	@ViewBuilder var content: Content
	@EnvironmentObject private var heroModel: HeroModel
	
	var body: some View {
		content
			.opacity(opacity)
			.anchorPreference(key: AnchorKey.self, value: .bounds, transform: { anchor in
				if let index, heroModel.info[index].isActive {
					return [id: anchor]
				}
				return [:]
			})
			.onPreferenceChange(AnchorKey.self, perform: { value in
				if let index, heroModel.info[index].isActive, heroModel.info[index].sourceAnchor == nil {
					heroModel.info[index].sourceAnchor = value[id]
				}
			})
	}
	
	var index: Int? {
		if let index = heroModel.info.firstIndex(where: { $0.infoID == id }) {
			return index
		}
		return nil
	}
	
	var opacity: CGFloat {
		if let index {
			return heroModel.info[index].isActive ? 0 : 1
		}
		return 1
	}
}

struct DestinationView<Content: View>: View {
	var id: String
	@ViewBuilder var content: Content
	@EnvironmentObject private var heroModel: HeroModel
	
	var body: some View {
		content
			.opacity(opacity)
			.anchorPreference(key: AnchorKey.self, value: .bounds, transform: { anchor in
				if let index, heroModel.info[index].isActive {
					return ["\(id)DESTINATION": anchor]
				}
				return [:]
			})
			.onPreferenceChange(AnchorKey.self, perform: { value in
				if let index, heroModel.info[index].isActive {
					heroModel.info[index].destinationAnchor = value["\(id)DESTINATION"]
				}
			})
	}
	
	var index: Int? {
		if let index = heroModel.info.firstIndex(where: { $0.infoID == id }) {
			return index
		}
		return nil
	}
	
	var opacity: CGFloat {
		if let index {
			return heroModel.info[index].isActive ? (heroModel.info[index].hideView ? 0 : 1) : 1
		}
		return 1
	}
}

extension View {
	@ViewBuilder
	func heroLayer<Content: View>(
		id: String,
		animate: Binding<Bool>,
		sourceCornerRadius: CGFloat = 0,
		destinationCornerRadius: CGFloat = 0,
		@ViewBuilder content: @escaping () -> Content,
		completion: @escaping (Bool) -> ()
	) -> some View {
		self
			.modifier(
				HeroLayerViewModifier(
					id: id,
					animate: animate,
					sourceCornerRadius: sourceCornerRadius,
					destinationCornerRadius: destinationCornerRadius,
					layer: content,
					completion: completion
				)
			)
	}
}

fileprivate struct HeroLayerViewModifier<Layer: View>: ViewModifier {
	// the reason for the usage of ViewModifier here is to access the HeroModel environment object for passing the necessary details for source and destination views
	let id: String
	@Binding var animate: Bool
	var sourceCornerRadius: CGFloat
	var destinationCornerRadius: CGFloat
	@ViewBuilder var layer: Layer
	var completion: (Bool) -> ()
	
	// Hero model
	@EnvironmentObject private var heroModel: HeroModel
	
	func body(content: Content) -> some View {
		content
			.onAppear {
				if !heroModel.info.contains(where: { $0.infoID == id }) {
					// whenever a hero layer modifier is created, we will be creating a heroInfo for that id and saving all the given properties so that source and destination views can access the heroInfo information with the same id
					heroModel.info.append(.init(id: id))
				}
			}
			.customOnChange(value: animate) { newValue in
				// let's now animate the view and pass it all the properties the LayerView needs
				if let index = heroModel.info.firstIndex(where: { $0.infoID == id }){
					// Setting up all the necessary properties for the animation
					heroModel.info[index].isActive = true
					heroModel.info[index].layerView = AnyView(layer)
					heroModel.info[index].sCornerRadius = sourceCornerRadius
					heroModel.info[index].dCornerRadius = destinationCornerRadius
					heroModel.info[index].completion = completion
					
					if newValue {
						// the reason for the delay is for the destination view to get loaded into the screen for reading its anchor values
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
							withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
								heroModel.info[index].animateView = true
							}
						}
					} else {
						heroModel.info[index].hideView = false
						withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
							heroModel.info[index].animateView = false
						}
					}
				}
			}
	}
}

fileprivate struct HeroLayerView: View {
	@EnvironmentObject private var heroModel: HeroModel
	
	var body: some View {
		GeometryReader { proxy in
			ForEach($heroModel.info) { $info in
				ZStack {
					if let sourceAnchor = info.sourceAnchor,
					   let destinationAnchor = info.destinationAnchor,
					   let layerView = info.layerView,
					   !info.hideView {
						// Retreving bounds data from the anchor values
						let sRect = proxy[sourceAnchor]
						let dRect = proxy[destinationAnchor]
						let animateView = info.animateView
						
						let size = CGSize(
							width: animateView ? dRect.size.width : sRect.size.width,
							height: animateView ? dRect.size.height : sRect.size.height
						)
						
						// Position
						let offset = CGSize(
							width: animateView ? dRect.minX : sRect.minX,
							height: animateView ? dRect.minY : sRect.minY
						)
						
						layerView
							.frame(width: size.width, height: size.height)
							.clipShape(.rect(cornerRadius: animateView ? info.dCornerRadius : info.sCornerRadius))
							.offset(offset)
							.transition(.identity)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
					}
				}
				.customOnChange(value: info.animateView) { newValue in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
						if !newValue {
							// Resetting all data once the view goes back to it's source state
							info.isActive = false
							info.layerView = nil
							info.sourceAnchor = nil
							info.destinationAnchor = nil
							info.sCornerRadius = 0
							info.dCornerRadius = 0
							
							info.completion(false)
						} else {
							info.hideView = true
							info.completion(true)
						}
					}
				}
			}
		}
	}
}

// Environment object
fileprivate class HeroModel: ObservableObject {
	// This environment object will be shared by source, destination, and layer view for handling hero effects
	@Published var info: [HeroInfo] = []
}

// Individual hero animation view info
// this will contain all the necessary information about each hero effect
fileprivate struct HeroInfo: Identifiable {
	private(set) var id: UUID = .init()
	private(set) var infoID: String
	var isActive: Bool = false
	var layerView: AnyView?
	var animateView = false
	var hideView = false
	var sourceAnchor: Anchor<CGRect>?
	var destinationAnchor: Anchor<CGRect>?
	var sCornerRadius: CGFloat = 0
	var dCornerRadius: CGFloat = 0
	var completion: (Bool) -> () = { _ in }
	
	init(id: String) {
		self.infoID = id
	}
}

fileprivate struct AnchorKey: PreferenceKey {
	static var defaultValue: [String: Anchor<CGRect>] = [:]
	static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
		// This is used to retrieve the size and position information about the SwiftUI view, and with the help of that, we can implement the hero effect
		value.merge(nextValue()) { $1 }
	}
}

// This project supports iOS 16, thus creating an extension for onChange
extension View {
	@ViewBuilder
	func customOnChange<Value: Equatable>(value: Value, completion: @escaping (Value) -> ()) -> some View {
		if #available(iOS 17, *) {
			self
				.onChange(of: value) { oldValue, newValue in
					completion(newValue)
				}
		} else {
			self
				.onChange(of: value, perform: { value in
					completion(value)
				})
		}
	}
}

fileprivate class PassthroughWindow: UIWindow {
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		guard let view = super.hitTest(point, with: event) else { return nil }
		return rootViewController?.view == nil ? view : nil
	}
}
