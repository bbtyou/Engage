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
    
    // - All assets by section
    fileprivate var filesBySection = [[File]]()
    
    // - All sections in order
    fileprivate var sections = [String]()
    
    // - Favorites toggle
    fileprivate var isFavorites: Bool = false
    
    // - Favorite identifiers
    fileprivate var favorites = [Favorite]()
    
    // - Favorites files
    fileprivate var favoritesBySection = [[File]]()
    
    // - Favorites sections
    fileprivate var favoritesSections = [String]()
    
    deinit {
        Current.log().verbose("** Deallocated \(HomePresenter.self).")
    }
    
    func fetchAssets(_ showSpinner: Bool = true) {
        if showSpinner {
            (self.delegate as? Waitable)?.showSpinner("Loading collateral...")
        }
        
        self.filesBySection.removeAll()
        self.sections.removeAll()
        
        Current.main().portal(false) { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let portal):
                self.favorites = portal.favorites
                
                let sections = portal.categories.filter({ $0.files.count > 0 })
                if sections.count == 0 {
                    self.delegate?.showEmpty(nil)
                    return
                }
                
                self.sections = sections.map({ $0.title })
                self.filesBySection = sections.map({ $0.files })
                self.loadFavorites()
                
                if self.isFavorites {
                    self.toggleFavorites(true)
                }
                else {
                    self.delegate?.hideEmpty()
                    self.delegate?.assetsLoaded(self.filesBySection.map({ (fileArray) -> [Asset] in
                        return fileArray.map({ (file) -> Asset in
                            let isFavorite = self.favorites.contains(where: { (favorite) -> Bool in
                                return favorite.id == file.id
                            })
                            
                            return (file.title, file.mimetype, file.url, file.thumbnail ?? "", isFavorite)
                        })
                    }), self.sections)
                }
                
            case .failure(let error):
                self.delegate?.showEmpty(error.localizedDescription)
            }
        }
    }
    
    func toggleFavorite(_ index: Int, _ section: Int) {
        // - Get the files based on whether favorites are enabled or not
        let files = self.isFavorites ? self.favoritesBySection : self.filesBySection

        let file = files[section][index]
        let isFavorite = self.favorites.contains { (favorite) -> Bool in
            return favorite.id == file.id
        }
        
        self.delegate?.showBanner(isFavorite ? "Removing \(file.title) from favorites." : "Adding \(file.title) to favorites.")
        if isFavorite {
            Current.unsetFavorite().unset(file.id) { result in
                switch result {
                case .failure(let error):
                    Current.log().error("The file with id \(file.title) could not be unset as a favorite. \(error)")
                    return
                    
                case .success(_):
                    self.fetchAssets(false)
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
                }
            }
        }
    }
    
    func selectAsset(_ section: Int, index: Int) {
        let asset = self.isFavorites ? self.favoritesBySection[section][index] : self.filesBySection[section][index]
        (self.delegate as? Waitable)?.showSpinner("Loading content for \(asset.title)...")
        
        Current.collateral().download(Current.base(), asset.url) { result in
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
        self.toggleFavorites(!self.isFavorites)
    }
    
    // MARK: - Private

    fileprivate func loadFavorites() {
        // - Filter favorites
        var sectionIndex = 0
        
        self.favoritesSections.removeAll()
        self.favoritesBySection.removeAll()
        
        self.filesBySection.forEach { (section) in
            let files = section.filter({ (file) -> Bool in
                return self.favorites.contains(where: { (favorite) -> Bool in
                    favorite.id == file.id
                })
            })
            
            if files.count > 0 {
                self.favoritesBySection.append(files)
                self.favoritesSections.append(self.sections[sectionIndex])
            }
            
            sectionIndex += 1
        }
    }
    
    fileprivate func toggleFavorites(_ enabled: Bool) {
        if !enabled {
            self.delegate?.assetsLoaded(self.filesBySection.map({ (fileArray) -> [Asset] in
                return fileArray.map({ (file) -> Asset in
                    let isFavorite = self.favorites.contains(where: { (favorite) -> Bool in
                        return favorite.id == file.id
                    })

                    return (file.title, file.mimetype, file.url, file.thumbnail ?? "", isFavorite)
                })
            }), self.sections)
            
            self.isFavorites = false
            self.delegate?.favoritesDisabled()
        }
        else {
            self.delegate?.assetsLoaded(self.favoritesBySection.map({ (fileArray) -> [Asset] in
                return fileArray.map({ (file) -> Asset in
                    let isFavorite = self.favorites.contains(where: { (favorite) -> Bool in
                        return favorite.id == file.id
                    })

                    return (file.title, file.mimetype, file.url, file.thumbnail ?? "", isFavorite)
                })
            }), self.favoritesSections)

            if self.favorites.count == 0 {
                self.delegate?.showEmptyFavorites()
            }

            self.isFavorites = true
            self.delegate?.favoritesEnabled()
        }
    }
}
