//
//  HomeDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// - Type alias for asset content
typealias Asset = (title: String, mimeType: String, url: URL?, imagePath: String, isFavorite: Bool)

protocol HomeDelegate: Waitable {
    
    // - Tells the view that the assets have been loaded
    func assetsLoaded(_ assets: [[Asset]], _ sections: [String])
    
    // - Tells the view that the marquee text has been updated
    func marqueeUpdated(_ text: String)
    
    // - Tells the view that an asset has been selected and it needs to be rendered with
    // - the web view presenter that has been passed along
    func fileOpened(_ presenter: WebViewPresenter)
 
    // - Tell the view to show empty data with an optional additional message
    func showEmpty(_ message: String?)
    
    // - Tell the view to hide the empty data view
    func hideEmpty()
    
    // - Notify the view that favorites have been enabled
    func favoritesEnabled()
    
    // - Notify the view that favorites have been disabled
    func favoritesDisabled()
    
    // - Notify the view to show empty favorites
    func showEmptyFavorites()

    // - Notify the view to hide empty favorites
    func hideEmptyFavorites()
    
    // - Show a notification banner
    func showBanner(_ message: String)
}
