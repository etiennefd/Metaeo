//
//  EnumConditions.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-30.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

enum Condition: String {
  //MARK: Environnement Canada (conditions actuelles et prévisions)
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
  
  //MARK: Environnement Canada (conditions actuelles seulement)
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
  case blowingSnow = "blowing snow"
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
  
  //MARK: Environnement Canada (prévisions seulement)
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
  
  //MARK: Environnement Canada (autres)
  //Pas dans les listes officielles d'EC, mais néanmoins vues dans les XML
  case chanceOfShowersRiskOfThunderstorms = "chance of showers. risk of thunderstorms"
  case chanceOfShowersRiskOfSevereThunderstorms = "chance of showers. risk of severe thunderstorms"
  case showersRiskOfThunderstorms = "showers. risk of thunderstorms"
  case showersRiskOfSevereThunderstorms = "showers. risk of severe thunderstorms"
  case aFewShowersRiskOfThunderstorms = "a few showers. risk of thunderstorms"
  case aFewShowersRiskOfSevereThunderstorms = "a few showers. risk of severe thunderstorms"
  case rainRiskOfThunderstorms = "rain. risk of thunderstorms"
  case rainAtTimesHeavyRiskOfThunderstorms = "rain at times heavy. risk of thunderstorms"
  //case riskOfThunderstorms = "risk of thunderstorms" // à ajouter?
  case riskOfSevereThunderstorms = "risk of severe thunderstorms"
  case lightRainshower = "light rainshower"
  case mainlyCloudy = "mainly cloudy"
  case rainShowersAndFlurries = "rain showers and flurries"
  case thunderstormWithLightRainshowers = "thunderstorm with light rainshowers"
  case thunderstormWithRainshowers = "thunderstorm with rainshowers"
  case thunderstormWithHeavyRainshowers = "thunderstorm with heavy rainshowers"
  
  //MARK: yr.no
  // Les cas commentés sont ceux qui sont identiques à une condition déjà définie ci-dessus
  case clearSkyYR = "clearsky"
  //case cloudyYR = "cloudy"
  case fairYR = "fair"
  //case fogYR = "fog"
  case heavyRainYR = "heavyrain"
  case heavyRainAndThunderYR = "heavyrainandthunder"
  case heavyRainShowersYR = "heavyrainshowers"
  case heavyRainShowersAndThunderYR = "heavyrainshowersandthunder"
  case heavySleetYR = "heavysleet (rain and snow)"
  case heavySleetAndThunderYR = "heavysleetandthunder (rain and snow)"
  case heavySleetShowersYR = "heavysleetshowers (rain and snow)"
  case heavySleetShowersAndThunderYR = "heavysleetshowersandthunder (rain and snow)"
  case heavySnowYR = "heavysnow"
  case heavySnowAndThunderYR = "heavysnowandthunder"
  case heavySnowShowersYR = "heavysnowshowers"
  case heavySnowShowersAndThunderYR = "heavysnowshowersandthunder"
  case lightRainYR = "lightrain"
  case lightRainAndThunderYR = "lightrainandthunder"
  case lightRainShowersYR = "lightrainshowers"
  case lightRainShowersAndThunderYR = "lightrainshowersandthunder"
  case lightSleetYR = "lightsleet (rain and snow)"
  case lightSleetAndThunderYR = "lightsleetandthunder (rain and snow)"
  case lightSleetShowersYR = "lightsleetshowers (rain and snow)"
  case lightSleetShowersAndThunderYR = "lightssleetshowersandthunder (rain and snow)" // typo dans l'original : double s
  case lightSnowYR = "lightsnow"
  case lightSnowAndThunderYR = "lightsnowandthunder"
  case lightSnowShowersYR = "lightsnowshowers"
  case lightSnowShowersAndThunderYR = "lightssnowshowersandthunder" // typo dans l'original : double s
  case partlyCloudyYR = "partlycloudy"
  //case rainYR = "rain"
  case rainAndThunderYR = "rainandthunder"
  case rainShowersYR = "rainshowers"
  case rainShowersAndThunderYR = "rainshowersandthunder"
  case sleetYR = "sleet (rain and snow)"
  case sleetAndThunderYR = "sleetandthunder (rain and snow)"
  case sleetShowersYR = "sleetshowers (rain and snow)"
  case sleetShowersAndThunderYR = "sleetshowersandthunder (rain and snow)"
  //case snowYR = "snow"
  case snowAndThunderYR = "snowandthunder"
  case snowShowersYR = "snowshowers"
  case snowShowersAndThunderYR = "snowshowersandthunder"
  
