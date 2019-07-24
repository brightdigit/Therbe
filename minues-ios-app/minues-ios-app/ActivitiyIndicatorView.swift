//
//  ActivitiyIndicatorView.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/23/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import UIKit
import SwiftUI


struct ActivitiyIndicatorView : UIViewRepresentable {
  func makeUIView(context: UIViewRepresentableContext<ActivitiyIndicatorView>) -> UIActivityIndicatorView {
    return UIActivityIndicatorView(style: self.style)
  }
  
  func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivitiyIndicatorView>) {
    uiView.startAnimating()
  }
  
  
  typealias UIViewType = UIActivityIndicatorView
  
  let style: UIActivityIndicatorView.Style
}
