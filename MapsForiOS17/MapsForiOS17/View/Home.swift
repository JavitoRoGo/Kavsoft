//
//  Home.swift
//  MapsForiOS17
//
//  Created by Javier Rodríguez Gómez on 26/9/23.
//

import MapKit
import SwiftUI

struct Home: View {
	// Map properties
	@State private var cameraPosition: MapCameraPosition = .region(.myRegion)
	@State private var mapSelection: MKMapItem?
	@Namespace private var locationSpace
	@State private var viewingRegion: MKCoordinateRegion?
	
	// Search properties
	@State private var searchText = ""
	@State private var showSearch = false
	@State private var searchResults: [MKMapItem] = []
	
	// Map selection detail properties
	@State private var showDetails = false
	@State private var lookAroundScene: MKLookAroundScene?
	
	// Route properties
	@State private var routeDisplaying = false
	@State private var route: MKRoute?
	@State private var routeDestination: MKMapItem?
	
	var body: some View {
		NavigationStack {
			Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace) {
				/// Map annotations
				/// We can annotate in map in two ways: one is as a marker with a default balloon shape with custom icons in it
				/// and another is as an annotaation view, which will allow us to define our own SwiftUI view as an annotation view
				/// Se incluyen varios ejemplos para ver las posibilidades, y por eso están comentados
				//			Marker("Apple Park", coordinate: .myLocation)
				//				.annotationTitles(.hidden)
				//			Marker("Apple Park", systemImage: "applelogo", coordinate: .myLocation)
				//				.tint(.black)
				Annotation("Apple Park", coordinate: .myLocation) {
					ZStack {
						Image(systemName: "applelogo")
						Image(systemName: "square")
							.font(.title)
					}
				}
				.annotationTitles(.visible)
				
				/// Simply display annotations as Marker, as we seen before
				ForEach(searchResults, id: \.self) { mapItem in
					// Hiding all other markers, except destination one
					if routeDisplaying {
						if mapItem == routeDestination {
							let placemark = mapItem.placemark
							Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
								.tint(.blue)
						}
					} else {
						let placemark = mapItem.placemark
						Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
							.tint(.blue)
					}
				}
				
				/// Display route using polyline
				if let route {
					MapPolyline(route.polyline)
					// Applying bigger stroke
						.stroke(.blue, lineWidth: 7)
				}
				
				/// To show user current location
				/// When we have access to phone location, this will show the current user's location on the map
				UserAnnotation()
			}
			//		.mapControls {
			//			/// Compass, 3D maps, user location, pitch, scale, etc.
			//			MapCompass()
			//			MapUserLocationButton()
			//			MapPitchToggle()
			//		}
			// Comentado lo anterior para no mezclarlo con lo siguiente
			// With the help of the mapStyle modifier we can easily change the style, such as standard, hybrid and imagery
			.onMapCameraChange { ctx in
				// para obtener la nueva region cuando movemos el mapa
				viewingRegion = ctx.region
			}
			.overlay(alignment: .bottomTrailing) {
				VStack(spacing: 15) {
					MapCompass(scope: locationSpace)
					MapPitchToggle(scope: locationSpace)
					MapUserLocationButton(scope: locationSpace)
				}
				.buttonBorderShape(.circle)
				.padding()
			}
			.mapScope(locationSpace)
			.navigationTitle("Map")
			.navigationBarTitleDisplayMode(.inline)
			// Search bar
			.searchable(text: $searchText, isPresented: $showSearch)
			// Showing translucent toolbar
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			// When route displaying hiding top and bottom bar
			.toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
			.sheet(isPresented: $showDetails, content: {
				MapDetails()
					.presentationDetents([.height(300)])
					.presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
					.presentationCornerRadius(25)
					.interactiveDismissDisabled(true)
			})
			.safeAreaInset(edge: .bottom) {
				// This will appear with the "End Route" button when the routes are displayed
				if routeDisplaying {
					Button("End Route") {
						// Closing the route and setting the selection
						withAnimation(.snappy) {
							routeDisplaying = false
							showDetails = true
							mapSelection = routeDestination
							routeDestination = nil
							route = nil
							cameraPosition = .region(.myRegion)
						}
					}
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 12)
					.background(.red.gradient, in: .rect(cornerRadius: 15))
					.padding()
					.background(.ultraThinMaterial)
				}
			}
		}
		.onSubmit(of: .search) {
			Task {
				guard !searchText.isEmpty else { return }
				await searchPlaces()
			}
		}
		.onChange(of: showSearch, initial: false) {
			if !showSearch {
				// Clearing search results
				searchResults.removeAll(keepingCapacity: false)
				showDetails = false
				// Zooming out to user region when search cancelled
				withAnimation(.snappy) {
					cameraPosition = .region(viewingRegion ?? .myRegion)
				}
			}
		}
		.onChange(of: mapSelection) { oldValue, newValue in
			// Displaying details about the selected place: whenever we tap an annotation on the map, the bottom sheet will display the details of the tapped annotation
			showDetails = newValue != nil
			// Fetching look around preview, when ever selection changes
			fetchLookAroundPreview()
		}
	}
	
	/// Search places
	func searchPlaces() async {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchText
		request.region = viewingRegion ?? .myRegion
		
		let results = try? await MKLocalSearch(request: request).start()
		searchResults = results?.mapItems ?? []
	}
	
	/// Map details view
	@ViewBuilder
	func MapDetails() -> some View {
		VStack(spacing: 15) {
			ZStack {
				// New look around API
				if lookAroundScene == nil {
					// New empty view API, used when there is no content to present
					ContentUnavailableView("No preview available", systemImage: "eye.slash")
				} else {
					LookAroundPreview(scene: $lookAroundScene)
				}
			}
			.frame(height: 200)
			.clipShape(.rect(cornerRadius: 15))
			// Close button
			.overlay(alignment: .topTrailing) {
				Button(action: {
					// Closing view
					showDetails = false
					withAnimation(.snappy) {
						mapSelection = nil
					}
				}, label: {
					Image(systemName: "xmark.circle.fill")
						.font(.title)
						.foregroundStyle(.black)
						.background(.white, in: .circle)
				})
				.padding(10)
			}
			
			// Direction's button
			Button("Get directions", action: fetchRoute)
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 12)
				.background(.blue.gradient, in: .rect(cornerRadius: 15))
		}
		.padding(15)
	}
	
	/// Fetching location preview
	func fetchLookAroundPreview() {
		if let mapSelection {
			// Clearing old one
			lookAroundScene = nil
			Task {
				let request = MKLookAroundSceneRequest(mapItem: mapSelection)
				lookAroundScene = try? await request.scene
			}
		}
	}
	
	/// Fetching route
	func fetchRoute() {
		if let mapSelection {
			let request = MKDirections.Request()
			request.source = .init(placemark: .init(coordinate: .myLocation))
			// Use user's location instead
			request.destination = mapSelection
			
			Task {
				let result = try? await MKDirections(request: request).calculate()
				route = result?.routes.first
				// Saving route destination
				routeDestination = mapSelection
				
				withAnimation(.snappy) {
					routeDisplaying = true
					showDetails = false
					// Zooming route
					if let boundingRect = route?.polyline.boundingMapRect {
						cameraPosition = .rect(boundingRect)
					}
				}
			}
		}
	}
}

#Preview {
    ContentView()
}


/// Location Data
/// Using static Apple Park as location, but can be changed to user's live location

extension CLLocationCoordinate2D {
	static var myLocation: CLLocationCoordinate2D {
		return .init(latitude: 37.3346, longitude: -122.0090)
	}
}

extension MKCoordinateRegion {
	static var myRegion: MKCoordinateRegion {
		return .init(center: .myLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
	}
}
