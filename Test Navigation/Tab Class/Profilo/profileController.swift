//
//  openedProfile.swift
//  Test Navigation
//
//  Created by Marius Lazar on 26/01/2019.
//  Copyright © 2019 Marius Lazar. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseAuth
import FirebaseDatabase

class profileController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var lblColor: UILabel = {
        var lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.backgroundColor = UIColor(r: 22, g: 147, b: 162)
        lbl.isEnabled = true
        return lbl
    }()
    
    lazy var imgProfile: UIImageView = {
        var img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var cosmosView: CosmosView = {
        var cosmos = CosmosView()
        cosmos.translatesAutoresizingMaskIntoConstraints = false
        cosmos.settings.updateOnTouch = false
        cosmos.settings.textColor = .white
        cosmos.settings.totalStars = 5
        cosmos.rating = 0
        cosmos.settings.fillMode = .precise
        cosmos.settings.filledColor = .white
        cosmos.settings.filledBorderColor = .white
        cosmos.settings.emptyBorderColor = .white
        return cosmos
    }()
    
    let segmentControl: UISegmentedControl = {
        var sc = UISegmentedControl()
        let item = ["CRONOLOGIA", "FEEDBACK"]
        sc = UISegmentedControl(items: item)
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 0
        sc.layer.borderColor = UIColor(r: 22, g: 147, b: 162).cgColor
        sc.layer.borderWidth = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        let attributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        let attributesSelected = [NSAttributedString.Key.foregroundColor: UIColor(r: 22, g: 147, b: 162), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        sc.setTitleTextAttributes(attributesNormal, for: .normal)
        sc.setTitleTextAttributes(attributesSelected, for: .selected)
        sc.addTarget(self, action: #selector(handleCF), for: .valueChanged)
        return sc
    }()
    
    let cellID = "cellMyProf"
    
    lazy var myTable: UITableView = {
        var tbl = UITableView()
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.delegate = self
        tbl.dataSource = self
        tbl.rowHeight = 150
        tbl.register(myProfileCell.self, forCellReuseIdentifier: cellID)
        return tbl
    }()
    
    let userID = Auth.auth().currentUser!.uid
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor(r: 22, g: 147, b: 162)
        navigationItem.title = "Profilo"
        view.addSubview(lblColor)
        
        lblColor.addSubview(imgProfile)
        lblColor.addSubview(cosmosView)
        view.addSubview(segmentControl)
        view.addSubview(myTable)
        
        imgProfile.image = UIImage(named: self.userID)
        
        downloadFeedback()
        downloadArray()
        handleCF()
        configureConstraints()
    }
    
    let dataBase = Database.database().reference(fromURL: "https://banca-del-tempo-aa402.firebaseio.com")
    var postInt: Int?
    
    
    var jsonFeedback: [infoUsers] = []
    var jsonDownload: [download] = []
    
    func downloadArray()
    {
        self.view.showBlurLoader()
        dataBase.child("Post").observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any]
            {
                self.view.removeBluerLoader()
                var fetchArray: [download] = []
                for element in dictionary
                {
                    
                    let value = element.value as? [String: Any]
                    
                    let post = download(cambioOra: self.castToBool(value: value?["cambio ora"] as? String), categoria: value!["categoria"] as? String, descrizione: value?["descrizione"] as? String, feedbackRilasciatoBoss: self.castToBool(value: value?["feedback rilasciato boss"] as? String), luogo: value?["luogo"] as? String, minuti: value?["minuti"] as? Int, ore: value?["ore"] as? Int, postAssegnato: self.castToBool(value: value?["post assegnato"] as? String), terminaDaBoss: self.castToBool(value: value?["termina da boss"] as? String), richiestaofferta: value?["richiestaofferta"] as? String, terminaDaUtente: self.castToBool(value: value?["termina utente help"] as? String), titolo: value?["titolo"] as? String, idBoss: value?["utente boss"] as? String, idPost: value?["idPost"] as? Int, proposte: value?["proposte"] as? String, feedbackRilasciatoHelper: self.castToBool(value: value?["feedback rilasciato helper"] as? String))
                    
                    fetchArray.append(post)
 
                }
                self.jsonDownload = fetchArray
                self.myTable.reloadData()
                
            }
            else
            {
                self.view.removeBluerLoader()
                debugPrint("errore")
            }
        }
    }
    
    func castToBool (value: String?) -> Bool? {
        let string = value?.lowercased()
        
        switch string {
        case "false":
            return false
        case "true":
            return true
        default:
            return nil
        }
    }
    
    func downloadFeedback()
    {
        dataBase.child("Utenti").child(self.userID).child("feedback").observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any]
            {
                var fetchArray: [infoUsers] = []
                for element in dictionary
                {
                    
                    let value = element.value as? [String: Any]
                    
                    let post = infoUsers(stars: value?["numero stelle"] as? Double, descrizione: value?["descrizione"] as? String)
                    fetchArray.append(post)
                    
                    
                }
                self.jsonFeedback = fetchArray
                self.myTable.reloadData()
                
            }
            else
            {
                debugPrint("errore")
            }
        }
    }

    @objc func handleCF()
    {
        myTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            return jsonDownload.count
        default:
            return jsonFeedback.count
        }
    }
    
    var totalStart: [Double] = []
    {
        didSet
        {
            var tot = 0.0
            for value in totalStart
            {
                tot = tot + value
            }
            tot = tot/Double(totalStart.count)
            cosmosView.rating = tot
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! myProfileCell
        
        cell.imageFeedback.image = nil
        
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            let post = jsonDownload[indexPath.row]
            cell.start.alpha = 0
            cell.imageFeedback.image = UIImage(named: post.idBoss!)
            cell.descrizione.text = post.descrizione
            cell.titolo.alpha = 1
            cell.oreMinuti.alpha = 1
            cell.titolo.text = post.titolo
            let ore = post.ore
            let minuti = post.minuti
            if minuti == 5 || minuti == 0
            {
                cell.oreMinuti.text = "0\(ore ?? 00):0\(minuti ?? 00)h"
            }
            else
            {
                cell.oreMinuti.text = "0\(ore ?? 00):\(minuti ?? 00)h"
            }
            
        default:
            let post = jsonFeedback[indexPath.row]
            cell.descrizione.text = post.descrizione
            cell.start.alpha = 1
            cell.titolo.alpha = 0
            cell.oreMinuti.alpha = 0
            cell.start.rating = post.stars!
            totalStart.append(post.stars!)
            if self.userID == "RtvEIHrdBXWfddMLletlSDbMqcc2"
            {
                cell.imageFeedback.image = UIImage(named: "PtXGYG1Qx7gheDkehkiZmJAaOuy1")
            }
            else
            {
                cell.imageFeedback.image = UIImage(named: "RtvEIHrdBXWfddMLletlSDbMqcc2")
            }
        }
        
       
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func configureConstraints()
    {
        lblColor.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        lblColor.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lblColor.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lblColor.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        imgProfile.centerYAnchor.constraint(equalTo: lblColor.centerYAnchor).isActive = true
        imgProfile.leftAnchor.constraint(equalTo: lblColor.leftAnchor, constant: 16).isActive = true
        imgProfile.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imgProfile.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        cosmosView.leftAnchor.constraint(equalTo: imgProfile.rightAnchor, constant: 16).isActive = true
        cosmosView.centerYAnchor.constraint(equalTo: imgProfile.centerYAnchor, constant: -32).isActive = true
        
        segmentControl.topAnchor.constraint(equalTo: lblColor.bottomAnchor).isActive = true
        segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        segmentControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        myTable.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 1).isActive = true
        myTable.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        myTable.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        
    }
    
}