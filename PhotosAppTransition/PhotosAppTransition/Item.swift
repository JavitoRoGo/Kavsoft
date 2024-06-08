//
//  Item.swift
//  PhotosAppTransition
//
//  Created by Javier Rodríguez Gómez on 10/5/24.
//

import SwiftUI

struct Item: Identifiable,Hashable {
	var id: String = UUID().uuidString
	var title: String
	var image: UIImage?
	var previewImage: UIImage?
	var appeared: Bool = false
}

var sampleItems: [Item] = [
	.init(title: "Picture 1", image: UIImage(named: "alaDeAguila")),
	.init(title: "Picture 2", image: UIImage(named: "armadura")),
	.init(title: "Picture 3", image: UIImage(named: "cronos")),
	.init(title: "Picture 4", image: UIImage(named: "eclipse")),
	.init(title: "Picture 5", image: UIImage(named: "eco")),
	.init(title: "Picture 6", image: UIImage(named: "elementa")),
	.init(title: "Picture 7", image: UIImage(named: "fenix")),
	.init(title: "Picture 8", image: UIImage(named: "geo")),
	.init(title: "Picture 9", image: UIImage(named: "giro")),
	.init(title: "Picture 10", image: UIImage(named: "luzEstelar")),
	.init(title: "Picture 11", image: UIImage(named: "psique")),
	.init(title: "Picture 12", image: UIImage(named: "pulso")),
	.init(title: "Picture 13", image: UIImage(named: "reflejo")),
	.init(title: "Picture 14", image: UIImage(named: "roca")),
	.init(title: "Picture 15", image: UIImage(named: "sirena")),
	.init(title: "Picture 16", image: UIImage(named: "sombra")),
	.init(title: "Picture 17", image: UIImage(named: "telemente")),
	.init(title: "Picture 18", image: UIImage(named: "tempestad")),
	.init(title: "Picture 19", image: UIImage(named: "titan")),
	.init(title: "Picture 20", image: UIImage(named: "vortex"))
]
