//
//  Filter.swift
//  Rotation
//
//  Created by Cornelis van der Bent on 19/11/2019.
//  Copyright © 2019 Meaning Matters. All rights reserved.
//

import Foundation

protocol Filter
{
    func addSample(sample: Double) -> Double
}
