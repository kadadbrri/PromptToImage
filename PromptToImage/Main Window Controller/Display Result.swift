//
//  Display Result.swift
//  PromptToImage
//
//  Created by hany on 25/12/22.
//

import Foundation
import AppKit

extension SDMainWindowController {
    
    
    // MARK: Display Results
    
    func displayResult(images:[CGImage?],
                       upscale:Bool,
                       prompt:String,
                       negativePrompt:String,
                       startingImage: CGImage?,
                       strength: Float,
                       stepCount:Int,
                       seed:Int,
                       guidanceScale:Float) {
        
        if images.count == 1 {
            self.displaySingleImage(image: images[0], upscale: upscale, prompt: prompt, negativePrompt: negativePrompt, startingImage: startingImage, strength: strength, stepCount: stepCount, seed: seed, guidanceScale: guidanceScale)
        } else if images.count > 1 {
            self.displayMultipleImages(images: images, upscale: upscale, prompt: prompt, negativePrompt: negativePrompt, startingImage: startingImage, strength: strength, stepCount: stepCount, seed: seed, guidanceScale: guidanceScale)
        }
    }
    
    
    
    
    // MARK: Display Multiple Images
    
    // display collection view
    func displayMultipleImages(images:[CGImage?],
                               upscale:Bool,
                               prompt:String,
                               negativePrompt:String,
                               startingImage: CGImage?,
                               strength: Float,
                               stepCount:Int,
                               seed:Int,
                               guidanceScale:Float) {
        
        DispatchQueue.main.async {
            self.progrLabel.stringValue = "Upscaling images..."
            self.indindicator.isHidden = false
            self.indicator.isHidden = true
        }
        
        
        
        for cgimage in images {
            if cgimage != nil {
                let nsimage = NSImage(cgImage: cgimage!,size: .zero)
                if upscale {
                    if let upscaledImage = Upscaler.shared.upscaledImage(image: nsimage) {
                        DispatchQueue.main.async {
                            // copy images to save clipboard
                            generatedImages.append(upscaledImage)
                            // add history item
                            let item = HistoryItem(modelName:currentModelName(), prompt: prompt, negativePrompt: negativePrompt, steps: stepCount, guidanceScale: guidanceScale, inputImage: startingImage, strenght: strength, image: nsimage, upscaledImage: upscaledImage, seed: seed)
                            DispatchQueue.main.async {
                                self.historyArrayController.addObject(item)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        // copy images to save clipboard
                        generatedImages.append(nsimage)
                        // add history item
                        let item = HistoryItem(modelName:currentModelName(), prompt: prompt, negativePrompt: negativePrompt, steps: stepCount, guidanceScale: guidanceScale, inputImage: startingImage, strenght: strength, image: nsimage, upscaledImage: nil, seed: seed)
                        DispatchQueue.main.async {
                            self.historyArrayController.addObject(item)
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.saveBtn.isEnabled = true
            self.window?.endSheet(self.progrWin)
            self.imageview.image = generatedImages.first ?? NSImage()
        }
    }
    
    
    
    
    // MARK: Display Single Image
    
    // display image view
    func displaySingleImage(image:CGImage??,
                            upscale:Bool,
                            prompt:String,
                            negativePrompt:String,
                            startingImage: CGImage?,
                            strength: Float,
                            stepCount:Int,
                            seed:Int,
                            guidanceScale:Float) {
        
        if image != nil {
            let nsimage = NSImage(cgImage: image!!,
                                  size: .zero)
            DispatchQueue.main.async {
                isRunning = false
                
                if upscale {
                    // UPSCALE OUTPUT IMAGE
                    
                    self.progrLabel.stringValue = "Upscaling image..."
                    self.indindicator.isHidden = false
                    self.indicator.isHidden = true
                    print("upscaling image...")
                    DispatchQueue.global().async {
                        if let upscaledImage = Upscaler.shared.upscaledImage(image: nsimage) {
                            DispatchQueue.main.async {
                                // copy images to save clipboard
                                generatedImages.append(upscaledImage)
                                // add history item
                                let item = HistoryItem(modelName:currentModelName(), prompt: prompt, negativePrompt: negativePrompt, steps: stepCount, guidanceScale: guidanceScale, inputImage: startingImage, strenght: strength, image: nsimage, upscaledImage: upscaledImage, seed: seed)
                                DispatchQueue.main.async {
                                    self.historyArrayController.addObject(item)
                                    self.imageview.image = upscaledImage
                                }
                                // close wait window
                                self.window?.endSheet(self.progrWin)
                                self.saveBtn.isEnabled = true
                            }
                        }
                    }
                } else {
                    // copy images to save clipboard
                    generatedImages.append(nsimage)
                    // add history item
                    let item = HistoryItem(modelName:currentModelName(), prompt: prompt, negativePrompt: negativePrompt, steps: stepCount, guidanceScale: guidanceScale, inputImage: startingImage, strenght: strength, image: nsimage, upscaledImage: nil, seed: seed)
                    DispatchQueue.main.async {
                        self.historyArrayController.addObject(item)
                        self.imageview.image = nsimage
                    }
                    // close wait window
                    self.window?.endSheet(self.progrWin)
                    self.saveBtn.isEnabled = true
                }
                
                
            }
        } else {
            print("ERROR image is nil")
            DispatchQueue.main.async {
                self.saveBtn.isEnabled = false
                self.window?.endSheet(self.progrWin)
            }
        }
    }
    
    
}