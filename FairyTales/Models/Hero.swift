//
//  Hero.swift
//  FairyTales
//
//  Created by Assistant on 27/08/2025.
//

import Foundation

// MARK: - Hero Data Models
struct Hero: Codable, Identifiable, Hashable {
    let id: String?
    let user_id: String?
    let name: String
    let gender: String
    let age: Int
    let appearance: String?
    let personality: String?
    let power: String?
    let avatar_image: String?
    let created_at: String?
    let updated_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id = "user_id"
        case name
        case gender
        case age
        case appearance
        case personality
        case power
        case avatar_image = "avatar_image"
        case created_at = "created_at"
        case updated_at = "updated_at"
    }
}

// MARK: - Hero Creation Request
struct HeroCreateRequest: Codable {
    let name: String
    let gender: String
    let age: Int
    let appearance: String?
    let personality: String?
    let power: String?
    let avatar_image: String?
}

// MARK: - Hero Update Request
struct HeroUpdateRequest: Codable {
    let name: String
    let gender: String
    let age: Int
    let appearance: String?
    let personality: String?
    let power: String?
    let avatar_image: String?
}

// MARK: - Hero Response Models
struct HeroResponse: Codable {
    let success: Bool
    let message: String?
    let data: Hero?
}

// MARK: - Heroes List Models
struct HeroesListResponse: Codable {
    let success: Bool
    let message: String?
    let data: HeroesListData?
}

struct HeroesListData: Codable {
    let heroes: [Hero]
    let total: Int?
    let skip: Int?
    let limit: Int?
}

// MARK: - Delete Hero Models
struct DeleteHeroResponse: Codable {
    let success: Bool
    let message: String?
}

// MARK: - Hero Enums
enum HeroGender: String, CaseIterable {
    case male = "boy"
    case female = "girl"
    
    var localizedName: String {
        switch self {
        case .male:
            return "boy".localized
        case .female:
            return "girl".localized
        }
    }
}

enum HeroAvatarImage: String, CaseIterable {
    case knight = "knight"
    case princess = "princess"
    case wizard = "wizard"
    case archer = "archer"
    case healer = "healer"
    case dragon = "dragon"
    case fairy = "fairy"
    
    var systemIcon: String {
        switch self {
        case .knight:
            return "shield.fill"
        case .princess:
            return "crown.fill"
        case .wizard:
            return "wand.and.rays"
        case .archer:
            return "arrow.up.right.circle.fill"
        case .healer:
            return "heart.fill"
        case .dragon:
            return "flame.fill"
        case .fairy:
            return "sparkles"
        }
    }
    
    var localizedName: String {
        switch self {
        case .knight:
            return "Knight"
        case .princess:
            return "Princess"
        case .wizard:
            return "Wizard"
        case .archer:
            return "Archer"
        case .healer:
            return "Healer"
        case .dragon:
            return "Dragon"
        case .fairy:
            return "Fairy"
        }
    }
    
    var gender: HeroGender? {
        switch self {
        case .knight, .wizard, .archer:
            return .male
        case .princess, .healer, .fairy:
            return .female
        case .dragon:
            return nil // Neutral - available for both
        }
    }
    
    static func avatarsForGender(_ gender: HeroGender) -> [HeroAvatarImage] {
        return HeroAvatarImage.allCases.filter { avatar in
            avatar.gender == gender || avatar.gender == nil
        }
    }
}