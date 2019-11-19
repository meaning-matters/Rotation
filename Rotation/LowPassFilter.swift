//
//  LowPassFilter.swift
//  Rotation
//
//  Created by Cornelis van der Bent on 12/10/2019.
//  Copyright © 2019 Meaning Matters. All rights reserved.
//

import Foundation

class LowPassFilter: Filter
{
    private let filterConstant: Double
    private var value: Double = 0.0

    private var samples = [Double]()
    private var sampleCount: Int

    init(sampleRate rate: Double, cutOffFrequency frequency: Double)
    {
        let dt = 1.0 / rate
        let RC = 1.0 / frequency
        filterConstant = dt / (dt + RC)

        sampleCount = Int(rate)
        samples.reserveCapacity(sampleCount * 4)
    }

    func addSample(sample: Double) -> Double
    {
        value = sample * filterConstant + value * (1.0 - filterConstant)

        return value
    }
}
