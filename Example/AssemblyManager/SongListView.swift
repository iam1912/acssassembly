//
//  SongListView.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/3.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

protocol SongListDelegate: AnyObject {
    func playSpecificallySong(identifient: Int)
}

class SongListView: UIView {
    @IBOutlet weak var vCollection: UICollectionView!
    @IBOutlet weak var vWrap: UIView!
    
    var vContent: UIView!
    var names: [String] = []
    var stores: [String] = []
    var delegate: SongListDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        guard let view = loadViewFromNib() else { return }
        vContent = view
        let nib = UINib(nibName: "AudioSongCell", bundle: nil)
        vCollection.register(nib, forCellWithReuseIdentifier: "AudioSongCell")
        self.addSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        vContent?.frame = self.bounds
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SongListView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @IBAction func close(_ sender: Any) {
        self.close()
    }
    
    func close() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    class func show(win: UIWindow?, stores: [String], names: [String], delegate: SongListDelegate) {
        guard let win = win else { return }
        let contentView = SongListView(frame: CGRect(x: 0, y: 0, width: H.winWidth(), height: H.winHeight()))
        contentView.setData(stores: stores, names: names)
        contentView.delegate = delegate
        win.addSubview(contentView)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { () in
            contentView.frame.origin.y = -70
        })
    }
    
    func setData(stores: [String], names: [String]) {
        self.stores = stores
        self.names = names
        vCollection.reloadData()
        vWrap.layer.cornerRadius = 20
    }
}

extension SongListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: H.winWidth() - 40, height: 40)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = vCollection.dequeueReusableCell(withReuseIdentifier: "AudioSongCell", for: indexPath) as! AudioSongCell
        cell.setData(name: names[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.playSpecificallySong(identifient: indexPath.row)
//        self.close()
    }
}
