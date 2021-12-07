//
//  ViewController.swift
//  Resnet50Demo
//
//  Created by Søren Nielsen on 01/12/2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBOutlet weak var Image: UIImageView!
    
    @IBOutlet weak var Output: UILabel!
    
    @IBAction func ChooseButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        print(image)
        
        analyseImage(image: image)
        Image.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func analyseImage(image: UIImage?) {
        guard let buffer = image?.resize(size: CGSize(width: 224, height:224))?.getCVPixelBuffer()
        else {
            return
        }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model)
        else { return }
        
        
        let request = VNCoreMLRequest(model: model)
        { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation]
                else { return }
                    guard let firstObservation = results.first else { return }
                        print(firstObservation.identifier, firstObservation.confidence)
                        DispatchQueue.main.async {
                            let confidenceRate = firstObservation.confidence * 100
                            let objectName = firstObservation.identifier
                            self.Output.text = "\(objectName) \(confidenceRate)"
        }
     }
        try? VNImageRequestHandler(cvPixelBuffer: buffer, options: [:]).perform([request])
    }
}



