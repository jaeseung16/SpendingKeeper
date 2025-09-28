//
//  BannerAdViewController.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 4/21/24.
//

import UIKit
import GoogleMobileAds
import os

class BannerAdViewController: UIViewController {
    private let logger = Logger()
    
    let adUnitId: String
    
    //Initialize variable
    init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bannerView: BannerView = BannerView() //Creates your BannerView

    override func viewDidLoad() {
        // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "a41877dede79bf64096bf6dd857966e1" ]
        
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = self
        bannerView.delegate = self
        
        //Add our BannerView to the VC
        view.addSubview(bannerView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadBannerAd()
    }
    
    //Allows the banner to resize when transition from portrait to landscape orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.bannerView.isHidden = true //So banner doesn't disappear in middle of animation
        } completion: { _ in
            self.bannerView.isHidden = false
            self.loadBannerAd()
        }
    }

    func loadBannerAd() {
        let frame = view.frame.inset(by: view.safeAreaInsets)
        let viewWidth = frame.size.width

        //Updates the BannerView size relative to the current safe area of device (This creates the adaptive banner)
        bannerView.adSize = inlineAdaptiveBanner(width: viewWidth, maxHeight: 50)

        if let winddowScene = self.view.window?.windowScene{
            let gadRequest = Request()
            gadRequest.scene = winddowScene
            bannerView.load(gadRequest)
        }
    }
}

extension BannerAdViewController: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        logger.info("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        logger.error("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        logger.info("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        logger.info("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        logger.info("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        logger.info("bannerViewDidDismissScreen")
    }
}
