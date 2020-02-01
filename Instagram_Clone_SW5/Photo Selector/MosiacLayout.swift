//
//  MosiacLayout.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 1/29/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import UIKit

protocol MosiacLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForHeader indexPath: IndexPath) -> CGFloat
    func collectionView(heightForTabBar collectionView: UICollectionView) -> CGFloat
}


enum Element: String {
    case header
    case cell
    
    var id: String { return self.rawValue }
    var kind: String { return self.rawValue.capitalized }
}

class MosiacLayout: UICollectionViewLayout {
    
    weak var delegate: MosiacLayoutDelegate?
    private var cache = [Element: [IndexPath: UICollectionViewLayoutAttributes]]()
    private var contentHeight = CGFloat()
    private var numberOfItems = 0
    private var currentIndex = 0
    private let cellPadding = CGFloat(0.5)
    
    
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.frame.width ?? 0, height: contentHeight)
    }
    
    private var contentOffset: CGPoint {
        return collectionView!.contentOffset
    }
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        //let insets = collectionView.contentInset
        return collectionView.bounds.width //- (insets.left + insets.right)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        contentHeight = 0
        prepareCache()
        currentIndex = 0

        
        numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        prepareHeader(for: collectionView)
        while numberOfItems > 0 {
          prepareLeftOrientedLayout()
          //prepareMiddleOrientedLayout()
          prepareMiddleOrientedLayout()
          prepareRightOrientedLayout()
        }
        
        contentHeight += delegate?.collectionView(heightForTabBar: collectionView) ?? 0
        
    }
    
    private func prepareHeader(for collectionView: UICollectionView) {
        let headerIndexPath = IndexPath(item: 0, section: 0)
        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.header.kind, with: headerIndexPath)
        let headerHeight = delegate?.collectionView(collectionView, heightForHeader: headerIndexPath) ?? 200
        headerAttributes.frame = CGRect(x: 0, y: contentHeight, width: contentWidth , height: headerHeight)
        contentHeight += headerAttributes.frame.height
        cache[.header]?[headerIndexPath] = headerAttributes
    }
    
    private func prepareCache() {
        cache.removeAll(keepingCapacity: true)
        cache[.header] = [IndexPath: UICollectionViewLayoutAttributes]()
        cache[.cell] = [IndexPath: UICollectionViewLayoutAttributes]()
    }
    
    private func prepareLeftOrientedLayout () {
      if numberOfItems > 0 {
        contentHeight += contentWidth*2/3
        let indexPath1 = IndexPath(item: currentIndex, section: 0)
        let height1 = contentWidth*2/3
        let width1 = 2/3*(contentWidth)
        let frame1 = CGRect(x: 0, y: contentHeight-contentWidth*2/3, width: width1, height: height1)
        let attributes1 = UICollectionViewLayoutAttributes(forCellWith: indexPath1)
        attributes1.frame = frame1.insetBy(dx: cellPadding, dy: cellPadding)
        cache[.cell]?[indexPath1] = attributes1
        currentIndex += 1
        numberOfItems -= 1
      }
      if numberOfItems > 0 {
        // computing frame two
        let indexPath2 = IndexPath(item: currentIndex, section: 0)
        let height2 = contentWidth/3
        let width2 = 1/3*(contentWidth)
        let frame2 = CGRect(x: contentWidth*2/3, y: contentHeight-contentWidth*2/3, width: width2, height: height2)
        let attributes2 = UICollectionViewLayoutAttributes(forCellWith: indexPath2)
        attributes2.frame = frame2.insetBy(dx: cellPadding, dy: cellPadding)
        cache[.cell]?[indexPath2] = attributes2
        currentIndex += 1
        numberOfItems -= 1
      }
      if numberOfItems > 0 {
        // computing frame three
        let indexPath3 = IndexPath(item: currentIndex, section: 0)
        let height3 = contentWidth/3
        let width3 = 1/3*(contentWidth)
        let frame3 = CGRect(x: contentWidth*2/3, y: contentHeight - contentWidth*2/3 + contentWidth/3, width: width3, height: height3)
        let attributes3 = UICollectionViewLayoutAttributes(forCellWith: indexPath3)
        attributes3.frame = frame3.insetBy(dx: cellPadding, dy: cellPadding)
        cache[.cell]?[indexPath3] = attributes3
        currentIndex += 1
        numberOfItems -= 1
      }
    }
    
    private func prepareRightOrientedLayout () {
      if numberOfItems > 0 {
        contentHeight += contentWidth*2/3
        let indexPath1 = IndexPath(item: currentIndex, section: 0)
        let height1 = contentWidth/3
        let width1 = 1/3*(contentWidth)
        let frame1 = CGRect(x: 0, y: contentHeight-contentWidth*2/3, width: width1, height: height1)
        let attributes1 = UICollectionViewLayoutAttributes(forCellWith: indexPath1)
        attributes1.frame = frame1.insetBy(dx: cellPadding, dy: cellPadding)
        cache[.cell]?[indexPath1] = attributes1
        currentIndex += 1
        numberOfItems -= 1
      }
      if numberOfItems > 0 {
        // computing frame two
        let indexPath2 = IndexPath(item: currentIndex, section: 0)
        let height2 = contentWidth/3
        let width2 = 1/3*(contentWidth)
        let frame2 = CGRect(x: 0, y: contentHeight-contentWidth/3, width: width2, height: height2)
        let attributes2 = UICollectionViewLayoutAttributes(forCellWith: indexPath2)
        attributes2.frame = frame2.insetBy(dx: cellPadding, dy: cellPadding)
        cache[.cell]?[indexPath2] = attributes2
        currentIndex += 1
        numberOfItems -= 1
      }
      if numberOfItems > 0 {
        // computing frame three
        let indexPath3 = IndexPath(item: currentIndex, section: 0)
        let height3 = contentWidth*2/3
        let width3 = 2/3*(contentWidth)
        let frame3 = CGRect(x: contentWidth*1/3, y: contentHeight - contentWidth*2/3 , width: width3, height: height3)
        let attributes3 = UICollectionViewLayoutAttributes(forCellWith: indexPath3)
        attributes3.frame = frame3.insetBy(dx: cellPadding, dy: cellPadding)
        cache[.cell]?[indexPath3] = attributes3
        currentIndex += 1
        numberOfItems -= 1
      }
    }
    
    private func prepareMiddleOrientedLayout () {
        if numberOfItems > 0 {
            contentHeight += contentWidth/3
            let indexPath1 = IndexPath(item: currentIndex, section: 0)
            let height1 = contentWidth/3
            let width1 = contentWidth/3
            let frame1 = CGRect(x: 0, y: contentHeight-contentWidth/3, width: width1, height: height1)
            let attributes1 = UICollectionViewLayoutAttributes(forCellWith: indexPath1)
            attributes1.frame = frame1.insetBy(dx: cellPadding, dy: cellPadding)
            cache[.cell]?[indexPath1] = attributes1
            currentIndex += 1
            numberOfItems -= 1
        }
        if numberOfItems > 0 {
            // computing frame two
            let indexPath2 = IndexPath(item: currentIndex, section: 0)
            let height2 = contentWidth/3
            let width2 = contentWidth/3
            let frame2 = CGRect(x: contentWidth/3, y: contentHeight-contentWidth/3, width: width2, height: height2)
            let attributes2 = UICollectionViewLayoutAttributes(forCellWith: indexPath2)
            attributes2.frame = frame2.insetBy(dx: cellPadding, dy: cellPadding)
            cache[.cell]?[indexPath2] = attributes2
            currentIndex += 1
            numberOfItems -= 1
        }
        if numberOfItems > 0 {
            // computing frame three
            let indexPath3 = IndexPath(item: currentIndex, section: 0)
            let height3 = contentWidth/3
            let width3 = contentWidth/3
            let frame3 = CGRect(x: contentWidth*2/3, y: contentHeight - contentWidth/3 , width: width3, height: height3)
            let attributes3 = UICollectionViewLayoutAttributes(forCellWith: indexPath3)
            attributes3.frame = frame3.insetBy(dx: cellPadding, dy: cellPadding)
            cache[.cell]?[indexPath3] = attributes3
            currentIndex += 1
            numberOfItems -= 1
        }
    }
    
}

extension MosiacLayout {
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case Element.header.kind:
            return cache[.header]?[indexPath]
        default:
            return cache[.cell]?[indexPath]
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[.cell]?[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        var visableLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        let headerAttributes = cache[.header]?[IndexPath(item: 0, section: 0)] ?? UICollectionViewLayoutAttributes()
        let contentOffsetY = collectionView.contentOffset.y
        let width = collectionView.frame.width
        let height = headerAttributes.frame.height - contentOffsetY
        headerAttributes.frame = CGRect(x: 0, y: contentOffsetY , width: width, height: height)
        visableLayoutAttributes.append(headerAttributes)
        
        // cells
        
        for (_, attributes) in cache[.cell]! {
            if attributes.frame.intersects(rect) {
                visableLayoutAttributes.append(attributes)
            }
        }
        
        return visableLayoutAttributes
    }
    
    
}
