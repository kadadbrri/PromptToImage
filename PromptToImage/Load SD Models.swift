//
//  Load SD Model.swift
//  PromptToImage
//
//  Created by hany on 05/12/22.
//

import Foundation
import CoreML


// MARK: Create Pipeline

func createStableDiffusionPipeline(computeUnits:MLComputeUnits, url:URL) {
    
    // show wait window
    (wins["main"] as! SDMainWindowController).waitProgr.startAnimation(nil)
    (wins["main"] as! SDMainWindowController).waitLabel.stringValue = "Creating pipeline..."
    (wins["main"] as! SDMainWindowController).window?.beginSheet((wins["main"] as! SDMainWindowController).waitWin)
    
    DispatchQueue.global().async {
        
        // create Stable Diffusion pipeline from CoreML resources
        print("creating Stable Diffusion pipeline...")
        do {
            let config = MLModelConfiguration()
            config.computeUnits = computeUnits
            sdPipeline = try StableDiffusionPipeline(resourcesAt: url,
                                                     configuration:config)
            try sdPipeline?.loadResources()
        } catch {}
        
        
        // load upscale model
        print("loading upscale model...")
        Upscaler.shared.setupUpscaleModelFromPath(path: defaultUpscaleModelPath!,
                                                  computeUnits: .cpuAndGPU)
        
        // close waiw window
        DispatchQueue.main.async {
            (wins["main"] as! SDMainWindowController).window?.endSheet((wins["main"] as! SDMainWindowController).waitWin)
        }
    }
}
