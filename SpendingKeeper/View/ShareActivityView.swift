//
//  ShareActivityView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/8/24.
//

import SwiftUI

struct ShareActivityView: UIViewControllerRepresentable {
    let url: URL
    let applicationActivities: [UIActivity]?
    
    @Binding var failedToRemoveItem: Bool
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: applicationActivities)
        
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                failedToRemoveItem = true
            }
        }
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
