// ResultList.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

extension Array: Error where Element == Error {}

public typealias ResultList<Element> = Result<[Element], [Error]>