  //MARK: NOAA
  // Les cas commentés sont ceux qui sont identiques à une condition déjà définie ci-dessus.
  // De plus, les conditions avec "slight chance" ou "likely" sont assimilées à celles avec "chance".
  //case sunnyNOAA = "sunny"
  case mostlySunnyNOAA = "mostly sunny"
  case partlySunnyNOAA = "partly sunny"
  //case mostlyCloudyNOAA = "mostly cloudy"
  //case cloudyNOAA = "cloudy"
  //case clearNOAA = "clear"
  case mostlyClearNOAA = "mostly clear"
  //case partlyCloudyNOAA = "partly cloudy"
  case increasingCloudsNOAA = "increasing clouds"
  case decreasingCloudsNOAA = "decreasing clouds"
  case becomingCloudyNOAA = "becoming cloudy"
  //case clearingNOAA = "clearing"
  case gradualClearingNOAA = "gradual clearing"
  case clearingLateNOAA = "clearing late"
  case becomingSunnyNOAA = "becoming sunny"
  case patchyFogNOAA = "patchy fog"
  case denseFogNOAA = "dense fog"
  case areasFogNOAA = "areas fog"
  //case fogNOAA = "fog"
  //case blowingSnowNOAA = "blowing snow"
  //case blowingDustNOAA = "blowing dust"
  case blowingSandNOAA = "blowing sand"
  case patchyHazeNOAA = "patchy haze"
  case areasHazeNOAA = "areas haze"
  //case hazeNOAA = "haze"
  case patchyIceCrystalsNOAA = "patchy ice crystals"
  case areasIceCrystalsNOAA = "areas ice crystals"
  //case iceCrystalsNOAA = "ice crystals"
  case patchyIceFogNOAA = "patchy ice fog"
  case areasIceFogNOAA = "areas ice fog"
  //case iceFogNOAA = "ice fog"
  case patchyFreezingFogNOAA = "patchy freezing fog"
  case areasFreezingFogNOAA = "areas freezing fog"
  case freezingFogNOAA = "freezing fog"
  case freezingSprayNOAA = "freezing spray"
  case patchySmokeNOAA = "patchy smoke"
  case areasSmokeNOAA = "areas smoke"
  //case smokeNOAA = "smoke"
  case patchyFrostNOAA = "patchy frost"
  case areasFrostNOAA = "areas frost"
  case frostNOAA = "frost"
  case patchyAshNOAA = "patchy ash"
  case areasAshNOAA = "areas ash"
  //case volcanicAshNOAA = "volcanic ash"
  case chanceSleetNOAA = "chance sleet (ice pellets)"
  case sleetNOAA = "sleet (ice pellets)"
  case chanceRainShowersNOAA = "chance rain showers"
  case rainShowersNOAA = "rain showers"
  case chanceRainNOAA = "chance rain"
  //case rainNOAA = "rain"
  //case heavyRainNOAA = "heavy rain"
  case chanceDrizzleNOAA = "chance drizzle"
  //case drizzleNOAA = "drizzle"
  case chanceSnowShowersNOAA = "chance snow showers"
  case snowShowersNOAA = "snow showers"
  case chanceFlurriesNOAA = "chance flurries"
  //case flurriesNOAA = "flurries"
  case chanceSnowNOAA = "chance snow"
  //case snowNOAA = "snow"
  //case blizzardNOAA = "blizzard"
  case chanceRainSnowNOAA = "chance rain/snow"
  case rainSnowNOAA = "rain/snow"
  case chanceFreezingRainNOAA = "chance freezing rain"
  //case freezingRainNOAA = "freezing rain"
  case chanceFreezingDrizzleNOAA = "chance freezing drizzle"
  //case freezingDrizzleNOAA = "freezing drizzle"
  case chanceWintryMixNOAA = "chance wintry mix"
  case wintryMixNOAA = "wintry mix"
  case chanceRainFreezingRainNOAA = "chance rain/freezing rain"
  case rainFreezingRainNOAA = "rain/freezing rain"
  case chanceRainSleetNOAA = "chance rain/sleet (ice pellets)"
  case rainSleetNOAA = "rain/sleet (ice pellets)"
  case chanceSnowSleetNOAA = "chance snow/sleet (ice pellets)"
  case snowSleetNOAA = "snow/sleet (ice pellets)"
  case isolatedThunderstormsNOAA = "isolated thunderstorms"
  case chanceThunderstormsNOAA = "chance thunderstorms"
  case thunderstormsNOAA = "thunderstorms"
  case severeTstmsNOAA = "severe tstms"
  case waterSpoutsNOAA = "water spouts"
  //case windyNOAA = "windy"
  case blusteryNOAA = "blustery"
  case breezyNOAA = "breezy"
  case hotNOAA = "hot"
  case coldNOAA = "cold"
  
