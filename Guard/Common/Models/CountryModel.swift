//
//  CountryModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct CountryModel: Codable {
	var countryCode: Int
	var title: String
	var titleEn: String
	var locale: String
	var cities: [CityModel]
}
