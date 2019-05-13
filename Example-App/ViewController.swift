//
//  ViewController.swift
//  Example-App
//
//  Created by Shadrach Mensah on 13/05/2019.
//  Copyright © 2019 Shadrach Mensah. All rights reserved.
//

import UIKit
import  Elysium

class ViewController: UIViewController {
    
    lazy var imageView:UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.clipsToBounds = true
        return v
    }()
    
    lazy var buton:UIButton = {
        let v = UIButton(frame: .zero)
        v.setTitle("Choose Image", for: .normal)
        v.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        v.backgroundColor = UIColor.magenta
        v.setTitleColor(.white, for: .normal)
        return v
    }()
    lazy var buton2:UIButton = {
        let v = UIButton(frame: .zero)
        v.setTitle("Resize", for: .normal)
        v.addTarget(self, action: #selector(resize), for: .touchUpInside)
        v.backgroundColor = UIColor.magenta
        v.setTitleColor(.white, for: .normal)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(buton)
        buton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buton2)
        buton2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            buton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            buton.widthAnchor.constraint(equalToConstant: 300),
            buton.heightAnchor.constraint(equalToConstant: 40),
            buton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:10),
            buton2.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            buton2.widthAnchor.constraint(equalToConstant: 300),
            buton2.heightAnchor.constraint(equalToConstant: 40),
            buton2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-10)
        ])
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func pickImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func resize(){
        guard let image = imageView.image else {return}
        let el = Elysium(source: image)
        if let img = el.transformImage(){
           print("The The New image size is: \(img.size)")
            imageView.image = img
        }
        
        
    }


}


extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            imageView.image = image
            print("The original image size is: \(image.jpegData(compressionQuality: 1)!.count)")
        }
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
