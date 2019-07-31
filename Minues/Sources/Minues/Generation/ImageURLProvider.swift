// ImageURLProvider.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

public protocol ImageURLProvider {
  func imageUrl(withSize size: Size) -> URL
}
