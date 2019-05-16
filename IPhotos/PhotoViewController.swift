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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pagingScrollViewFrame = frameForPagingScrollView()
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        view.backgroundColor = .black
        pagingScrollView.backgroundColor = .black
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        view.addSubview(pagingScrollView)
        
        for index in 0..<imageCount {
            let page = ImageScrollView()
            configure(page, for: index)
            pagingScrollView.addSubview(page)
        }
    }
    
    func configure(_ page: ImageScrollView, for index: Int) {
        page.frame = self.frameForPage(at: index)
        page.set(image: self.image(at: index))
    }
    
    func frameForPage(at index: Int) -> CGRect {
        let bounds = self.pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= 2 * pagePadding
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + pagePadding
        return pageFrame
    }
	
    func frameForPagingScrollView() -> CGRect {
        var frame = UIScreen.main.bounds
        frame.origin.x -= pagePadding
        print(frame.origin.x)
        frame.size.width += 2 * pagePadding
        print(UIScreen.main.bounds)
        print(frame.size.width)
        return frame
    }
    
    func contentSizeForPagingScrollView() -> CGSize {
        let bounds = self.pagingScrollView.bounds
        return CGSize(width: bounds.size.width * CGFloat(imageCount), height: bounds.size.height)
    }
	
	
	//MARK: - Image Fetching tools
	
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
