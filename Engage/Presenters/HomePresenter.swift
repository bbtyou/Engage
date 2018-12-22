//
//  HomePresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

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
    
    // - Marquee timer
    fileprivate var dailyUpdateTimer: Timer?
    
    deinit {
        log.verbose("** Deallocated \(HomePresenter.self).")
        self.dailyUpdateTimer?.invalidate()
    }
    
    func fetchDailyUpdates() {
        let dataSource = PortalDataSource.init()
        
        dataSource.fetchMarquee { (marquee, error) in
            if let error = error {
                log.error("The daily inspiration could not be loaded. \(error)")
                return
            }
            
            guard let updates = marquee?.text, updates.count > 0 else {
                log.debug("There were no daily quotes to update.")
                return
            }
            
            guard let dailyUpdates = marquee?.text, let delayString = marquee?.delay, let delayInt = Int(delayString) else {
                log.debug("Daily updates could not be displayed due to missing information.")
                return
            }
            
            var updateIndex = 0
            self.dailyUpdateTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(delayInt), repeats: true, block: { [weak self] (timer) in
                guard let self = self else {
                    timer.invalidate()
                    return
                }

                if updateIndex >= dailyUpdates.count {
                    updateIndex = 0
                }

                self.delegate?.marqueeUpdated(dailyUpdates[updateIndex])
                updateIndex += 1
            })
        }
    }
    
    func fetchAssets(_ showSpinner: Bool = true) {
        let dataSource = PortalDataSource.init()
        
        if showSpinner {
            self.delegate?.showSpinner("Loading tools and assets...")
        }
        
        self.filesBySection.removeAll()
        self.sections.removeAll()
        
        dataSource.fetchCategories { (categories, error) in
            self.delegate?.hideSpinner()

            if let e = error {
                self.delegate?.showEmpty(e.localizedDescription)
                return
            }
            
            // - Fetch the favorites
            if showSpinner {
                self.delegate?.showSpinner("Updating favorites...")
            }
            
            dataSource.fetchFavorites({ (favorites, error) in
                self.delegate?.hideSpinner()
                
                if let e = error {
                    log.warning("The favorites could not be retrieved. \(e)")
                }
                else {
                    self.favorites = favorites
                }
                
                // - Filter out only categories
                let sections = categories.filter({ (category) -> Bool in
                    return category.files.count > 0
                })
                
                if sections.count == 0 {
                    self.delegate?.showEmpty(nil)
                    return
                }
                
                sections.forEach({ (section) in
                    self.sections.append(section.title)
                    self.filesBySection.append(section.files)
                })

                // - Load the favorites
                self.loadFavorites()

                if self.isFavorites {
                    self.toggleFavorites(true)
                }
                else {
                    // - Update the view with the assets and section names
                    self.delegate?.assetsLoaded(self.filesBySection.map({ (fileArray) -> [Asset] in
                        return fileArray.map({ (file) -> Asset in
                            let isFavorite = self.favorites.contains(where: { (favorite) -> Bool in
                                return favorite.id == file.id
                            })
                            
                            return (file.title, file.mimetype, URL.init(string: file.url), file.thumbnail, isFavorite)
                        })
                    }), self.sections)
                }
            })
        }
    }
    
    func toggleFavorite(_ index: Int, _ section: Int) {
        // - Get the files based on whether favorites are enabled or not
        let files = self.isFavorites ? self.favoritesBySection : self.filesBySection

        let file = files[section][index]
        let isFavorite = self.favorites.contains { (favorite) -> Bool in
            return favorite.id == file.id
        }
        
        let request: Request = isFavorite ? UnsetFavoriteRequest.init(unid: file.id) : SetFavoriteRequest.init(unid: file.id)
        
        self.delegate?.showBanner(isFavorite ? "Removing \(file.title) from favorites." : "Adding \(file.title) to favorites.")
        request.sendRequest { (response, data, error) in
            if let error = error {
                log.warning("The message with id \(file.id) could not be set as a favorite. \(error)")
                return
            }
            
            // - Update the view to display the favorite properly
            self.fetchAssets(false)
        }
    }
    
    func selectAsset(_ section: Int, index: Int) {
        let asset = self.isFavorites ? self.favoritesBySection[section][index] : self.filesBySection[section][index]

        self.delegate?.showSpinner("Loading content for \(asset.title)...")
        
        let dataSource = AssetFileDataSource.init()
        dataSource.fetchAsset(fromModel: asset) { (data, error) in
            self.delegate?.hideSpinner()
            
            if let error = error {
                log.error("The asset file could not be loaded. \(error)")
                // Show error
                return
            }
            
            guard let data = data else {
                // - Display an error
                return
            }
            
            // - Get the path extension for the mimetype
            let mime = MimeMap.shared
            let pathExtension = mime.pathExtension(forMime: asset.mimetype)
            
            self.delegate?.fileOpened(WebViewPresenter.init(withData: data, pathExtension, asset.title))
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

                    return (file.title, file.mimetype, URL.init(string: file.url), file.thumbnail, isFavorite)
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

                    return (file.title, file.mimetype, URL.init(string: file.url), file.thumbnail, isFavorite)
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
