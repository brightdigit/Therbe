// ActivitiyIndicatorView.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import SwiftUI
import UIKit

struct ActivitiyIndicatorView: UIViewRepresentable {
  func makeUIView(context _: UIViewRepresentableContext<ActivitiyIndicatorView>) -> UIActivityIndicatorView {
    return UIActivityIndicatorView(style: style)
  }

  func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivitiyIndicatorView>) {
    uiView.startAnimating()
  }

  typealias UIViewType = UIActivityIndicatorView

  let style: UIActivityIndicatorView.Style
}
