//
//  CityModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct CityModel: Codable {
	var cityCode: Int
	var title: String
	var titleEn: String
	var countryCode: Int

	init(cityObject: CityObject) {
		self.title = cityObject.title ?? ""
		self.titleEn = cityObject.titleEn ?? ""
		self.cityCode = Int(cityObject.cityCode)
		self.countryCode = Int(cityObject.countryCode)
	}
}
