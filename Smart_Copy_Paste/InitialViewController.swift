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
import Alamofire
class InitialViewController: UIViewController,VNDocumentCameraViewControllerDelegate {
    var flag = true
    var vision = VNRecognizeTextRequest(completionHandler: nil)
    var document = VNDocumentCameraViewController()
    var text_String = ""
    var images = [CGImage]()
    var image:UIImage?
    @IBOutlet weak var image_view: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        document.delegate = self
        // Do any additional setup after loading the view.
    }
    @IBAction func camera_two(_ sender: Any) {
        images = []
        flag = true
        present(document, animated: true)
        
    }
    
    @IBAction func Camera(_ sender: Any) {
        images = []
        text_String = ""
        flag = false
        present(document, animated: true)
        
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
       
         let image = scan.imageOfPage(at: 0)
        if let cgImage = image.cgImage {
             images.append(cgImage)
        }
        if flag{
            document.dismiss(animated: true, completion: nil)
            remove_background()
           
            
        }
        else{
            
            detect_Text(images)
        }
         
         
        
    }
    
    func remove_background(){

        let imgData = UIImage(cgImage: images[0]).jpegData(compressionQuality: 0)!
                       AF.upload(
                               multipartFormData: { builder in
                                   builder.append(
                                       imgData,
                                       withName: "image_file",
                                       fileName: "car.jpg",
                                       mimeType: "image/jpeg"
                                   )
                               },
                               to: URL(string: "https://api.remove.bg/v1.0/removebg")!,
                               headers: [
                                   "X-Api-Key": "1hSJN52f8cUtouHyyFTtCPZj"
                               ]
                           )
                        .responseJSON { imageResponse in
                                       guard let imageData = imageResponse.data,
                                           let image = UIImage(data: imageData) else { return }
                            self.image_view.image = image
                            DispatchQueue.main.async {
                                self.image = image
                                self.performSegue(withIdentifier: "PresentTextInARView", sender: self)
                            }
                            
                                   
                            
                           }
            
        }
        
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ViewController{
            if !flag{
                destinationVC.text =  text_String
                destinationVC.flag = false
            }
            else{
                destinationVC.image = image!
                destinationVC.flag = true
            }
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
