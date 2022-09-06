//
//  Matrix.swift
//  iOS_note
//
//  Created by allen0828 on 2022/7/22.
//

import UIKit
import simd

@objc class Matrix: NSObject {

    @objc public static func test() {
        
        var a = simd_float3x3()
        a.columns.0 = simd_float3(1,0,0)
        a.columns.1 = simd_float3(0,1,0)
        a.columns.2 = simd_float3(0.2,0,1)
        
        let b = simd_float3(-0.5,-0.5,1)
        let c = a * b
        
        let d = simd_float3(0.5,-0.5,1)
        let e = a * d
        
        let f = simd_float3(0.5,0.5,1)
        let g = a * f
    }
    
    
}
