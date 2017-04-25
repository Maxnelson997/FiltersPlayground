//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

protocol Processable {
    var filter: CIFilter { set get }
    func input(_ image: UIImage)
    func outputUIImage() -> UIImage?
}


extension NSNumber {
    static func doubleNumber(_ double: Double, min: Double, max: Double) -> NSNumber {
        return NSNumber(value: self.convert(double, min: min, max: max))
    }
    
    static func floatNumber(_ floatNr: Float, min: Float, max: Float) -> NSNumber {
        return NSNumber(value: self.convert(floatNr, min: min, max: max))
    }
    
    static func intNumber(_ int: Int, min: Int, max: Int) -> NSNumber {
        return NSNumber(value: self.convert(int, min: min, max: max) as Int)
    }
    
    fileprivate static func convert<T: Comparable>(_ target: T, min: T, max: T) -> T {
        if target < min {
            return min
        }
        
        if target > max {
            return max
        }
        
        return target
    }
}

extension Processable {
    
    func input(_ image: UIImage) {
        if let cgImage = image.cgImage {
            
            let ciImage = CIImage(cgImage: cgImage)
            self.filter.setValue(ciImage, forKey: kCIInputImageKey)
        }
    }
}


extension Processable {
    
    func outputUIImage() -> UIImage? {
        
        if let outputImage = self.filter.outputImage {
            let openGLContext = EAGLContext(api: .openGLES3)!
            let ciImageContext = CIContext(eaglContext: openGLContext)
            
            if let cgImageNew = ciImageContext.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImageNew)
            }
        }
        
        return nil
    }
}

protocol AdjustBrightness: Processable {
    var minBrightnessVal: Float { get }
    var maxBrightnessVal: Float { get }
    var curBrightnessVal: Float { get }
    func brightness(_ brightness: Float)
}

protocol AdjustContrast: Processable {
    var minContrastVal: Float { get }
    var maxContrastVal: Float { get }
    var curContrastVal: Float { get }
    func contrast(_ contrast: Float)
}

protocol AdjustSaturation: Processable {
    var minSaturationVal: Float { get }
    var maxSaturationVal: Float { get }
    var curSaturationVal: Float { get }
    func saturation(_ saturation: Float)
}

//
extension AdjustBrightness {
    var minBrightnessVal: Float {
        return -0.5
    }
    
    var maxBrightnessVal: Float {
        return 0.5
    }
    
    var curBrightnessVal: Float {
        return filter.value(forKey: kCIInputBrightnessKey) as? Float ?? 0.00
    }
    
    func brightness(_ brightness: Float) {
        self.filter.setValuesForKeys(["inputBrightness":brightness])
    }
}

//
extension AdjustContrast {
    
    var minContrastVal: Float {
        return 0.00
    }
    
    var maxContrastVal: Float {
        return 2.00
    }
    
    var curContrastVal: Float {
        return filter.value(forKey: kCIInputContrastKey) as? Float ?? 1.00
    }
    
    func contrast(_ contrast: Float) {
        
        self.filter.setValuesForKeys(["inputContrast":contrast])
    }
}

//
extension AdjustSaturation {
    
    var minSaturationVal: Float {
        return 0.25
    }
    
    var maxSaturationVal: Float {
        return 1.75
    }
    
    var curSaturationVal: Float {
        return filter.value(forKey: kCIInputSaturationKey) as? Float ?? 1.00
    }
    
    func saturation(_ saturation: Float) {
        self.filter.setValuesForKeys(["inputSaturation":saturation])
    }
}

class CIFilterControls: AdjustBrightness, AdjustContrast, AdjustSaturation {
    
    var filter:CIFilter = CIFilter()
    
    init(CIFilterType:String) {
        filter = CIFilter(name: CIFilterType)!
    }
}




let controls = CIFilterControls(CIFilterType: "CIColorControls")
controls.input(#imageLiteral(resourceName: "comp.jpg"))

let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 800))
view.backgroundColor = .white

let img = UIImageView(image: #imageLiteral(resourceName: "comp.jpg"))
img.frame = CGRect(x: 20, y: 20, width: 460, height: 460)



func updateBrightness(sender:UISlider) {
    controls.brightness(sender.value)
    img.image = controls.outputUIImage()
}

class controlmethods: NSObject {
    func BrightnessChanged(sender:UISlider) {
        updateBrightness(sender: sender)
    }
}

let c = controlmethods()

let slider = UISlider(frame: CGRect(x: 20, y: 500, width: 460, height: 50))
slider.minimumValue = controls.minBrightnessVal
slider.maximumValue = controls.maxBrightnessVal
slider.value = controls.curBrightnessVal
slider.thumbTintColor = UIColor.green.withAlphaComponent(0.7)
slider.addTarget(c, action: #selector(c.BrightnessChanged(sender:)), for: .valueChanged)



view.addSubview(img)
view.addSubview(slider)
        
PlaygroundPage.current.liveView = view

/*var names:[String] = [
    "CIColorControls",
    "CIHueAdjust",
    "CINoiseReduction"
]

print("\nExample: kCInputSaturationKey")

for i in 0 ..< names.count {
    let c = CIFilter(name: names[i])!
    var f = c.inputKeys.filter { $0 != "inputImage"}
    print("\(names[i]):  \(f)\n")
}*/
