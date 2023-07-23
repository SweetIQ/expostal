defmodule Expostal.Address do
  @moduledoc """
  Struct for holding the results returned by libpostal.
  from the upstream README.md:

  * house: venue name e.g. "Brooklyn Academy of Music", and building names e.g. "Empire State Building"
  * category: for category queries like "restaurants", etc.
  * near: phrases like "in", "near", etc. used after a category phrase to help with parsing queries like "restaurants in Brooklyn"
  * house_number: usually refers to the external (street-facing) building number. In some countries this may be a compount, hyphenated number which also includes an apartment number, or a block number (a la Japan), but libpostal will just call it the house_number for simplicity.
  * road: street name(s)
  * unit: an apartment, unit, office, lot, or other secondary unit designator
  * level: expressions indicating a floor number e.g. "3rd Floor", "Ground Floor", etc.
  * staircase: numbered/lettered staircase
  * entrance: numbered/lettered entrance
  * po_box: post office box: typically found in non-physical (mail-only) addresses
  * postcode: postal codes used for mail sorting
  * suburb: usually an unofficial neighborhood name like "Harlem", "South Bronx", or "Crown Heights"
  * city_district: these are usually boroughs or districts within a city that serve some official purpose e.g. "Brooklyn" or "Hackney" or "Bratislava IV"
  * city: any human settlement including cities, towns, villages, hamlets, localities, etc.
  * island: named islands e.g. "Maui"
  * state_district: usually a second-level administrative division or county.
  * state: a first-level administrative division. Scotland, Northern Ireland, Wales, and England in the UK are mapped to "state" as well (convention used in OSM, GeoPlanet, etc.)
  * country_region: informal subdivision of a country without any political status
  * country: sovereign nations and their dependent territories, anything with an ISO-3166 code.
  * world_region: currently only used for appending “West Indies” after the country name, a pattern frequently used in the English-speaking Caribbean e.g. “Jamaica, West Indies”
  """

  defstruct [
    :house,
    :category,
    :near,
    :house_number,
    :road,
    :unit,
    :level,
    :staircase,
    :entrance,
    :po_box,
    :postcode,
    :suburb,
    :city_district,
    :city,
    :island,
    :state_district,
    :state,
    :country_region,
    :country,
    :world_region
  ]
end
