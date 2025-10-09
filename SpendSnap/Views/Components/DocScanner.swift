//
//  DocScanner.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 06/10/2025.
//

import SwiftUI

import VisionKit
struct DocScanner: UIViewControllerRepresentable {
  var onImage: (UIImage) -> Void
  func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
    let vc = VNDocumentCameraViewController()
    vc.delegate = context.coordinator
    return vc
  }
  func updateUIViewController(_: VNDocumentCameraViewController, context: Context) {}
  func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage) }

  final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    let onImage: (UIImage) -> Void
    init(onImage: @escaping (UIImage) -> Void) { self.onImage = onImage }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
      defer { controller.dismiss(animated: true) }
      guard scan.pageCount > 0 else { return }
      onImage(scan.imageOfPage(at: 0)) // first page; add loop if multi-page
    }
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
      controller.dismiss(animated: true)
    }
  }
}
