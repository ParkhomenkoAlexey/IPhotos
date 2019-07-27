//
//  PhotoViewController.swift
//  PhotoScroller
//
//  Created by Seyed Samad Gholamzadeh on 1/19/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
	
    let pagePadding: CGFloat = 10
    var pagingScrollView: UIScrollView!
    
    var recycledPages: Set<ImageScrollView> = [] // Tiling and page configuration
    var visiblePages: Set<ImageScrollView> = [] // Tiling and page configuration
    
    // we need this variable for saving page index before rotation
    var firstVisiblePageIndexBeforeRotation: Int!
    
    // single tap for hide / show bar
    var singleTap: UITapGestureRecognizer!
    
    var navigationBarIsHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        view.addGestureRecognizer(self.singleTap)
        
        if self.navigationController != nil, !self.navigationController!.navigationBar.isHidden {
            self.navigationBarIsHidden = false
        }

        let pagingScrollViewFrame = frameForPagingScrollView()
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        self.updateBackgroundColor()
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        self.pagingScrollView.contentInsetAdjustmentBehavior = .never // чтобы во время поворота экрана фото не съезжали
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
        
        layoutPagingScrollView()
        
        // стало, после dequeue reusable cells
        self.tilePages()
        
        // было
        //        for index in 0..<imageCount {
        //            let page = ImageScrollView()
        //            configure(page, for: index)
        //            pagingScrollView.addSubview(page)
        //        }
    }
    
    @objc func handleSingleTap() {
        print("123")
        let duration: TimeInterval = 0.2
        if self.navigationController != nil {
            
            if !self.navigationBarIsHidden {
                
                self.navigationBarIsHidden = true
                UIView.animate(withDuration: duration, animations: {
                    self.navigationController?.navigationBar.alpha = 0
                    self.updateBackgroundColor()
                    
                }) { (finished) in
                    self.navigationController?.navigationBar.isHidden = true
                }
            } else {
                self.navigationBarIsHidden = false
                UIView.animate(withDuration: duration) {
                    self.navigationController?.navigationBar.alpha = 1
                    self.navigationController?.navigationBar.isHidden = false
                    self.updateBackgroundColor()
                }
            }
        }
    }
    
    // Update background color. Default is white / black
    func updateBackgroundColor() {
        if !self.navigationBarIsHidden {
            self.updateBackground(to: .white)
        } else {
            self.updateBackground(to: .black)
        }
    }
    
    func updateBackground(to color: UIColor) {
        self.view.backgroundColor = color
        pagingScrollView.backgroundColor = color
        
        for page in visiblePages {
            page.backgroundColor = color
        }
    }
    
    //MARK: - Frame calculations
    
    // было
