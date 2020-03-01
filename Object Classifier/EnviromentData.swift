//
//  EnviromentData.swift
//  Object Classifier
//
//  Created by Nikita Galaganov on 28.02.2020.
//  Copyright © 2020 Nikita Galaganov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreML
import Vision

class EnviromentData: ObservableObject {
    @Published var observation: VNClassificationObservation = VNClassificationObservation(){
        willSet{
            objectWillChange.send()
        }
    }
}
