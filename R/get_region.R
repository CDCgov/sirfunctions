#' Determines whether lab data is EMRO or AFRO
#'
#' Outputs the name of the region which a country belongs to.
#'
#' @param country_name `str` Name of the country.
#'
#' @returns `str` A string, either `"EMRO"` or `"AFRO"`.
#' @examples
#' \dontrun{
#' get_region("algeria")
#' }
#'
#' @export
get_region <- function(country_name = Sys.getenv("DR_COUNTRY")) {
  # Format country_name
  country_name <- stringr::str_trim(stringr::str_to_upper(country_name))

  # Countries that belong in a region
  afro_ctry <- c(
    "CHAD", "ANGOLA", "BENIN", "NIGERIA", "ALGERIA", "GUINEA", "CAMEROON",
    "KENYA", "BURKINA FASO", "MOZAMBIQUE", "ETHIOPIA",
    "SOUTH AFRICA", "SENEGAL", "MADAGASCAR", "CENTRAL AFRICAN REPUBLIC",
    "BURUNDI", "CONGO", "UNITED REPUBLIC OF TANZANIA", "CABO VERDE", "NIGER",
    "MALAWI", "SOUTH SUDAN", "LIBERIA", "TOGO", "UGANDA", "BOTSWANA", "ZAMBIA",
    "MAURITANIA", "GABON", "ERITREA", "GUINEA-BISSAU", "LESOTHO", "NAMIBIA",
    "SIERRA LEONE", "ZIMBABWE", "EQUATORIAL GUINEA", "MAURITIUS", "RWANDA",
    "ESWATINI", "COTE D'IVOIRE", "COTE D IVOIRE",
    "DEMOCRATIC REPUBLIC OF THE CONGO", "GHANA", "GAMBIA", "MALI",
    "SEYCHELLES", "COMOROS"
  )

  amro_ctry <- c(
    "ARGENTINA", "BOLIVIA (PLURINATIONAL STATE OF)", "BRAZIL", "CUBA",
    "DOMINICAN REPUBLIC", "EL SALVADOR", "MEXICO", "NICARAGUA", "PERU",
    "VENEZUELA (BOLIVARIAN REPUBLIC OF)", "CHILE", "HAITI", "HONDURAS",
    "PARAGUAY", "BARBADOS", "COLOMBIA", "ECUADOR", "UNITED STATES OF AMERICA",
    "BELIZE", "JAMAICA", "GUATEMALA", "CANADA", "COSTA RICA", "GUYANA", "PANAMA",
    "URUGUAY", "TURKS AND CAICOS ISLANDS", "SURINAME", "GRENADA",
    "TRINIDAD AND TOBAGO", "SAINT VINCENT AND THE GRENADINES", "ANGUILLA",
    "FRENCH GUIANA"
  )

  emro_ctry <- c(
    "EGYPT", "AFGHANISTAN", "PAKISTAN", "IRAN (ISLAMIC REPUBLIC OF)",
    "KUWAIT", "SYRIAN ARAB REPUBLIC", "MOROCCO", "IRAQ", "YEMEN",
    "SOMALIA", "BAHRAIN", "LEBANON",
    "OCCUPIED PALESTINIAN TERRITORY, INCLUDING EAST JERUSALEM",
    "QATAR", "SUDAN", "SAUDI ARABIA", "UNITED ARAB EMIRATES",
    "DJIBOUTI", "JORDAN", "TUNISIA", "LIBYA", "OMAN"
  )

  euro_ctry <- c(
    "SPAIN", "AZERBAIJAN", "ARMENIA", "BELARUS", "GEORGIA", "KYRGYZSTAN",
    "KAZAKHSTAN", "NORTH MACEDONIA", "POLAND", "RUSSIAN FEDERATION",
    "TAJIKISTAN", "TURKMENISTAN", "UKRAINE", "UZBEKISTAN", "ISRAEL", "ITALY",
    "SERBIA", "AUSTRIA", "BOSNIA AND HERZEGOVINA", "CZECHIA", "GREECE", "LATVIA",
    "SLOVAKIA", "ESTONIA", "SLOVENIA", "NORWAY", "ROMANIA", "CROATIA", "LITHUANIA",
    # non-ASCII char must be converted to hexadecimal representation
    "PORTUGAL", "T\u00DCRKIYE", "ALBANIA", "REPUBLIC OF MOLDOVA", "SWITZERLAND",
    "HUNGARY", "BULGARIA", "MONTENEGRO", "TURKEY",
    "THE UNITED KINGDOM", "GERMANY", "FINLAND"
  )

  searo_ctry <- c(
    "BANGLADESH", "MYANMAR", "BHUTAN", "SRI LANKA", "INDIA",
    "DEMOCRATIC PEOPLE'S REPUBLIC OF KOREA", "NEPAL", "THAILAND",
    "TIMOR-LESTE", "INDONESIA", "MALDIVES"
  )

  wpro_ctry <- c(
    "AUSTRALIA", "FIJI", "REPUBLIC OF KOREA", "LAO PEOPLE'S DEMOCRATIC REPUBLIC",
    "MALAYSIA", "PHILIPPINES", "TONGA", "CHINA", "SOLOMON ISLANDS", "CAMBODIA",
    "NEW ZEALAND", "PAPUA NEW GUINEA", "VIET NAM", "BRUNEI DARUSSALAM",
    "MONGOLIA", "JAPAN", "SAMOA", "MICRONESIA (FEDERATED STATES OF)", "TUVALU",
    "SINGAPORE", "NEW CALEDONIA"
  )

  region <- dplyr::case_match(
    country_name,
    emro_ctry ~ "EMRO",
    afro_ctry ~ "AFRO",
    amro_ctry ~ "AMRO",
    euro_ctry ~ "EURO",
    wpro_ctry ~ "WPRO",
    searo_ctry ~ "SEARO",
    .default = NA
  )

  return(region)
}
