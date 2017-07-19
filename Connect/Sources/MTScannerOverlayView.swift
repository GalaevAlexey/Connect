//
//  ScannerOverlayView.Swift
//  Authenticator
//
//  Created by Alexey Galaev on 11/24/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit

class ScannerOverlayView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.needsDisplayOnBoundsChange = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.needsDisplayOnBoundsChange = true
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        UIColor(white: 0, alpha: 0.5).setFill()
        UIColor(white: 1, alpha: 0.2).setStroke()

        let smallestDimension = min(self.bounds.width, self.bounds.height)
        let windowSize = 0.9 * smallestDimension
        let window = CGRect(
            x: rect.midX - windowSize/2,
            y: rect.midY - windowSize/2,
            width: windowSize,
            height: windowSize
        )

        context.fill(rect)
        context.clear(window)
        context.stroke(window)
    }
}
