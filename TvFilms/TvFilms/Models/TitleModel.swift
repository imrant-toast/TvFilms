//
//  TitleModel.swift
//  TvFilms
//
//  Created by Малиль Дугулюбгов on 16.03.2022.
//

import Foundation

struct TitlesResponse: Decodable {
    let results: [TitleModel]?
    let total_pages: Int?
}

struct TitleModel: Decodable {
    let id: Int
    let name: String?
    let media_type: String?
    let original_name: String?
    let original_title: String?
    let poster_path: String?
    let backdrop_path: String?
    let overview: String?
    let vote_average: Double?
}
