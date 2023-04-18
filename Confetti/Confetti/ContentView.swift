//
//  ContentView.swift
//  Confetti
//
//  Created by Javier Rodríguez Gómez on 1/6/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home: View {
    @State var wish = false
    @State var finishWish = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Image("cake")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: getRect().width / 1.8)
                
                Text("Happy Birthday\nYourNameHere")
                    .font(.system(size: 35))
                // Letter spacing...
                    .kerning(3)
                // Line spacing...
                    .lineSpacing(10)
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)
                
                Button {
                    doAnimation()
                } label: {
                    Text("Wish")
                        .kerning(2)
                        .font(.system(size: 20))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 50)
                        .background(.purple)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                }
                .disabled(wish)
            }
            
            EmitterView()
                .scaleEffect(wish ? 1 : 0, anchor: .top)
                .opacity(wish && !finishWish ? 1 : 0)
            // Moving from center effect...
                .offset(y: wish ? 0 : getRect().height / 2)
                .ignoresSafeArea()
        }
    }
    
    func doAnimation() {
        withAnimation(.spring()) {
            wish = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 1.5)) {
                finishWish = true
            }
            // Resetting after wish finished...
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                finishWish = false
                wish = false
            }
        }
    }
}


// Global function for getting size...

func getRect() -> CGRect {
    return UIScreen.main.bounds
}


// Emit Particle view...
// AKA CAEmmiterLayer from UIKit...

struct EmitterView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        //Emitter layer...
        let emitterLayer = CAEmitterLayer()
        // Since we need top to down animation...
        // Just change and play with properties...
        emitterLayer.emitterShape = .line
        emitterLayer.emitterCells = createEmitterCells()
        
        // Size and position...
        emitterLayer.emitterSize = CGSize(width: getRect().width, height: 1)
        emitterLayer.emitterPosition = CGPoint(x: getRect().width / 2, y: 0)
        
        view.layer.addSublayer(emitterLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func createEmitterCells() -> [CAEmitterCell] {
        // Multiple different shaped emitters...
        var emitterCells: [CAEmitterCell] = []
        for index in 1...12 {
            let cell = CAEmitterCell()
            
            // Import white particle images...
            cell.contents = UIImage(named: getImage(index: index))?.cgImage
            // Other wise color wont work...
            cell.color = getColor().cgColor
            // New particle creation
            cell.birthRate = 4.5
            // Particle existence
            cell.lifetime = 20
            // Velocity
            cell.velocity = 120
            // Scale
            cell.scale = 0.25
            cell.scaleRange = 0.3
            cell.emissionLongitude = .pi
            cell.emissionRange = 0.5
            cell.spin = 3.5
            cell.spinRange = 1
            // Acceleration
            cell.yAcceleration = 40
            
            emitterCells.append(cell)
        }
        
        return emitterCells
    }
    
    func getColor() -> UIColor {
        let colors: [UIColor] = [.systemPink, .systemGreen, .systemRed, .systemOrange, .systemPurple]
        return colors.randomElement()!
    }
    
    func getImage(index: Int) -> String {
        if index < 4 {
            return "square.fill"
        } else if index > 5 && index <= 8 {
            return "circle.fill"
        } else {
            return "triangle.fill"
        }
    }
}
