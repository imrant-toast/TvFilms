//
//  StorageManager.swift
//  TvFilms
//
//  Created by Малиль Дугулюбгов on 20.03.2022.
//

import UIKit
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    //MARK: Properties
    
    private let context: NSManagedObjectContext?
    
    //MARK: - Initialization

    private init() {
        context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    //MARK: - Methods
    
    func save(_ title: TitleModel, completion: ((_ isAdded: Bool) -> Void)?) {
        
        findObjectInStorage(title) { storedTitle in
            guard
                storedTitle == nil,
                let context = self.context,
                let entityDescription = NSEntityDescription.entity(forEntityName: "TitleStorageModel", in: context),
                let item = NSManagedObject(entity: entityDescription, insertInto: context) as? TitleStorageModel
            else {
                completion?(false)
                return
            }
            
            item.id = Int64(title.id)
            item.name = title.name
            item.backdrop_path = title.backdrop_path
            item.poster_path = title.poster_path
            item.original_title = title.original_title
            item.original_name = title.original_name
            item.overview = title.overview
            item.vote_average = title.vote_average ?? 0

            if context.hasChanges {
                do {
                    try context.save()
                    completion?(true)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchData(_ completion: @escaping (Result<[TitleStorageModel], Error>) -> Void) {
        guard let context = context else { return }
        let request: NSFetchRequest<TitleStorageModel> = TitleStorageModel.fetchRequest()
        do {
            let fetchedTitles = try context.fetch(request)
            completion(.success(fetchedTitles))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func delete(_ title: TitleStorageModel) {
        guard let context = context else { return }
        context.delete(title)
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteAll() {
        guard let context = context else { return }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TitleStorageModel")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Private methods
    
    private func findObjectInStorage(_ title: TitleModel, completion: @escaping (TitleStorageModel?) -> Void) {
        guard let context = context else { return }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TitleStorageModel")
        fetchRequest.predicate = NSPredicate(format: "overview = %@", title.overview ?? "")
        
        do {
            guard let results = try context.fetch(fetchRequest) as? [NSManagedObject] else { return }
            if !results.isEmpty {
                guard
                    let storedTitle = results.first as? TitleStorageModel,
                    storedTitle.name == title.name,
                    storedTitle.original_name == title.original_name,
                    storedTitle.original_title == title.original_title
                else { return }
                print(storedTitle)
                completion(storedTitle)
            } else {
                completion(nil)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
