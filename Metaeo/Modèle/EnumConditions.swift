//
//  EnumConditions.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-30.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

enum Condition: String {
  // utilisées à la fois dans les conditions actuelles et les prévisions d'Environnement Canada
  case sunny = "sunny"
  case cloudy = "cloudy"
  case mostlyCloudy = "mostly cloudy"
  case rain = "rain"
  case freezingRain = "freezing rain"
  case flurries = "flurries"
  case lightSnow = "light snow"
  case snow = "snow"
  case fog = "fog"
  case fogPatches = "fog patches"
  case haze = "haze"
  case iceFog = "ice fog"
  case drizzle = "drizzle"
  case freezingDrizzle = "freezing drizzle"
  case clear = "clear"
  case windy = "windy"
  case smoke = "smoke"
  
  // utilisées uniquement dans les conditions actuelles d'Environnement Canada
  case mainlySunny = "mainly sunny"
  case partlyCloudy = "partly cloudy"
  case lightRainShower = "light rain shower"
  case lightRainShowerAndFlurries = "light rain shower and flurries"
  case lightFlurries = "light flurries"
  case precipitation = "precipitation"
  case squalls = "squalls"
  case lightPrecipitation = "light precipitation"
  case heavyPrecipitation = "heavy precipitation"
  case rainShower = "rain shower"
  case lightRainAndDrizzle = "light rain and drizzle"
  case lightRain = "light rain"
  case rainAndDrizzle = "rain and drizzle"
  case heavyRainAndDrizzle = "heavy rain and drizzle"
  case heavyRainShower = "heavy rain shower"
  case heavyRain = "heavy rain"
  case lightFreezingDrizzle = "light freezing drizzle"
  case lightFreezingRain = "light freezing rain"
  case heavyFreezingDrizzle = "heavy freezing drizzle"
  case heavyFreezingRain = "heavy freezing rain"
  case rainAndFlurries = "rain and flurries"
  case rainAndSnow = "rain and snow"
  case lightRainAndSnow = "light rain and snow"
  case heavyRainShowerAndFlurries = "heavy rain shower and flurries"
  case heavyRainAndSnow = "heavy rain and snow"
  case heavyFlurries = "heavy flurries"
  case heavySnow = "heavy snow"
  case thunderstormWithRain = "thunderstorm with rain"
  case thunderstormWithHeavyRain = "thunderstorm with heavy rain"
  case thunderstormWithLightRain = "thunderstorm with light rain"
  case thunderstorm = "thunderstorm"
  case heavyThunderstormWithRain = "heavy thunderstorm with rain"
  case heavyThunderstorm = "heavy thunderstorm"
  case shallowFog = "shallow fog"
  case mist = "mist"
  case driftingSnow = "drifting snow"
  case iceCrystals = "ice crystals"
  case snowPellets = "snow pellets"
  case icePellets = "ice pellets"
  case hail = "hail"
  case snowGrains = "snow grains"
  case lightDrizzle = "light drizzle"
  case heavyDrizzle = "heavy drizzle"
  case mainlyClear = "mainly clear"
  case blowingSnow = "blowing Snow"
  case funnelCloud = "funnel cloud"
  case tornado = "tornado"
  case dustDevils = "dust devils"
  case dustStorm = "dust storm"
  case volcanicAsh = "volcanic ash"
  case blowingDust = "blowing dust"
  case sandstorm = "sandstorm"
  case driftingDust = "drifting dust"
  case thunderstormWithHail = "thunderstorm with hail"
  case heavyThunderstormWithHail = "heavy thunderstorm with hail"
  case thunderstormWithBlowingDust = "thunderstorm with blowing dust"
  case thunderstormWithDustStorm = "thunderstorm with dust storm"
  case waterspout = "waterspout"
  