  // Pas dans les liste de la NOAA, mais néanmoins vues dans les JSON
  case isolatedRainShowersNOAA = "isolated rain showers"
  case chanceShowersAndThunderstormsNOAA = "chance showers and thunderstorms"
  case isolatedShowersAndThunderstormsNOAA = "isolated showers and thunderstorms"
  case chanceLightRainNOAA = "chance light rain"
  case chanceHeavyRainNOAA = "chance heavy rain"
  case thunderstormsAndRainNOAA = "thunderstorms and rain"

  //MARK: OpenWeatherMap
  // Les cas commentés sont ceux qui sont identiques à une condition déjà définie ci-dessus.
  //case thunderstormWithLightRainOWM = "thunderstorm with light rain"
  //case thunderstormWithRainOWM = "thunderstorm with rain"
  //case thunderstormWithHeavyRainOWM = "thunderstorm with heavy rain"
  case lightThunderstormOWM = "light thunderstorm"
  //case thunderstormOWM = "thunderstorm"
  //case heavyThunderstormOWM = "heavy thunderstorm"
  case raggedThunderstormOWM = "ragged thunderstorm"
  case thunderstormWithLightDrizzleOWM = "thunderstorm with light drizzle"
  case thunderstormWithDrizzleOWM = "thunderstorm with drizzle"
  case thunderstormWithHeavyDrizzleOWM = "thunderstorm with heavy drizzle"
  case lightIntensityDrizzleOWM = "light intensity drizzle"
  //case drizzleOWM = "drizzle"
  case heavyIntensityDrizzleOWM = "heavy intensity drizzle"
  case lightIntensityDrizzleRainOWM = "light intensity drizzle rain"
  case drizzleRainOWM = "drizzle rain"
  case heavyIntensityDrizzleRainOWM = "heavy intensity drizzle rain"
  case showerRainAndDrizzleOWM = "shower rain and drizzle"
  case heavyShowerRainAndDrizzleOWM = "heavy shower rain and drizzle"
  case showerDrizzleOWM = "shower drizzle"
  //case lightRainOWM = "light rain"
  case moderateRainOWM = "moderate rain"
  case heavyIntensityRainOWM = "heavy intensity rain"
  case veryHeavyRainOWM = "very heavy rain"
  case extremeRainOWM = "extreme rain"
  //case freezingRainOWM = "freezing rain"
  case lightIntensityShowerRainOWM = "light intensity shower rain"
  case showerRainOWM = "shower rain"
  case heavyIntensityShowerRainOWM = "heavy intensity shower rain"
  case raggedShowerRainOWM = "ragged shower rain"
  //case lightSnowOWM = "light snow"
  //case snowOWM = "snow"
  //case heavySnowOWM = "heavy snow"
  //case sleetOWM = "sleet (ice pellets)"
  case lightShowerSleetOWM = "light shower sleet (ice pellets)"
  case showerSleetOWM = "shower sleet (ice pellets)"
  //case lightRainAndSnowOWM = "light rain and snow"
  //case rainAndSnowOWM = "rain and snow"
  case lightShowerSnowOWM = "light shower snow"
  case showerSnowOWM = "shower snow"
  case heavyShowerSnowOWM = "heavy shower snow"
  //case mistOWM = "mist"
  //case smokeOWM = "smoke"
  //case hazeOWM = "haze"
  case sandDustWhirlsOWM = "sand/ dust whirls"
  //case fogOWM = "fog"
  case sandOWM = "sand"
  case dustOWM = "dust"
  //case volcanicAshOWM = "volcanic ash"
  //case squallsOWM = "squalls"
  //case tornadoOWM = "tornado"
  case clearSkyOWM = "clear sky"
  case fewCloudsOWM = "few clouds"
  case scatteredCloudsOWM = "scattered clouds"
  case brokenCloudsOWM = "broken clouds"
  case overcastCloudsOWM = "overcast clouds"

}

