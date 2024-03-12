//
//  exportImportSettings.swift
//  winston
//
//  Created by Daniel Inama on 19/10/23.
//

import Foundation

func exportUserDefaultsToJSON(fileName: String) -> String? {
  // Get all UserDefaults keys and values as a dictionary
  let userDefaults = UserDefaults.standard
  let userDefaultsDictionary = userDefaults.dictionaryRepresentation()
  
  // Create a dictionary to hold the serialized values
  var serializedDictionary: [String: Any] = [:]
  
  for (key, value) in userDefaultsDictionary {
    if let date = value as? Date {
      // Convert Date to a string representation
      serializedDictionary[key] = date.iso8601String
    } else {
      // For other types, use the value as is
      serializedDictionary[key] = value
    }
  }
  
  do {
    // Serialize the modified dictionary as JSON data
    let jsonData = try JSONSerialization.data(withJSONObject: serializedDictionary, options: .prettyPrinted)
    
    // Define the file URL where you want to save the JSON file
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let fileURL = documentsDirectory.appendingPathComponent(fileName)
      
      // Write the JSON data to the file
      try jsonData.write(to: fileURL)
      
      print("UserDefaults exported to: \(fileURL.absoluteString)")
      return fileURL.absoluteString
    }
  } catch {
    print("Error exporting UserDefaults to JSON: \(error)")
  }
  
  return nil
}

func importUserDefaultsFromJSON(jsonFilePath: URL) -> Bool {
  // Check if the file exists at the provided path
  let gotAccess = jsonFilePath.startAccessingSecurityScopedResource()
  if !gotAccess {
    print("Can't get file access")
    return false
  }
  do {
    // Read the JSON data from the file
    let jsonData = try Data(contentsOf:jsonFilePath)
    
    // Deserialize the JSON data into a dictionary
    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
      // Iterate through the dictionary and set the values in UserDefaults
      for (key, value) in jsonObject {
        if let dateStr = value as? String,
           let date = Date.dateFromISO8601String(dateStr) {
          UserDefaults.standard.set(date, forKey: key)
        } else {
          UserDefaults.standard.set(value, forKey: key)
        }
      }
      
      // Synchronize UserDefaults to save the changes
      UserDefaults.standard.synchronize()
      
      print("UserDefaults imported from: \(jsonFilePath)")
      jsonFilePath.stopAccessingSecurityScopedResource()
      return true
    }
  } catch {
    print("Error importing UserDefaults from JSON: \(error)")
    jsonFilePath.stopAccessingSecurityScopedResource()
  }
  return false
}

// Extension to convert Date to ISO8601 string
extension Date {
  var iso8601String: String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: self)
  }
}

// Extension to convert ISO8601 string to Date
extension Date {
  static func dateFromISO8601String(_ iso8601String: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: iso8601String)
  }
}