//    func frameForPagingScrollView() -> CGRect {
//        var frame = UIScreen.main.bounds
//        frame.origin.x -= pagePadding
//        frame.size.width += 2 * pagePadding
//        return frame
//    }
    
    // стало, для реализации поворота экрана
    func frameForPagingScrollView(in size: CGSize? = nil) -> CGRect {
        var frame = UIScreen.main.bounds

        if size != nil {
            frame.size = size!
        }

        frame.origin.x -= pagePadding
        frame.size.width += 2 * pagePadding
        return frame
    }
    
    //MARK: - Calculate contentSize
    func contentSizeForPagingScrollView() -> CGSize {
        let bounds = self.pagingScrollView.bounds
        return CGSize(width: bounds.size.width * CGFloat(imageCount), height: bounds.size.height)
    }
    
    func configure(_ page: ImageScrollView, for index: Int) {
        self.singleTap.require(toFail: page.zoomingTap)
        page.backgroundColor = self.view.backgroundColor
        
        page.frame = self.frameForPage(at: index)
        page.set(image: self.image(at: index))
        page.index = index
    }
    
    func frameForPage(at index: Int) -> CGRect {
        let bounds = self.pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= 2 * pagePadding
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + pagePadding
        return pageFrame
    }
    
    //MARK: - Tiling and page configuration

    func tilePages() {
        
        //1. Calculate which pages should now be visible
        let visibleBounds = pagingScrollView.bounds
        
        var firstNeededPageIndex: Int = Int(floor(visibleBounds.minX / visibleBounds.width))
        var lastNeededPageIndex: Int = Int(floor((visibleBounds.maxX - 1) / visibleBounds.width))
        firstNeededPageIndex = max(firstNeededPageIndex, 0)
        lastNeededPageIndex = min(lastNeededPageIndex, imageCount - 1)
        
        //2. Recycle no longer need pages
        for page in self.visiblePages {
            if page.index < firstNeededPageIndex || page.index > lastNeededPageIndex {
                self.recycledPages.insert(page)
                page.removeFromSuperview()
            }
        }
        self.visiblePages.subtract(self.recycledPages)
        
        //3. Add missing pages
        for index in firstNeededPageIndex...lastNeededPageIndex {
            if !self.isDisplayingPage(forIndex: index) {
                let page = self.dequeueRecycledPage() ?? ImageScrollView()
                self.configure(page, for: index)
                self.pagingScrollView.addSubview(page)
                self.visiblePages.insert(page)
            }
        }
    }
    
    func dequeueRecycledPage() -> ImageScrollView? {
        if let page = self.recycledPages.first {
            self.recycledPages.remove(page)
            return page
        }
        return nil
    }
    
    func isDisplayingPage(forIndex index: Int) -> Bool {
        for page in self.visiblePages {
            if page.index == index {
                return true
            }
        }
        return false
    }
    
    // MARK: Configure our app for landscape.
    
    func layoutPagingScrollView() {
        self.pagingScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        pagingScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pagingScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pagingScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        pagingScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -10).isActive = true
    }
    
    // MARK: - Rotation Configuration
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.saveCurrentStatesForRotation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.restoreStatesForRotation(in: size)
    }
    
    // Save current page and zooming states for device rotation.
    func saveCurrentStatesForRotation() {
        let visibleBounds = pagingScrollView.bounds
        firstVisiblePageIndexBeforeRotation = Int(floor(visibleBounds.minX/visibleBounds.width))
    }
    
    // Apply tracked informations for device rotation.
    // Применяйте отслеживаемую информацию для ротации устройства.
    func restoreStatesForRotation(in size: CGSize) {
        
        // recalculate contentSize based on current orientation
        let pagingScrollViewFrame = self.frameForPagingScrollView(in: size)
        pagingScrollView.frame = pagingScrollViewFrame
        pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
        
        // adjust frames and configuration of each visible page
        for page in visiblePages {
            let restorePoint = page.pointToCenterAfterRotation()
            let restoreScale = page.scaleToRestoreAfterRotation()
            page.frame = self.frameForPage(at: page.index)
            page.setMaxMinZoomScaleForCurrentBounds()
            page.restoreCenterPoint(to: restorePoint, oldScale: restoreScale)
        }
        
        // adjust contentOffset to preserve page location based on values collected prior to location
        // настроить contentOffset, чтобы сохранить местоположение страницы на основе значений, собранных до местоположения
        var conterOffset = CGPoint.zero
        
        let pageWidth = pagingScrollView?.bounds.size.width ?? 1
        conterOffset.x = (CGFloat(firstVisiblePageIndexBeforeRotation) * pageWidth)
        
        pagingScrollView.contentOffset = conterOffset
    }
    
 
	// MARK: - Image Fetching tools
	
	lazy var imageData: [Any]? = {
		var data: [Any]? = nil
		
		DispatchQueue.global().sync {
			let path = Bundle.main.url(forResource: "ImageData", withExtension: "plist")
			do {
				let plistData = try Data(contentsOf: path!)
				data = try PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil) as? [Any]
				//				return data
			}
			catch {
				print("Unable to read image data: ", error)
			}
		}
		return data
	}()
	
	lazy var imageCount: Int = {
		return self.imageData?.count ?? 0
	}()
	
	func imageName(at index: Int) -> String {
		if let info = imageData?[index] as? [String: Any] {
			return info["name"] as? String ?? ""
		}
		return ""
	}
	
	// we use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching
	func image(at index: Int) -> UIImage {
		let name = imageName(at: index)
		if let path = Bundle.main.path(forResource: name, ofType: "jpg") {
			return UIImage(contentsOfFile: path)!
		}
		return UIImage()
	}
	
	func imageSizeAt(index: Int) -> CGSize {
		if let info = imageData?[index] as? [String: Any] {
			return CGSize(width: info["width"] as? CGFloat ?? 0, height: info["height"] as? CGFloat ?? 0)
		}
		return CGSize.zero
	}
}

//MARK: - ScrollView delegate methods


extension PhotoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("1_")
        self.tilePages()
    }
}
