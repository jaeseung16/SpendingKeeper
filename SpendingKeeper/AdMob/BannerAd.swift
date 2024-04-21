//
//  BannerAd.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 4/21/24.
//

import SwiftUI

struct BannerAd: UIViewControllerRepresentable {
    let adUnitId = "ca-app-pub-3940256099942544/2435281174" //"ca-app-pub-6771077591139198/3138486346"
    
    init() {
    }
    
    func makeUIViewController(context: Context) -> BannerAdViewController {
        return BannerAdViewController(adUnitId: adUnitId)
    }

    func updateUIViewController(_ uiViewController: BannerAdViewController, context: Context) {
        
    }
}