  // utilisées uniquement dans les prévisions d'Environnement Canada
  case aFewClouds = "a few clouds"
  case aMixOfSunAndCloud = "a mix of sun and cloud"
  case cloudyPeriods = "cloudy periods"
  case sunnyWithCloudyPeriods = "sunny with cloudy periods"
  case cloudyWithSunnyPeriods = "cloudy with sunny periods"
  case increasingCloudiness = "increasing cloudiness"
  case clearing = "clearing"
  case chanceOfShowers = "chance of showers"
  case aFewShowers = "a few showers"
  case chanceOfDrizzleOrRain = "chance of drizzle or rain"
  case aFewFlurriesOrRainShowers = "a few flurries or rain showers"
  case chanceOfFlurriesOrRainShowers = "chance of flurries or rain showers"
  case aFewFlurries = "a few flurries"
  case chanceOfFlurries = "chance of flurries"
  case aFewWetFlurries = "a few wet flurries"
  case chanceOfShowersAtTimesHeavyOrThundershowers = "chance of showers at times heavy or thundershowers"
  case chanceOfShowersAtTimesHeavyOrThunderstorms = "chance of showers at times heavy or thunderstorms"
  case chanceOfThundershowers = "chance of thundershowers"
  case chanceOfThunderstorms = "chance of thunderstorms"
  case chanceOfShowersOrThundershowers = "chance of showers or thundershowers"
  case chanceOfShowersOrThunderstorms = "chance of showers or thunderstorms"
  case aFewFlurriesOrThundershowers = "a few flurries or thundershowers"
  case overcast = "overcast"
  case showers = "showers"
  case periodsOfRain = "periods of rain"
  case rainAtTimesHeavy = "rain at times heavy"
  case aFewShowersOrDrizzle = "a few showers or drizzle"
  case chanceOfFreezingRain = "chance of freezing rain"
  case chanceOfFreezingRainOrRain = "chance of freezing rain or rain"
  case chanceOfRainOrFreezingRain = "chance of rain or freezing rain"
  case aFewRainShowersOrFlurries = "a few rain showers or flurries"
  case periodsOfRainOrSnow = "periods of rain or snow"
  case aFewRainShowersOrWetFlurries = "a few rain showers or wet flurries"
  case snowMixedWithRain = "snow mixed with rain"
  case chanceOfSnowMixedWithFreezingRain = "chance of snow mixed with freezing rain"
  case wetSnowOrRain = "wet snow or rain"
  case wetFlurries = "wet flurries"
  case wetSnow = "wet snow"
  case snowAtTimesHeavy = "snow at times heavy"
  case periodsOfSnow = "periods of snow"
  case chanceOfSnow = "chance of snow"
  case snowSqualls = "snow squalls"
  case localSnowSqualls = "local snow squalls"
  case blizzard = "blizzard"
  case nearBlizzard = "near blizzard"
  case snowAndBlizzard = "snow and blizzard"
  case snowAtTimesHeavyAndBlowingSnow = "snow at times heavy and blowing snow"
  case aFewShowersOrThundershowers = "a few showers or thundershowers"
  case aFewShowersOrThunderstorms = "a few showers or thunderstorms"
  case showersOrThundershowers = "showers or thundershowers"
  case showersOrThunderstorms = "showers or thunderstorms"
  case rainOrThunderstorms = "rain or thunderstorms"
  case rainOrThundershowers = "rain or thundershowers"
  case chanceOfThunderstormsAndPossibleHail = "chance of thunderstorms and possible hail"
  case thunderstormsAndPossibleHail = "thunderstorms and possible hail"
  case fogDissipating = "fog dissipating"
  case fogDeveloping = "fog developing"
  case iceFogDeveloping = "ice fog developing"
  case iceFogDissipating = "ice fog dissipating"
  case aFewFlurriesMixedWithIcePellets = "a few flurries mixed with ice pellets"
  case icePellet = "ice pellet"
  case icePelletMixedWithFreezingRain = "ice pellet mixed with freezing rain"
  case icePelletMixedWithSnow = "ice pellet mixed with snow"
  case icePelletOrSnow = "ice pellet or snow"
  case possibilityOfDrizzleMixedWithFreezingDrizzle = "possibility of drizzle mixed with freezing drizzle"
  case possibilityOfDrizzle = "possibility of drizzle"
  case drizzleOrFreezingDrizzle = "drizzle or freezing drizzle"
  case notAvailable = "not available"
  case aFewFlurriesOrShowers = "a few flurries or showers"
  case chanceOfSnowOrRain = "chance of snow or rain"
  case chanceOfLightSnow = "chance of light snow"
  case snowAndBlowingSnow = "snow and blowing snow"
  
