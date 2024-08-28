//
//  SimpleMovingAverageFilter.swift
//  Rotation
//
//  Created by Cornelis van der Bent on 19/11/2019.
//  Copyright © 2019 Meaning Matters. All rights reserved.
//

import Foundation

class SimpleMovingAverageFilter: Filter
{
    private var samples: [Double]
    private var average: Double
    private var index: Int

    /// Create SMA filter.
    ///
    /// - Parameter rate: Sample rate in Hz.
    /// - Parameter period: Length of the sample buffer in seconds.
    init(sampleRate rate: Double, period: Double)
    {
        samples = [Double](repeating: 0.0, count: Int(round(rate * period)))
        average = 0.0
        index = 0
    }

    // According to https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average
    func addSample(sample: Double) -> Double
    {
        let droppingSample = samples[index % samples.count]
        samples[index % samples.count] = sample
        index += 1

        average += 1.0 / Double(samples.count) * (sample - droppingSample)

        return average
    }
}
