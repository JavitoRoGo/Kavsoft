//
//  ContentView.swift
//  DraggablePiniOS17
//
//  Created by Javier Rodríguez Gómez on 16/2/24.
//

import MapKit
import SwiftUI

struct ContentView: View {
	// View properties
	@State private var camera: MapCameraPosition = .region(.init(center: .applePark, span: .initialSpan))
	@State private var coordinate: CLLocationCoordinate2D = .applePark
	@State private var mapSpan: MKCoordinateSpan = .initialSpan
	@State private var annotationTitle = ""
	
	@State private var updatesCamera = false
	@State private var displaysTitle = false
	
    var body: some View {
		MapReader { proxy in
			Map(position: $camera) {
				// Custom annotation view
				Annotation(displaysTitle ? annotationTitle : "", coordinate: coordinate) {
					DraggablePin(proxy: proxy, coordinate: $coordinate) { coordinate in
						findCoordinateName()
						guard updatesCamera else { return }
						
						// Optional: Updating camera position when coordinate changes
						// Consider when a map is zoomed in or out and we don't want to update the camera with the default zooming. To solve that, we want to know about the coordinate span of the region. In iOS 17, MapKit has a new modifier that will let us know when the map regio is changed and with the help of that, we can extract the current coordinate region span
						let newRegion = MKCoordinateRegion(
							center: coordinate,
							span: mapSpan
						)
						
						withAnimation(.smooth) {
							camera = .region(newRegion)
						}
					}
				}
			}
			.onMapCameraChange(frequency: .continuous) { ctx in
				mapSpan = ctx.region.span
			}
			.safeAreaInset(edge: .bottom, content: {
				HStack(spacing: 0) {
					Toggle("Updates Camera", isOn: $updatesCamera)
						.frame(width: 180)
					
					Spacer(minLength: 0)
					
					Toggle("Displays Title", isOn: $displaysTitle)
						.frame(width: 150)
				}
				.textScale(.secondary)
				.padding(15)
				.background(.ultraThinMaterial)
			})
			.onAppear(perform: findCoordinateName)
		}
    }
	
	// Finds name for current location coordinates
	func findCoordinateName() {
		annotationTitle = ""
		Task {
			let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let geoDecoder = CLGeocoder()
			if let name = try? await geoDecoder.reverseGeocodeLocation(location).first?.name {
				annotationTitle = name
			}
		}
	}
}

#Preview {
    ContentView()
}


// Custom draggable pin annotation
struct DraggablePin: View {
	var tint: Color = .red
	var proxy: MapProxy
	@Binding var coordinate: CLLocationCoordinate2D
	var onCoordinateChange: (CLLocationCoordinate2D) -> ()
	// View properties
	@State private var isActive = false
	@State private var translation: CGSize = .zero
	
	var body: some View {
		GeometryReader {
			let frame = $0.frame(in: .global)
			
			Image(systemName: "mappin")
				.font(.title)
				.foregroundStyle(tint.gradient)
				.animation(.snappy, body: { content in
					content
					// Scaling on Active
						.scaleEffect(isActive ? 1.3 : 1, anchor: .bottom)
				})
				.frame(width: frame.width, height: frame.height)
			// Directly updating the annotation coordinates will result in a break of the gesture.
			// Instead, I'm going to locally move the view while the gesture is active using the offset modifier and update the coordinates once the gesture is finished dragging
				.onChange(of: isActive, initial: false) { oldValue, newValue in
					let position = CGPoint(x: frame.midX, y: frame.midY)
					// Converting Position into location coordinate using Map proxy
					if let coordinate = proxy.convert(position, from: .global), !newValue {
						// Updating coordinate based on translation and resetting translation to zero
						self.coordinate = coordinate
						translation = .zero
						onCoordinateChange(coordinate)
					}
				}
		}
		.frame(width: 30, height: 30)
		.contentShape(.rect)
		.offset(translation)
		.gesture(
			LongPressGesture(minimumDuration: 0.15)
				.onEnded {
					isActive = $0
				}
				.simultaneously(with:
					DragGesture(minimumDistance: 0)
						.onChanged { value in
							if isActive { translation = value.translation }
						}
						.onEnded { value in
							if isActive { isActive = false }
						}
					)
		)
	}
}

// Static values
extension MKCoordinateSpan {
	static var initialSpan: MKCoordinateSpan {
		.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
	}
}

extension CLLocationCoordinate2D {
	static var applePark: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: 37.334606, longitude: -122.0091102)
	}
}
