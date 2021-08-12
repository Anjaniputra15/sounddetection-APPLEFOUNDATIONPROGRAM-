//
//  BirdsModel.swift
//  BirdsModel
//
//  Created by Dmitrii on 09.08.2021.
//

import Foundation

struct Birds {
    var name:String
    var confidence:Double
    var isDetected:Bool {
        if confidence > 0 {
            return  true
        } else {
         return   false
        }
    }

}
