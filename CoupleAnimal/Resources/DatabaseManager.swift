//
//  DatabaseManager.swift
//  CoupleAnimal
//
//  Created by Nikita on 7.02.23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

extension DatabaseManager {
    
    public func updateUser(user: UserModel) {
        database.child("users").child(user.safeEmail).updateChildValues([
            "nickname" : user.nickname,
            "breed" : user.species,
            "location" : user.location,
            "weight" : user.weight,
            "height" : user.height
        ])
    }
    /// read user data
    public func readUser(email: String, complition: @escaping(([String : Any]) -> Void)) {
            var safeEmail = email.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child("users").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
             guard (snapshot.value != nil) else { return }
            if let info = snapshot.value as? [String:Any] {
                complition(info)
            }
        }
    }
    
    ///read country
   
    public func readCountry(completion: @escaping(Result<[String:Any], Error>) -> Void) {

        database.child("country").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String:Any] else {
                completion(.failure(DatabaseError.failedToReturn))
                return
            }
            completion(.success(value))
        }
    }
    
    public func readCity(nameCountry: String, completion: @escaping(Result<[String:Any], Error>) -> Void) {
        database.child("country").child(nameCountry).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String:Any] else {
                completion(.failure(DatabaseError.failedToReturn))
                return
            }
            completion(.success(value))
        }
    }
    /// search if user exist
    public func isUserExists(email: String, complition: @escaping ((Bool) -> Void)) {

        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        database.child("users").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                complition(false)
                return
            }
            complition(true)
        }
    }
    
    ///  Inserts new user to the database
    public func inserUser(user: UserModel) {
        database.child("users").child(user.safeEmail).setValue([
            "name" : user.name,
            "id" : user.id,
            "fullRegister" : user.isFillingTheData
        ])
        //DefaultsManager.userID = user.id
        DefaultsManager.safeEmail = user.safeEmail
    }
    /// update user
    public func addAditionalInfo(user: UserModel, complition: @escaping(Bool) -> Void) {
        
        
        database.child("users").child(user.safeEmail).updateChildValues([
            "nickname" : user.nickname,
            "breed" : user.species,
            "animal" : user.animal,
            "location" : user.location,
            "weight" : user.weight,
            "height" : user.height,
            "info" : user.additionalInfo,
            "age" : user.age,
            "id" : user.id,
            "gender" : user.gender,
            "additionalInfo" : user.additionalInfo,
            "species" : user.species,
            "fullRegister" : user.isFillingTheData
        ], withCompletionBlock: { error, _ in
            guard  error == nil else {
                complition(false)
                return
            }
            DefaultsManager.safeEmail = user.safeEmail
            complition(true)
        })
    }
    
    public func getAllUsers(completion: @escaping(Result<[String:Any], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String:Any] else {
                completion(.failure(DatabaseError.failedToReturn))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DatabaseError:Error {
        case failedToReturn
    }

}
