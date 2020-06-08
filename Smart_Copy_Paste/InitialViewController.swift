//
//  InitialViewController.swift
//  Smart_Copy_Paste
//
//  Created by KOTTE V S S DHEERAJ on 08/06/20.
//  Copyright © 2020 KOTTE V S S DHEERAJ. All rights reserved.
//

import UIKit
import Vision
import VisionKit
class InitialViewController: UIViewController,VNDocumentCameraViewControllerDelegate {
    
    var vision = VNRecognizeTextRequest(completionHandler: nil)
    var document = VNDocumentCameraViewController()
    var text_String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        document.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Camera(_ sender: Any) {
        
            
        
        
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images = [CGImage]()
         let image = scan.imageOfPage(at: 0)
         if let cgImage = image.cgImage {
             images.append(cgImage)
         }
        
         
         detect_Text(images)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ViewController{
            destinationVC.text =  text_String
        }
    }
    func detect_Text(_ image:[CGImage]){
         
           
           vision = VNRecognizeTextRequest(completionHandler: { (request, Error) in
               
               guard let value = request.results as? [VNRecognizedTextObservation] else{
                   return
               }
               
               for a in value{
                   guard let b = a.topCandidates(1).first else{
                       continue
                   }
                    print(self.text_String)
                    self.text_String+="\n\(b.string)"
               }
               DispatchQueue.main.async {
                   
                self.document.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "PresentTextInARView", sender: (Any).self)
                
                
                }
           })
       
           vision.recognitionLevel = .accurate
          
      
           for image in image {
                      let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
           
                      do {
                          try requestHandler.perform([vision])
                      } catch {
                          print(error)
                      }
                      text_String += "\n\n"
            }
       
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
