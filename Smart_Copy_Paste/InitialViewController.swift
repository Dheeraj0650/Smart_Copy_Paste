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
class InitialViewController: UIViewController,VNDocumentCameraViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate {
    var flag = true
    var vision = VNRecognizeTextRequest(completionHandler: nil)
    var document = VNDocumentCameraViewController()
    var text_String = ""
    var images = [CGImage]()
    var image:UIImage?

    @IBOutlet weak var buttom_View: UIView!
    @IBOutlet weak var collection_view: UICollectionView!
    var options:[String] = ["Image","Text","Voice"]
    override func viewDidLoad() {
        collection_view.dataSource = self
        collection_view.delegate = self
        super.viewDidLoad()
        collection_view.register(UINib(nibName: "CollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "CollectionViewCell")
        document.delegate = self
        buttom_View.layer.cornerRadius = 60
        buttom_View.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
     
      
        // Do any additional setup after loading the view.
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
            self.document.dismiss(animated: true, completion: nil)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.layer.cornerRadius = 15
        cell.label.text = options[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.background_image.isHidden = true
        cell.label.textColor = #colorLiteral(red: 0.2377739549, green: 0.1985788047, blue: 0.2505975366, alpha: 1)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            cell.background_image.isHidden = false
             cell.label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            if indexPath.row == 0{
                self.images = []
                self.flag = true
                self.present(self.document, animated: true)
            
            }
            if indexPath.row == 1{
                self.images = []
                self.text_String = ""
                self.flag = false
                self.present(self.document, animated: true)
            
            }
            timer.invalidate()
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
