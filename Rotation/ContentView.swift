//
//  ContentView.swift
//  Rotation
//
//  Created by Cornelis van der Bent on 12/10/2019.
//  Copyright © 2019 Meaning Matters. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View
{
    private let startAngle: Double = 135
    @State private var endAngle: Double = 135
    @State private var clippedEndAngle: Double = 135
    @State private var staticEndAngle: Double = 135 + 270
    @State private var sensitivity = 2.0
    private let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    func value() -> Double
    {
        return 0
    }

    var body: some View
    {
        ZStack
        {
            Color(white: 0.3)
                .edgesIgnoringSafeArea(.all)

            Circle().padding()

            Text(String(format: "%.0f", (endAngle - startAngle) / 360.0 / sensitivity * 100.0))
                .foregroundColor(.white)
                .font(.system(size: 100))
                .fontWeight(.ultraLight)

            GeometryReader
            { geometry in
                Text("Averaged Device Rotation Over All 3 Axis")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding()

                Arc(startAngle: self.startAngle,
                    endAngle: self.$staticEndAngle,
                    center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                    radius: geometry.size.width / 2 - 60)
                    .fill(Color(white: 0.1))

                Arc(startAngle: self.startAngle,
                    endAngle: self.$clippedEndAngle,
                    center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                    radius: geometry.size.width / 2 - 60)
                    .fill(AngularGradient(gradient: self.gradient,
                                          center: .center,
                                          startAngle: .degrees(self.startAngle),
                                          endAngle: .degrees(self.startAngle + 270)))
                    .onReceive((UIApplication.shared.delegate as! AppDelegate).subject)
                    { factor in
                        self.endAngle = 360 * factor * self.sensitivity + self.startAngle
                        self.clippedEndAngle = min(360 * factor * self.sensitivity, 270) + self.startAngle
                        self.sensitivity -= max((self.endAngle - self.clippedEndAngle) / 360 * factor, 0)
                    }

                VStack
                {
                    Text("Sensitivity")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .offset(x: 0, y: 10)
                    Slider(value: self.$sensitivity, in: 1.0...3.0)
                        .padding(.horizontal)
                }
                .offset(x: 0, y: CGFloat(0.75) * geometry.size.height +
                                 CGFloat(0.25) * (geometry.size.width + CGFloat(2 * 20)) -
                                 CGFloat(69 / 2) - CGFloat(15))
                // ^^^ Above offset vertically centers the VStack in the space below the circle.
                //     20 is the common iOS padding() applied to both sides of the outer Circle.
                //     69 is estimated height of this VStack with one slider (checked with screenshot).
                //     15 is the estimated space above text and border of VStack.
            }
        }
        .statusBar(hidden: true)
    }
}

struct Arc : Shape
{
    var startAngle: Double
    @Binding var endAngle: Double
    var center: CGPoint
    var radius: CGFloat
    func path(in rect: CGRect) -> Path
    {
        var path = Path()

        path.addArc(center: center,
                    radius: radius,
                    startAngle: .degrees(startAngle),
                    endAngle: .degrees(endAngle),
                    clockwise: false)

        return path.strokedPath(.init(lineWidth: 50, lineCap: .round))
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
