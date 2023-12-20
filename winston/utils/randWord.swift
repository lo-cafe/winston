//
//  randWord.swift
//  winston
//
//  Created by Igor Marcossi on 08/09/23.
//

import Foundation

func randomWord(wordLength: Int = 6) -> String {
  
  let kCons = 1
  let kVows = 2
  
  var cons: [String] = [
    // single consonants. Beware of Q, it"s often awkward in words
    "b", "c", "d", "f", "g", "h", "j", "k", "l", "m",
    "n", "p", "r", "s", "t", "v", "w", "x", "z",
    // possible combinations excluding those which cannot start a word
    "pt", "gl", "gr", "ch", "ph", "ps", "sh", "st", "th", "wh"
  ]
  
  // consonant combinations that cannot start a word
  let cons_cant_start: [String] = [
    "ck", "cm",
    "dr", "ds",
    "ft",
    "gh", "gn",
    "kr", "ks",
    "ls", "lt", "lr",
    "mp", "mt", "ms",
    "ng", "ns",
    "rd", "rg", "rs", "rt",
    "ss",
    "ts", "tch"
  ]
  
  let vows : [String] = [
    // single vowels
    "a", "e", "i", "o", "u", "y",
    // vowel combinations your language allows
    "ee", "oa", "oo",
  ]
  
  // start by vowel or consonant ?
  var current = (Int(arc4random_uniform(2)) == 1 ? kCons : kVows );
  
  var word : String = ""
  while ( word.count < wordLength ){
    // After first letter, use all consonant combos
    if word.count == 2 {
      cons = cons + cons_cant_start
    }
    
    // random sign from either $cons or $vows
    var rnd: String = "";
    var index: Int;
    if current == kCons {
      index = Int(arc4random_uniform(UInt32(cons.count)))
      rnd = cons[index]
    }else if current == kVows {
      index = Int(arc4random_uniform(UInt32(vows.count)))
      rnd = vows[index]
    }
    
    // check if random sign fits in word length
    let tempWord = "\(word)\(rnd)"
    if( tempWord.count <= wordLength ) {
      word = "\(word)\(rnd)"
      // alternate sounds
      current = ( current == kCons ) ? kVows : kCons;
    }
  }
  
  return word
}
