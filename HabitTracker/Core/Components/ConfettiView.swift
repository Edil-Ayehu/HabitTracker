//
//  ConfettiView.swift
//  HabitTracker
//

import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var rotation: Double
    var spin: Double
    var color: Color
    var size: Double
    var shape: ShapeType
    var opacity: Double = 1.0
    
    enum ShapeType: CaseIterable {
        case circle
        case square
        case star
    }
}

struct ConfettiView: View {
    
    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?
    @State private var opacity: Double = 1.0
    
    var duration: Double = 3.5
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for particle in particles {
                        var pContext = context
                        pContext.opacity = particle.opacity * opacity
                        pContext.translateBy(x: particle.x, y: particle.y)
                        pContext.rotate(by: .degrees(particle.rotation))
                        
                        let rect = CGRect(x: -particle.size / 2, y: -particle.size / 2, width: particle.size, height: particle.size)
                        
                        switch particle.shape {
                        case .circle:
                            pContext.fill(Path(ellipseIn: rect), with: .color(particle.color))
                        case .square:
                            pContext.fill(Path(rect), with: .color(particle.color))
                        case .star:
                            pContext.fill(starPath(in: rect), with: .color(particle.color))
                        }
                    }
                }
            }
            .onAppear {
                spawnParticles(in: geo.size)
                startAnimationLoop(in: geo.size)
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
        .opacity(opacity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    private func spawnParticles(in size: CGSize) {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint]
        var newParticles: [ConfettiParticle] = []
        
        for _ in 0..<75 {
            let p = ConfettiParticle(
                x: Double.random(in: 0...size.width),
                y: Double.random(in: -100...(-10)),
                vx: Double.random(in: -3.0...3.0),
                vy: Double.random(in: 3.0...9.0),
                rotation: Double.random(in: 0...360),
                spin: Double.random(in: -10...10),
                color: colors.randomElement() ?? .yellow,
                size: Double.random(in: 8...16),
                shape: ConfettiParticle.ShapeType.allCases.randomElement() ?? .square
            )
            newParticles.append(p)
        }
        particles = newParticles
    }
    
    private func startAnimationLoop(in size: CGSize) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            for i in particles.indices {
                particles[i].x += particles[i].vx
                particles[i].y += particles[i].vy
                particles[i].vy += 0.15 // Gravity
                particles[i].rotation += particles[i].spin
                
                if particles[i].y > size.height {
                    particles[i].opacity = max(0, particles[i].opacity - 0.05)
                }
            }
        }
        
        withAnimation(.easeOut(duration: 1.0).delay(duration - 1.0)) {
            opacity = 0.0
        }
    }
    
    private func starPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.width / 2
        let pointsOnStar = 5
        let angle = .pi / Double(pointsOnStar)
        
        for i in 0..<(pointsOnStar * 2) {
            let radius = i % 2 == 0 ? r : r * 0.4
            let x = center.x + CGFloat(cos(Double(i) * angle - .pi / 2)) * radius
            let y = center.y + CGFloat(sin(Double(i) * angle - .pi / 2)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
