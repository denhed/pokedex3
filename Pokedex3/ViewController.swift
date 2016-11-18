//
//  ViewController.swift
//  Pokedex3
//
//  Created by Dennis Hedlund on 2016-11-17.
//  Copyright © 2016 Dennis Hedlund. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var musicPlayer: AVAudioPlayer!
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        searchBar.delegate = self
        
        //ändra namn på keyboard
        searchBar.returnKeyType = UIReturnKeyType.done
        
        parsePokemonCSV()
        initAudio()
    }
    
    func initAudio() {
        
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do {
            
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1 // loops
            musicPlayer.play()
        
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func parsePokemonCSV() {
        
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            // gör om data till en dictionary som json
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            print(rows)
            
            for row in rows {
                
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, pokedexId: pokeId)
                pokemon.append(poke)
            }
            
        } catch let err as NSError {
            
            print(err.debugDescription)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // vi kan inte skapa 700 celler utan återanvänd celler som inte syns.
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            //let pokemon = Pokemon(name: "Pokemon", pokedexId: indexPath.row)
            
            
            let poke: Pokemon!
            
            if inSearchMode {
            
                poke = filteredPokemon[indexPath.row]
                cell.configureCell(pokemon: poke)
                
            } else {
                poke = pokemon[indexPath.row]
                cell.configureCell(pokemon: poke)
            }

            return cell
        } else {
            
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        var poke: Pokemon!
        
        if inSearchMode {
            
            poke = filteredPokemon[indexPath.row]
        } else {
            
            poke = pokemon[indexPath.row]
        }
        
        performSegue(withIdentifier: "PokemonDetailsVC", sender: poke)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            
            return filteredPokemon.count
        }
        
        return pokemon.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // imagesize on storyboard
        return CGSize(width: 105, height: 105)
    }
    
    @IBAction func musicBtnPressed(_ sender: UIButton) {
       
        if musicPlayer.isPlaying {
            musicPlayer.pause()
            sender.alpha = 0.2
            
            
        } else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            collection.reloadData()
            
            //för att dölja keyboard 
            view.endEditing(true)
            
            
        } else {
            
            inSearchMode = true
            
            let lower = searchBar.text!.lowercased()
            
            // $0 is placeholder for a pokemon.
            // om sök texten finn i range dvs inte är nil så retuneras den.
            filteredPokemon = pokemon.filter({$0.name.range(of: lower) != nil})
            
            collection.reloadData()
            
        }
        
    }
    
    //förbereder så vi kan skicka data mellan vc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonDetailsVC" {
        
            if let detailsVC = segue.destination as? PokemonDetailsVC {
            
                if let poke = sender as? Pokemon {
                    // detailsVC.pokemon är den var vi har i PokemonDetailsVC var pokemon: Pokemon!
                    // vi tilldelar den vår pokemon som vi skickar.
                    detailsVC.pokemon = poke
                }
            }
        }
    }
    
}

