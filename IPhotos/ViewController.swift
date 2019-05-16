//
//  ViewController.swift
//  IPhotos
//
//  Created by Алексей Пархоменко on 16/05/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var imageScrollView: ImageScrollView!
    var photoViewController: PhotoViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1. Initialize imageScrollView and adding it to viewControllers view
        imageScrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(imageScrollView)
        setupImageScrollView()
        
        //2. Making an image from our photo path
        let imagePath = Bundle.main.path(forResource: "gratisography-225H", ofType: "jpg")!
        let image = UIImage(contentsOfFile: imagePath)!
        
        //3. Ask imageScrollView to show image
        imageScrollView.set(image: image)
    }
    
    func setupImageScrollView() {
        imageScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    // MARK - 3 strange function about screen transition
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        restoreStatrsForRotation(in: size)
    }
    
    func restoreStatrsForRotation(in bounds: CGRect) {
        
        // recalculate contentSize bbased on current orientation
        let restorePoint = imageScrollView.pointToCenterAfterRotation()
        let restoreScale = imageScrollView.scaleToRestoreAfterRotation()
        imageScrollView.frame = bounds
        imageScrollView.setMaxMinZoomScaleForCurrentBounds()
        imageScrollView.restoreCenterPoint(to: restorePoint, oldScale: restoreScale)
    }
    
    func restoreStatrsForRotation(in size: CGSize) {
        var bounds = self.view.bounds
        if bounds.size != size {
            bounds.size = size
            self.restoreStatrsForRotation(in: bounds)
        }
    }
}