  // conditions pas dans les liste d'EC, mais néanmoins vues dans les XML
  case chanceOfShowersRiskOfThunderstorms = "chance of showers. risk of thunderstorms"
  case lightRainshower = "light rainshower"
  case mainlyCloudy = "mainly cloudy"
}

// Fonction pour retourner une icône selon la condition météo.
// C'est plus pratique de mettre ça ici comme extension plutôt que directement dans le fichier Prevision.swift.
extension Prevision {
  func donneIcone() -> UIImage? {
    guard let condition = self.condition else {
      return UIImage(named: "na")
    }
    switch condition {
    case .sunny:
      return UIImage(named: "sunny")
    case .mainlySunny, .aMixOfSunAndCloud:
      return UIImage(named: "mainly sunny")
    case .cloudyPeriods, .partlyCloudy, .mainlyClear:
      return self.estNuit() ? UIImage(named: "a few clouds") : UIImage(named: "mainly sunny")
    case .mainlyCloudy, .mostlyCloudy:
      return self.estNuit() ? UIImage(named: "mostly cloudy night") : UIImage(named: "mostly cloudy")
    case .lightRainshower, .lightRainShower, .chanceOfShowers:
      return self.estNuit() ? UIImage(named: "chance of showers night") : UIImage(named: "chance of showers")
    case .lightRainShowerAndFlurries:
      return self.estNuit() ? UIImage(named: "chance of rain and snow night") : UIImage(named: "chance of rain and snow")
    case.lightFlurries:
      return self.estNuit() ? UIImage(named: "light flurries night") : UIImage(named: "light flurries")
    case .cloudy:
      return UIImage(named: "cloudy")
    case .precipitation, .squalls, .lightPrecipitation, .heavyPrecipitation:
      return UIImage(named: "unknown precipitation")
    case .rainShower, .lightRainAndDrizzle, .lightRain, .rain, .rainAndDrizzle:
      return UIImage(named: "light rain")
    case .heavyRain, .heavyRainShower, .heavyRainAndDrizzle:
      return UIImage(named: "heavy rain")
    case .lightFreezingRain, .lightFreezingDrizzle, .freezingRain, .freezingDrizzle, .heavyFreezingRain, .heavyFreezingDrizzle:
      return UIImage(named: "sleet")
    case .lightSnow, .snow:
      return UIImage(named: "snow")
    case .flurries, .heavySnow, .heavyFlurries:
      return UIImage(named: "heavy snow")
    case .thunderstorm, .thunderstormWithLightRain, .thunderstormWithRain, .thunderstormWithHeavyRain, .heavyThunderstorm, .heavyThunderstormWithRain:
      return UIImage(named: "thunderstorm")
    case .haze:
      return UIImage(named: "haze")
    case .fog, .iceFog, .fogPatches, .shallowFog, .mist:
      return UIImage(named: "fog")
    case .driftingSnow:
      return UIImage(named: "drifting snow")
    case .iceCrystals:
      return UIImage(named: "ice crystals")
    case .snowPellets, .icePellets, .hail:
      return UIImage(named: "hail")
    case .snowGrains, .lightDrizzle, .drizzle, .heavyDrizzle:
      return UIImage(named: "drizzle")
    case .clear:
      return UIImage(named: "clear")
    case .aFewClouds:
      return UIImage(named: "a few clouds")
    case .blowingSnow:
      return UIImage(named: "blowing snow")
    case .funnelCloud, .tornado:
      return UIImage(named: "tornado")
    case .smoke:
      return UIImage(named: "smoke")
    case .dustDevils, .dustStorm, .blowingDust, .sandstorm, .driftingDust:
      return UIImage(named: "sandstorm")
    case .volcanicAsh:
      return UIImage(named: "volcanic ash")
    case .thunderstormWithHail, .heavyThunderstormWithHail:
      return UIImage(named: "thunderstorm with hail")
    case .thunderstormWithBlowingDust, .thunderstormWithDustStorm:
      return UIImage(named: "thunderstorm with dust")
    case .waterspout:
      return UIImage(named: "waterspout")

    case .chanceOfShowersRiskOfThunderstorms:
      return self.estNuit() ? UIImage(named: "chance of showers risk of thunderstorms night") : UIImage(named: "chance of showers risk of thunderstorms")

    case .notAvailable:
      return UIImage(named: "na")
    default:
      return UIImage(named: "na")
    }
  }
}