// Fonction pour retourner une icône selon la condition météo.
// C'est plus pratique de mettre ça ici comme extension plutôt que directement dans le fichier Prevision.swift.
extension Prevision {
  func donneIcone() -> UIImage? {
    guard let condition = self.condition else {
      return UIImage(named: "na")
    }
    switch condition {
      
    //MARK: Couverture nuageuse
      
    case .sunny:
      return UIImage(named: "sunny")
    case .clear, // pour EC "clear" c'est toujours la nuit, mais pas pour les autres
         .clearSkyYR,
         .clearSkyOWM:
      return self.estNuit() ? UIImage(named: "clear") : UIImage(named: "sunny")
    case .mainlySunny,
         .aMixOfSunAndCloud,
         .sunnyWithCloudyPeriods,
         .mostlySunnyNOAA,
         .partlySunnyNOAA:
      return UIImage(named: "mainly sunny")
    case .aFewClouds,
         .cloudyPeriods,
         .partlyCloudy,
         .mainlyClear,
         .fairYR,
         .mostlyClearNOAA,
         .fewCloudsOWM,
         .scatteredCloudsOWM:
      return self.estNuit() ? UIImage(named: "a few clouds night") : UIImage(named: "mainly sunny")
    case .mainlyCloudy,
         .mostlyCloudy,
         .partlyCloudyYR,
         .brokenCloudsOWM:
      return self.estNuit() ? UIImage(named: "mostly cloudy night") : UIImage(named: "mostly cloudy")
    case .cloudyWithSunnyPeriods:
      return UIImage(named: "mostly cloudy")
    case .cloudy,
         .overcast,
         .overcastCloudsOWM:
      return UIImage(named: "cloudy")
    case .increasingCloudiness,
         .increasingCloudsNOAA,
         .becomingCloudyNOAA:
      return self.estNuit() ? UIImage(named: "increasing cloudiness night") : UIImage(named: "increasing cloudiness")
    case .clearing,
         .decreasingCloudsNOAA,
         .gradualClearingNOAA,
         .clearingLateNOAA:
      return self.estNuit() ? UIImage(named: "clearing night") : UIImage(named: "clearing")
    case .becomingSunnyNOAA:
      return UIImage(named: "clearing")
      
    //MARK: Pluie
      
    case .lightRainshower,
         .lightRainShower,
         .chanceOfShowers,
         .aFewShowers,
         .chanceOfDrizzleOrRain,
         .lightRainShowersYR,
         .rainShowersYR,
         .chanceRainShowersNOAA,
         .isolatedRainShowersNOAA,
         .chanceLightRainNOAA,
         .chanceRainNOAA,
         .raggedShowerRainOWM:
      return self.estNuit() ? UIImage(named: "chance of showers night") : UIImage(named: "chance of showers")
    case .rainShower,
         .lightRainAndDrizzle,
         .lightRain,
         .rain,
         .rainAndDrizzle,
         .showers,
         .aFewShowersOrDrizzle,
         .lightRainYR,
         .rainShowersNOAA,
         .lightIntensityDrizzleRainOWM,
         .drizzleRainOWM,
         .showerRainAndDrizzleOWM,
         .moderateRainOWM,
         .lightIntensityShowerRainOWM,
         .showerRainOWM:
      return UIImage(named: "light rain")
    case .chanceHeavyRainNOAA,
         .heavyRainShowersYR:
      return self.estNuit() ? UIImage(named: "chance of heavy rain night") : UIImage(named: "chance of heavy rain")
    case .heavyRain,
         .heavyRainShower,
         .heavyRainAndDrizzle,
         .periodsOfRain,
         .rainAtTimesHeavy,
         .heavyRainYR,
         .heavyIntensityDrizzleRainOWM,
         .heavyShowerRainAndDrizzleOWM,
         .heavyIntensityRainOWM,
         .veryHeavyRainOWM,
         .extremeRainOWM,
         .heavyIntensityShowerRainOWM:
      return UIImage(named: "heavy rain")
    case .snowGrains,
         .lightDrizzle,
         .drizzle,
         .heavyDrizzle,
         .drizzleOrFreezingDrizzle,
         .possibilityOfDrizzle,
         .possibilityOfDrizzleMixedWithFreezingDrizzle,
         .chanceDrizzleNOAA,
         .lightIntensityDrizzleOWM,
         .heavyIntensityDrizzleOWM,
         .showerDrizzleOWM:
      return UIImage(named: "drizzle")
      
    //MARK: Neige et glace
      
    case .lightFlurries,
         .aFewFlurries,
         .chanceOfFlurries,
         .aFewWetFlurries,
         .chanceOfLightSnow,
         .lightSnowShowersYR,
         .snowShowersYR,
         .heavySnowShowersYR,
         .snowShowersNOAA,
         .chanceSnowShowersNOAA,
         .chanceFlurriesNOAA,
         .lightShowerSnowOWM:
      return self.estNuit() ? UIImage(named: "light flurries night") : UIImage(named: "light flurries")
    case .lightSnow,
         .snow,
         .wetSnow,
         .flurries,
         .wetFlurries,
         .chanceOfSnow,
         .periodsOfSnow,
         .lightSnowYR,
         .chanceSnowNOAA,
         .showerSnowOWM:
      return UIImage(named: "snow")
    case .heavySnow,
         .snowAtTimesHeavy,
         .heavyFlurries,
         .snowSqualls,
         .localSnowSqualls,
         .blizzard,
         .nearBlizzard,
         .snowAndBlizzard,
         .snowAtTimesHeavyAndBlowingSnow,
         .heavySnowYR,
         .heavyShowerSnowOWM:
      return UIImage(named: "heavy snow")
    case .lightRainShowerAndFlurries,
         .aFewRainShowersOrFlurries,
         .aFewFlurriesOrShowers,
         .aFewFlurriesOrRainShowers,
         .chanceOfFlurriesOrRainShowers,
         .chanceOfSnowOrRain,
         .lightSleetShowersYR,
         .sleetShowersYR,
         .heavySleetShowersYR,
         .chanceRainSnowNOAA,
         .chanceWintryMixNOAA:
      return self.estNuit() ? UIImage(named: "chance of rain and snow night") : UIImage(named: "chance of rain and snow")
    case .rainAndFlurries,
         .rainShowersAndFlurries,
         .rainAndSnow,
         .lightRainAndSnow,
         .heavyRainShowerAndFlurries,
         .heavyRainAndSnow,
         .periodsOfRainOrSnow,
         .aFewRainShowersOrWetFlurries,
         .snowMixedWithRain,
         .chanceOfSnowMixedWithFreezingRain,
         .wetSnowOrRain,
         .lightSleetYR,
         .sleetYR,
         .heavySleetYR,
         .rainSnowNOAA,
         .wintryMixNOAA:
      return UIImage(named: "rain and snow")
    case .lightFreezingRain,
         .lightFreezingDrizzle,
         .freezingRain,
         .freezingDrizzle,
         .heavyFreezingRain,
         .heavyFreezingDrizzle,
         .chanceOfFreezingRain,
         .chanceOfFreezingRainOrRain,
         .chanceOfRainOrFreezingRain,
         .freezingSprayNOAA,
         .rainFreezingRainNOAA,
         .chanceFreezingRainNOAA,
         .chanceFreezingDrizzleNOAA,
         .chanceRainFreezingRainNOAA:
      return UIImage(named: "freezing rain")
    case .hail,
         .snowPellets,
         .icePellets,
         .icePellet,
         .icePelletOrSnow,
         .icePelletMixedWithSnow,
         .icePelletMixedWithFreezingRain,
         .aFewFlurriesMixedWithIcePellets,
         .sleetNOAA,
         .chanceSleetNOAA,
         .rainSleetNOAA,
         .chanceRainSleetNOAA,
         .snowSleetNOAA,
         .chanceSnowSleetNOAA,
         .lightShowerSleetOWM,
         .showerSleetOWM:
      return UIImage(named: "hail")
    case .driftingSnow:
      return UIImage(named: "drifting snow")
    case .blowingSnow,
         .snowAndBlowingSnow:
      return UIImage(named: "blowing snow")
    case .iceCrystals,
         .patchyIceCrystalsNOAA,
         .areasIceCrystalsNOAA:
      return UIImage(named: "ice crystals")

    //MARK: Orages

    case .chanceOfThunderstorms,
         .chanceOfThundershowers,
         .chanceOfShowersOrThunderstorms,
         .chanceOfShowersOrThundershowers,
         .chanceOfShowersAtTimesHeavyOrThunderstorms,
         .chanceOfShowersAtTimesHeavyOrThundershowers,
         .chanceOfShowersRiskOfThunderstorms,
         .chanceOfShowersRiskOfSevereThunderstorms,
         .aFewShowersOrThunderstorms,
         .aFewShowersOrThundershowers,
         .showersOrThunderstorms,
         .showersOrThundershowers,
         .aFewShowersRiskOfThunderstorms,
         .aFewShowersRiskOfSevereThunderstorms,
         .showersRiskOfThunderstorms,
         .showersRiskOfSevereThunderstorms,
         .riskOfSevereThunderstorms,
         .lightRainShowersAndThunderYR,
         .rainShowersAndThunderYR,
         .heavyRainShowersAndThunderYR,
         .chanceThunderstormsNOAA,
         .chanceShowersAndThunderstormsNOAA,
         .isolatedThunderstormsNOAA,
         .isolatedShowersAndThunderstormsNOAA,
         .raggedThunderstormOWM:
      return self.estNuit() ? UIImage(named: "chance of thunderstorms night") : UIImage(named: "chance of thunderstorms")
    case .thunderstorm,
         .thunderstormWithLightRain,
         .thunderstormWithRain,
         .thunderstormWithHeavyRain,
         .heavyThunderstorm,
         .heavyThunderstormWithRain,
         .thunderstormWithLightRainshowers,
         .thunderstormWithRainshowers,
         .thunderstormWithHeavyRainshowers,
         .rainOrThunderstorms,
         .rainOrThundershowers,
         .rainRiskOfThunderstorms,
         .rainAtTimesHeavyRiskOfThunderstorms,
         .lightRainAndThunderYR,
         .rainAndThunderYR,
         .heavyRainAndThunderYR,
         .thunderstormsNOAA,
         .severeTstmsNOAA,
         .thunderstormsAndRainNOAA,
         .lightThunderstormOWM,
         .thunderstormWithLightDrizzleOWM,
         .thunderstormWithDrizzleOWM,
         .thunderstormWithHeavyDrizzleOWM:
      return UIImage(named: "thunderstorm")
    case .lightSleetShowersAndThunderYR,
         .sleetShowersAndThunderYR,
         .heavySleetShowersAndThunderYR:
      return self.estNuit() ? UIImage(named: "chance of thunderstorm with rain and snow night") : UIImage(named: "chance of thunderstorm with rain and snow")
    case .lightSleetAndThunderYR,
         .sleetAndThunderYR,
         .heavySleetAndThunderYR:
      return UIImage(named: "thunderstorm with rain and snow")
    case .aFewFlurriesOrThundershowers,
         .lightSnowShowersAndThunderYR,
         .snowShowersAndThunderYR,
         .heavySnowShowersAndThunderYR:
      return self.estNuit() ? UIImage(named: "chance of thunderstorm with snow night") : UIImage(named: "chance of thunderstorm with snow")
    case .lightSnowAndThunderYR,
         .snowAndThunderYR,
         .heavySnowAndThunderYR:
      return UIImage(named: "thunderstorm with snow")
    case .thunderstormWithHail,
         .heavyThunderstormWithHail,
         .thunderstormsAndPossibleHail,
         .chanceOfThunderstormsAndPossibleHail:
      return UIImage(named: "thunderstorm with hail")
    case .thunderstormWithBlowingDust,
         .thunderstormWithDustStorm:
      return UIImage(named: "thunderstorm with dust")

    //MARK: Aérosols
      
    case .haze,
         .patchyHazeNOAA,
         .areasHazeNOAA:
      return UIImage(named: "haze")
    case .fog,
         .fogPatches,
         .fogDissipating,
         .fogDeveloping,
         .iceFog,
         .iceFogDeveloping,
         .iceFogDissipating,
         .shallowFog,
         .mist,
         .patchyFogNOAA,
         .denseFogNOAA,
         .areasFogNOAA,
         .patchyIceFogNOAA,
         .areasIceFogNOAA,
         .patchyFreezingFogNOAA,
         .areasFreezingFogNOAA,
         .freezingFogNOAA:
      return UIImage(named: "fog")
    case .smoke,
         .patchySmokeNOAA,
         .areasSmokeNOAA:
      return UIImage(named: "smoke")
    case .dustDevils,
         .dustStorm,
         .blowingDust,
         .sandstorm,
         .driftingDust,
         .blowingSandNOAA,
         .sandOWM,
         .dustOWM,
         .sandDustWhirlsOWM:
      return UIImage(named: "sandstorm")
    case .volcanicAsh,
         .patchyAshNOAA,
         .areasAshNOAA:
      return UIImage(named: "volcanic ash")

    //MARK: Vent
      
    case .windy,
         .blusteryNOAA,
         .breezyNOAA:
      return UIImage(named: "windy")
    case .funnelCloud,
         .tornado:
      return UIImage(named: "tornado")
    case .waterspout,
         .waterSpoutsNOAA:
      return UIImage(named: "waterspout")
      
    //MARK: Autres
 
    case .coldNOAA,
         .frostNOAA,
         .patchyFrostNOAA,
         .areasFrostNOAA:
      return UIImage(named: "cold")
    case .hotNOAA:
      return UIImage(named: "hot")
    case .precipitation,
         .squalls,
         .lightPrecipitation,
         .heavyPrecipitation:
      return UIImage(named: "unknown precipitation")
      
    case .notAvailable:
      return UIImage(named: "na")
      //    default:
      //      return UIImage(named: "na")
    }
  }
}
