//
//  EnviromentExchanger.swift
//  Object Classifier
//
//  Created by Nikita Galaganov on 28.02.2020.
//  Copyright © 2020 Nikita Galaganov. All rights reserved.
//

import Foundation
import Vision

class EnviromentExchanger: ObservableObject {
    @Published var observation: String = " "{
        willSet{
            objectWillChange.send()
        }
    }
    
    init() {
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
             let obsData = DataWriter().getObj()
             self.observation = obsData
        }
    }
}

class DataWriter {
    private var key: String = "ObjInfo"
    
    func setObj(object: VNClassificationObservation){
        let confidence = String(Int(object.confidence * 100)) + " %"
        let data = Data((confidence + "\n" + object.identifier.description).utf8)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func getObj() -> String{
        let obj = String(decoding: UserDefaults.standard.data(forKey: key) ?? Data(), as: UTF8.self)
        return obj
    }
}
