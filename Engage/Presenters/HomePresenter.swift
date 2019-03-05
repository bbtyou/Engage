//
//  HomePresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class HomePresenter {
    
    // - View delegate
    weak var delegate: HomeDelegate?
    
    // - All assets
    fileprivate var files = [[File]]()
    
    // - Favorites files
    fileprivate var favoriteFiles = [[File]]()
    
    // - All asset sections
    fileprivate var sections = [Category]()
    
    // - Favorite seections
    fileprivate var favoriteSections = [Category]()
    
    // - IDs for favorites
    fileprivate var favorites = Set<String>()
    
    // - If favorites are shown
    fileprivate var isFavorites = false
    
    deinit {
        Current.log().verbose("** Deallocated \(HomePresenter.self).")
    }
    
    func fetchAssets(_ showSpinner: Bool = true, _ useCache: Bool = false) {
        if showSpinner {
            (self.delegate as? Waitable)?.showSpinner("Loading content...")
        }
        
        self.files = []
        
        Current.main().portal(useCache) { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let portal):
                self.sections = portal.categories.filter({ $0.files.count > 0 }).sorted(by: { $0.lft < $1.lft })
                if self.sections.count == 0 {
                    self.delegate?.showEmpty(nil)
                    return
                }

                // - Get the files
                self.files = self.sections.map({ $0.files })
                
                // - Get the favorites
                self.favorites = Set(portal.favorites.map({ $0.id }))
                
                if self.isFavorites {
                    self.favoriteSections = [Category]()
                    self.favoriteFiles = [[File]]()
                    
                    self.sections.forEach({ (section) in
                        let files = section.files.filter({ self.favorites.contains($0.id) })
                        if files.count > 0 {
                            self.favoriteSections.append(section)
                            self.favoriteFiles.append(files)
                        }
                    })
                    
                    if self.favoriteFiles.count > 0 {
                        self.delegate?.hideEmptyFavorites()
                        self.delegate?.assetsLoaded(
                            self.favoriteFiles.map({
                                return $0.map({ return ($0.title, $0.mimetype, $0.url, $0.thumbnail ?? "", true) }) }), self.favoriteSections.map({ $0.title }))
                    }
                    else {
                        self.delegate?.assetsLoaded([], [])
                        self.delegate?.showEmptyFavorites()
                    }
                }
                else {
                    if self.files.count == 0 {
                        self.delegate?.assetsLoaded([], [])
                        self.delegate?.showEmpty(nil)
                    }
                    else {
                        self.delegate?.hideEmpty()
                        self.delegate?.assetsLoaded(
                            self.files.map({
                                return $0.map({ return ($0.title, $0.mimetype, $0.url, $0.thumbnail ?? "", self.favorites.contains($0.id)) }) }), self.sections.map({ $0.title }))
                    }
                }
                
            case .failure(let error):
                self.delegate?.showEmpty(error.localizedDescription)
            }
        }
    }
    
    func toggleFavorite(_ index: Int, _ section: Int) {
        let file = self.isFavorites ? self.favoriteFiles[section][index] : self.files[section][index]

        if self.favorites.contains(file.id) {
            Current.unsetFavorite().unset(file.id) { result in
                switch result {
                case .failure(let error):
                    Current.log().error("The file with id \(file.title) could not be unset as a favorite. \(error)")
                    return
                    
                case .success(_):
                    self.fetchAssets(false)
                    self.delegate?.showBanner("Removing \(file.title) from your favorites.")
                }
            }
        }
        else {
            Current.setFavorite().set(file.id) { result in
                switch result {
                case .failure(let error):
                    Current.log().error("The message with id \(file.id) could not be set as a favorite. \(error)")
                    return
                    
                case .success(_):
                    self.fetchAssets(false)
                    self.delegate?.showBanner("Adding \(file.title) to your favorites.")
                }
            }
        }
    }
    
    func selectAsset(_ section: Int, index: Int) {
        let asset = self.isFavorites ? self.favoriteFiles[section][index] : self.files[section][index]

        (self.delegate as? Waitable)?.showSpinner("Loading content for \(asset.title)...")
        Current.collateral().download(Current.base(), String(asset.url.dropFirst())) { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let data):
                let mime = MimeMap.shared
                let pathExtension = mime.pathExtension(forMime: asset.mimetype)
                self.delegate?.fileOpened(WebViewPresenter.init(withData: data, pathExtension, asset.title))

            case .failure(let error):
                Current.log().error("This asset file could not be loaded. \(error)")
                self.delegate?.showBanner(error.localizedDescription)
            }
        }
    }
    
    func toggleFavorites() {
        self.isFavorites = !self.isFavorites
        self.isFavorites ? self.delegate?.favoritesEnabled() : self.delegate?.favoritesDisabled()
        self.fetchAssets(false, true)
    }
    
    // MARK: - Private
}
