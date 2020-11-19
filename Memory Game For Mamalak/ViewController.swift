//
//  ViewController.swift
//  Memory Game For Mamalak
//
//  Created by Edil Ashimov on 5/13/20.
//  Copyright © 2020 Edil Ashimov. All rights reserved.
//

import UIKit
enum gameState {
    case zeroCard
    case oneCard
    case twoCards
    case matched
    case noMatch
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    var collectionView: UICollectionView!
    var allCards:[Card]?
    var matchedImages:[String]?
    var cardOne: String?
    var cardTwo: String?
    var gameLevel = 0
    
    var score = 0 {
        didSet {
            navigationItem.rightBarButtonItems![0].title = "Score is: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score is: \(score)", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Chalkduster", size: 20)!], for: .normal)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "cellID")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        loadLevel(gameLevel) { [weak self] in
            allCards?.shuffle()
            self?.collectionView.reloadData()
        }
        
        
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
        ])
    }
    
    func loadLevel(_ level: Int, completed: () -> Void) {
        
        loadImages {
            switch gameLevel {
            case 0:
                matchedImages?.shuffle()
                var cards = Array<String>()
                for  match in (matchedImages?.prefix(4))! {
                    cards += match.components(separatedBy: "+")
                }
                
                var filtered:Array = [Card]()
                outLoop: for matches in cards {
                    for card in allCards! {
                        if card.name.hasPrefix(matches) {
                            filtered.append(card)
                        }
                    }
                }
                
                //TO DO logic to match the matched names it is not matching now
                allCards = filtered
                filtered.removeAll()
                
            default:
                break
            }
            completed()
        }
    }
    
    func loadImages(finished: () -> Void) {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        allCards = [Card]()
        matchedImages = [String]()
        for item in items  {
            if item.hasSuffix("png") && !item.contains("+")  {
                let card = Card(name: item, image: UIImage(named: item)!)
                allCards?.append(card)
            } else if item.contains("+")  {
                matchedImages?.append(item)
            }
        }
        finished()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCards?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as? CardCell {
            
            let card = allCards?[indexPath.row]
            cell.data = allCards?[indexPath.row]
            
            if card!.isHidden {
                cell.data?.image = UIImage(named: "redCardBackground")!
            } else {
            }
            
            
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        // Handles Flipping and Checking toggle Card isHidden Property
        //TO DO: needs Re-fractoring
        let card = allCards?[indexPath.row]
        if card!.isHidden {
            allCards?[indexPath.row].isHidden.toggle()
            UIView.transition(with: cell, duration: 0.6, options: [.transitionFlipFromRight], animations: {
                collectionView.reloadItems(at: [indexPath])
                cell.contentView.isHidden = true
            }) { (done) in
                cell.contentView.isHidden = false
            }
        } else {
            allCards?[indexPath.row].isHidden.toggle()
            UIView.transition(with: cell, duration: 0.6, options: [.transitionFlipFromRight], animations: {
                collectionView.reloadItems(at: [indexPath])
                cell.contentView.isHidden = true
            }) { (done) in
                cell.contentView.isHidden = false
            }
        }
        
        
        if cardOne == nil {
            cardOne = card?.name
        } else {
            cardTwo = card?.name
            if cardOne != cardTwo {
                var firstIndex:Int!
                for (i, card) in allCards!.enumerated() where card.name == cardOne {
                    firstIndex = i
                }
                if isMatch(cardOne!,with: cardTwo!){
                    changeBgColor(to: IndexPath(row: firstIndex, section: 0), and: indexPath, isMatch: true)
                    allCards = allCards?.filter({$0.name != cardOne && $0.name != cardTwo})
                    score+=1
                    cardOne = nil
                    cardTwo = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                        self?.collectionView.reloadData()
                        guard (self?.allCards!.isEmpty)! else { return }
                        self?.gameOver()
                    }
                } else {
                    //NO MATCH
                    for (i, _) in allCards!.enumerated() {
                        allCards![i].isHidden = true
                    }
                    changeBgColor(to: IndexPath(row: firstIndex, section: 0), and: indexPath, isMatch: false)
                    score-=1
                    cardOne = nil
                    cardTwo = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                        self?.collectionView.reloadItems(at: [IndexPath(row: firstIndex, section: 0), indexPath])
                    }
                }
            } else {
                cardOne = nil
                cardTwo = nil
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.height*0.6/4
        return CGSize(width: width, height: width*1.4)
        
    }
    
    func changeBgColor(to cellOne: IndexPath, and cellTwo: IndexPath, isMatch: Bool) {
        
        let cell = collectionView.cellForItem(at: cellOne)
        let cell2 = collectionView.cellForItem(at: cellTwo)
        
        UIView.animate(withDuration: 0.6, animations: {
            
            if isMatch {
                cell?.contentView.backgroundColor = .green
                cell2?.contentView.backgroundColor = .green
            } else {
                cell?.contentView.backgroundColor = .red
                cell2?.contentView.backgroundColor = .red
            }
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1200)) {
                cell?.contentView.backgroundColor = .white
                cell2?.contentView.backgroundColor = .white
            }
        }
        
    }
    
    func isMatch(_ first: String, with second: String) -> Bool {
        let option1 = "\(first.replacingOccurrences(of: ".png", with: ""))+\(second.replacingOccurrences(of: ".png", with: "")).png"
        let option2 = "\(second.replacingOccurrences(of: ".png", with: ""))+\(first.replacingOccurrences(of: ".png", with: "")).png"
        
        if matchedImages!.contains(option1)  {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.animateResult(option1)
            }
            return true
        } else if matchedImages!.contains(option2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.animateResult(option2)
            }
            return true
        }
        return false
    }
    
    func animateResult(_ imageName: String){
        
        let imageView = UIImageView(frame: CGRect(x: view.center.x-self.view.frame.size.width/8, y: view.center.y-self.view.frame.size.width/8, width: self.view.frame.size.width/4, height: self.view.frame.size.width/4))
        imageView.image = UIImage(named: imageName)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.green
        imageView.layer.cornerRadius = 10
        view.addSubview(imageView)
        
        imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 3, options: [], animations: {
            
            imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (done) in
            UIView.transition(with: imageView, duration: 0.7, options: [.transitionFlipFromRight], animations: {
                imageView.alpha = 0
            })
        }
    }
    func gameOver() {
        
        let ac = UIAlertController(title: "You scored \(score)", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play again", style: .default, handler: {  [weak self] (done) in
            self?.restartTheGame()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac, animated: true)
    }
    
    func restartTheGame()  {
        allCards = nil
        matchedImages = nil
        loadLevel(gameLevel) { [weak self] in
            allCards?.shuffle()
            self?.collectionView.reloadData()
        }
        
    }
}
