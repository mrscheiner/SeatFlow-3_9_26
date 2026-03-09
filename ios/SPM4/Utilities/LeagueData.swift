import Foundation

nonisolated struct LeagueData {
    static let allLeagues: [League] = [nhl, nba, nfl, mlb, mls]

    static let nhl = League(
        id: "nhl",
        name: "National Hockey League",
        shortName: "NHL",
        logoURL: "https://a.espncdn.com/i/teamlogos/leagues/500/nhl.png",
        teams: [
            Team(id: "ana", name: "Ducks", city: "Anaheim", abbreviation: "ANA", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/ana.png", primaryColor: "F47A38", secondaryColor: "B5985A", apiAbbr: "ANA"),
            Team(id: "bos", name: "Bruins", city: "Boston", abbreviation: "BOS", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/bos.png", primaryColor: "FCB514", secondaryColor: "000000", apiAbbr: "BOS"),
            Team(id: "buf", name: "Sabres", city: "Buffalo", abbreviation: "BUF", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/buf.png", primaryColor: "002654", secondaryColor: "FCB514", apiAbbr: "BUF"),
            Team(id: "cgy", name: "Flames", city: "Calgary", abbreviation: "CGY", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/cgy.png", primaryColor: "D2001C", secondaryColor: "FAAF19", apiAbbr: "CGY"),
            Team(id: "car", name: "Hurricanes", city: "Carolina", abbreviation: "CAR", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/car.png", primaryColor: "CC0000", secondaryColor: "000000", apiAbbr: "CAR"),
            Team(id: "chi", name: "Blackhawks", city: "Chicago", abbreviation: "CHI", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/chi.png", primaryColor: "CF0A2C", secondaryColor: "000000", apiAbbr: "CHI"),
            Team(id: "col", name: "Avalanche", city: "Colorado", abbreviation: "COL", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/col.png", primaryColor: "6F263D", secondaryColor: "236192", apiAbbr: "COL"),
            Team(id: "cbj", name: "Blue Jackets", city: "Columbus", abbreviation: "CBJ", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/cbj.png", primaryColor: "002654", secondaryColor: "CE1141", apiAbbr: "CBJ"),
            Team(id: "dal", name: "Stars", city: "Dallas", abbreviation: "DAL", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/dal.png", primaryColor: "006847", secondaryColor: "8F8F8C", apiAbbr: "DAL"),
            Team(id: "det", name: "Red Wings", city: "Detroit", abbreviation: "DET", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/det.png", primaryColor: "CE1141", secondaryColor: "FFFFFF", apiAbbr: "DET"),
            Team(id: "edm", name: "Oilers", city: "Edmonton", abbreviation: "EDM", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/edm.png", primaryColor: "041E42", secondaryColor: "FF4C00", apiAbbr: "EDM"),
            Team(id: "fla", name: "Panthers", city: "Florida", abbreviation: "FLA", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/fla.png", primaryColor: "002B5C", secondaryColor: "B9975B", apiAbbr: "FLA"),
            Team(id: "lak", name: "Kings", city: "Los Angeles", abbreviation: "LAK", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/la.png", primaryColor: "111111", secondaryColor: "A2AAAD", apiAbbr: "LA"),
            Team(id: "min", name: "Wild", city: "Minnesota", abbreviation: "MIN", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/min.png", primaryColor: "154734", secondaryColor: "A6192E", apiAbbr: "MIN"),
            Team(id: "mtl", name: "Canadiens", city: "Montreal", abbreviation: "MTL", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/mtl.png", primaryColor: "AF1E2D", secondaryColor: "192168", apiAbbr: "MON"),
            Team(id: "nsh", name: "Predators", city: "Nashville", abbreviation: "NSH", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/nsh.png", primaryColor: "FFB81C", secondaryColor: "041E42", apiAbbr: "NAS"),
            Team(id: "njd", name: "Devils", city: "New Jersey", abbreviation: "NJD", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/njd.png", primaryColor: "CE1141", secondaryColor: "000000", apiAbbr: "NJ"),
            Team(id: "nyi", name: "Islanders", city: "New York", abbreviation: "NYI", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/nyi.png", primaryColor: "00539B", secondaryColor: "F47D30", apiAbbr: "NYI"),
            Team(id: "nyr", name: "Rangers", city: "New York", abbreviation: "NYR", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/nyr.png", primaryColor: "0038A8", secondaryColor: "CE1141", apiAbbr: "NYR"),
            Team(id: "ott", name: "Senators", city: "Ottawa", abbreviation: "OTT", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/ott.png", primaryColor: "C52032", secondaryColor: "C2912C", apiAbbr: "OTT"),
            Team(id: "phi", name: "Flyers", city: "Philadelphia", abbreviation: "PHI", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/phi.png", primaryColor: "F74902", secondaryColor: "000000", apiAbbr: "PHI"),
            Team(id: "pit", name: "Penguins", city: "Pittsburgh", abbreviation: "PIT", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/pit.png", primaryColor: "000000", secondaryColor: "FCB514", apiAbbr: "PIT"),
            Team(id: "sjs", name: "Sharks", city: "San Jose", abbreviation: "SJS", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/sj.png", primaryColor: "006D75", secondaryColor: "EA7200", apiAbbr: "SJ"),
            Team(id: "sea", name: "Kraken", city: "Seattle", abbreviation: "SEA", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/sea.png", primaryColor: "001628", secondaryColor: "99D9D9", apiAbbr: "SEA"),
            Team(id: "stl", name: "Blues", city: "St. Louis", abbreviation: "STL", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/stl.png", primaryColor: "002F87", secondaryColor: "FCB514", apiAbbr: "STL"),
            Team(id: "tbl", name: "Lightning", city: "Tampa Bay", abbreviation: "TBL", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/tb.png", primaryColor: "002868", secondaryColor: "FFFFFF", apiAbbr: "TB"),
            Team(id: "tor", name: "Maple Leafs", city: "Toronto", abbreviation: "TOR", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/tor.png", primaryColor: "00205B", secondaryColor: "FFFFFF", apiAbbr: "TOR"),
            Team(id: "van", name: "Canucks", city: "Vancouver", abbreviation: "VAN", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/van.png", primaryColor: "00205B", secondaryColor: "00843D", apiAbbr: "VAN"),
            Team(id: "vgk", name: "Golden Knights", city: "Vegas", abbreviation: "VGK", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/vgk.png", primaryColor: "333F42", secondaryColor: "B4975A", apiAbbr: "VEG"),
            Team(id: "wsh", name: "Capitals", city: "Washington", abbreviation: "WSH", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/wsh.png", primaryColor: "041E42", secondaryColor: "C8102E", apiAbbr: "WAS"),
            Team(id: "wpg", name: "Jets", city: "Winnipeg", abbreviation: "WPG", logoURL: "https://a.espncdn.com/i/teamlogos/nhl/500/wpg.png", primaryColor: "041E42", secondaryColor: "004C97", apiAbbr: "WPG")
        ]
    )

    static let nba = League(
        id: "nba",
        name: "National Basketball Association",
        shortName: "NBA",
        logoURL: "https://a.espncdn.com/i/teamlogos/leagues/500/nba.png",
        teams: [
            Team(id: "atl", name: "Hawks", city: "Atlanta", abbreviation: "ATL", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/atl.png", primaryColor: "E03A3E", secondaryColor: "C1D32F", apiAbbr: "ATL"),
            Team(id: "bkn", name: "Nets", city: "Brooklyn", abbreviation: "BKN", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/bkn.png", primaryColor: "000000", secondaryColor: "FFFFFF", apiAbbr: "BKN"),
            Team(id: "bos_nba", name: "Celtics", city: "Boston", abbreviation: "BOS", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/bos.png", primaryColor: "007A33", secondaryColor: "BA9653", apiAbbr: "BOS"),
            Team(id: "cha", name: "Hornets", city: "Charlotte", abbreviation: "CHA", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/cha.png", primaryColor: "1D1160", secondaryColor: "00788C", apiAbbr: "CHA"),
            Team(id: "chi_nba", name: "Bulls", city: "Chicago", abbreviation: "CHI", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/chi.png", primaryColor: "CE1141", secondaryColor: "000000", apiAbbr: "CHI"),
            Team(id: "cle", name: "Cavaliers", city: "Cleveland", abbreviation: "CLE", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/cle.png", primaryColor: "860038", secondaryColor: "041E42", apiAbbr: "CLE"),
            Team(id: "dal_nba", name: "Mavericks", city: "Dallas", abbreviation: "DAL", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/dal.png", primaryColor: "00538C", secondaryColor: "002B5E", apiAbbr: "DAL"),
            Team(id: "den", name: "Nuggets", city: "Denver", abbreviation: "DEN", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/den.png", primaryColor: "0E2240", secondaryColor: "FEC524", apiAbbr: "DEN"),
            Team(id: "det_nba", name: "Pistons", city: "Detroit", abbreviation: "DET", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/det.png", primaryColor: "C8102E", secondaryColor: "006BB6", apiAbbr: "DET"),
            Team(id: "gsw", name: "Warriors", city: "Golden State", abbreviation: "GSW", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/gs.png", primaryColor: "1D428A", secondaryColor: "FFC72C", apiAbbr: "GS"),
            Team(id: "hou", name: "Rockets", city: "Houston", abbreviation: "HOU", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/hou.png", primaryColor: "CE1141", secondaryColor: "000000", apiAbbr: "HOU"),
            Team(id: "ind", name: "Pacers", city: "Indiana", abbreviation: "IND", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/ind.png", primaryColor: "002D62", secondaryColor: "FDBB30", apiAbbr: "IND"),
            Team(id: "lac", name: "Clippers", city: "LA", abbreviation: "LAC", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/lac.png", primaryColor: "C8102E", secondaryColor: "1D428A", apiAbbr: "LAC"),
            Team(id: "lal", name: "Lakers", city: "Los Angeles", abbreviation: "LAL", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/lal.png", primaryColor: "552583", secondaryColor: "FDB927", apiAbbr: "LAL"),
            Team(id: "mem", name: "Grizzlies", city: "Memphis", abbreviation: "MEM", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/mem.png", primaryColor: "5D76A9", secondaryColor: "12173F", apiAbbr: "MEM"),
            Team(id: "mia", name: "Heat", city: "Miami", abbreviation: "MIA", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/mia.png", primaryColor: "98002E", secondaryColor: "F9A01B", apiAbbr: "MIA"),
            Team(id: "mil", name: "Bucks", city: "Milwaukee", abbreviation: "MIL", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/mil.png", primaryColor: "00471B", secondaryColor: "EEE1C6", apiAbbr: "MIL"),
            Team(id: "min_nba", name: "Timberwolves", city: "Minnesota", abbreviation: "MIN", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/min.png", primaryColor: "0C2340", secondaryColor: "236192", apiAbbr: "MIN"),
            Team(id: "nop", name: "Pelicans", city: "New Orleans", abbreviation: "NOP", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/no.png", primaryColor: "0C2340", secondaryColor: "C8102E", apiAbbr: "NO"),
            Team(id: "nyk", name: "Knicks", city: "New York", abbreviation: "NYK", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/ny.png", primaryColor: "006BB6", secondaryColor: "F58426", apiAbbr: "NY"),
            Team(id: "okc", name: "Thunder", city: "Oklahoma City", abbreviation: "OKC", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/okc.png", primaryColor: "007AC1", secondaryColor: "EF6100", apiAbbr: "OKC"),
            Team(id: "orl", name: "Magic", city: "Orlando", abbreviation: "ORL", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/orl.png", primaryColor: "0077C0", secondaryColor: "000000", apiAbbr: "ORL"),
            Team(id: "phi_nba", name: "76ers", city: "Philadelphia", abbreviation: "PHI", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/phi.png", primaryColor: "006BB6", secondaryColor: "ED174C", apiAbbr: "PHI"),
            Team(id: "phx", name: "Suns", city: "Phoenix", abbreviation: "PHX", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/phx.png", primaryColor: "1D1160", secondaryColor: "E56020", apiAbbr: "PHO"),
            Team(id: "por", name: "Trail Blazers", city: "Portland", abbreviation: "POR", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/por.png", primaryColor: "E03A3E", secondaryColor: "000000", apiAbbr: "POR"),
            Team(id: "sac", name: "Kings", city: "Sacramento", abbreviation: "SAC", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/sac.png", primaryColor: "5A2D81", secondaryColor: "63727A", apiAbbr: "SAC"),
            Team(id: "sas", name: "Spurs", city: "San Antonio", abbreviation: "SAS", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/sa.png", primaryColor: "C4CED4", secondaryColor: "000000", apiAbbr: "SA"),
            Team(id: "tor_nba", name: "Raptors", city: "Toronto", abbreviation: "TOR", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/tor.png", primaryColor: "CE1141", secondaryColor: "000000", apiAbbr: "TOR"),
            Team(id: "uta", name: "Jazz", city: "Utah", abbreviation: "UTA", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/uta.png", primaryColor: "002B5C", secondaryColor: "00471B", apiAbbr: "UTA"),
            Team(id: "was", name: "Wizards", city: "Washington", abbreviation: "WAS", logoURL: "https://a.espncdn.com/i/teamlogos/nba/500/wsh.png", primaryColor: "002B5C", secondaryColor: "E31837", apiAbbr: "WAS")
        ]
    )

    static let nfl = League(
        id: "nfl",
        name: "National Football League",
        shortName: "NFL",
        logoURL: "https://a.espncdn.com/i/teamlogos/leagues/500/nfl.png",
        teams: [
            Team(id: "ari", name: "Cardinals", city: "Arizona", abbreviation: "ARI", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/ari.png", primaryColor: "97233F", secondaryColor: "000000", apiAbbr: "ARI"),
            Team(id: "atl_nfl", name: "Falcons", city: "Atlanta", abbreviation: "ATL", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/atl.png", primaryColor: "A71930", secondaryColor: "000000", apiAbbr: "ATL"),
            Team(id: "bal", name: "Ravens", city: "Baltimore", abbreviation: "BAL", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/bal.png", primaryColor: "241773", secondaryColor: "000000", apiAbbr: "BAL"),
            Team(id: "buf_nfl", name: "Bills", city: "Buffalo", abbreviation: "BUF", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/buf.png", primaryColor: "00338D", secondaryColor: "C60C30", apiAbbr: "BUF"),
            Team(id: "car_nfl", name: "Panthers", city: "Carolina", abbreviation: "CAR", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/car.png", primaryColor: "0085CA", secondaryColor: "101820", apiAbbr: "CAR"),
            Team(id: "chi_nfl", name: "Bears", city: "Chicago", abbreviation: "CHI", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/chi.png", primaryColor: "0B162A", secondaryColor: "C83803", apiAbbr: "CHI"),
            Team(id: "cin", name: "Bengals", city: "Cincinnati", abbreviation: "CIN", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/cin.png", primaryColor: "FB4F14", secondaryColor: "000000", apiAbbr: "CIN"),
            Team(id: "cle_nfl", name: "Browns", city: "Cleveland", abbreviation: "CLE", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/cle.png", primaryColor: "311D00", secondaryColor: "FF3C00", apiAbbr: "CLE"),
            Team(id: "dal_nfl", name: "Cowboys", city: "Dallas", abbreviation: "DAL", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/dal.png", primaryColor: "003594", secondaryColor: "869397", apiAbbr: "DAL"),
            Team(id: "den_nfl", name: "Broncos", city: "Denver", abbreviation: "DEN", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/den.png", primaryColor: "FB4F14", secondaryColor: "002244", apiAbbr: "DEN"),
            Team(id: "det_nfl", name: "Lions", city: "Detroit", abbreviation: "DET", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/det.png", primaryColor: "0076B6", secondaryColor: "B0B7BC", apiAbbr: "DET"),
            Team(id: "gb", name: "Packers", city: "Green Bay", abbreviation: "GB", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/gb.png", primaryColor: "203731", secondaryColor: "FFB612", apiAbbr: "GB"),
            Team(id: "hou_nfl", name: "Texans", city: "Houston", abbreviation: "HOU", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/hou.png", primaryColor: "03202F", secondaryColor: "A71930", apiAbbr: "HOU"),
            Team(id: "ind_nfl", name: "Colts", city: "Indianapolis", abbreviation: "IND", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/ind.png", primaryColor: "002C5F", secondaryColor: "A2AAAD", apiAbbr: "IND"),
            Team(id: "jax", name: "Jaguars", city: "Jacksonville", abbreviation: "JAX", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/jax.png", primaryColor: "006778", secondaryColor: "D7A22A", apiAbbr: "JAX"),
            Team(id: "kc", name: "Chiefs", city: "Kansas City", abbreviation: "KC", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/kc.png", primaryColor: "E31837", secondaryColor: "FFB81C", apiAbbr: "KC"),
            Team(id: "lv", name: "Raiders", city: "Las Vegas", abbreviation: "LV", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/lv.png", primaryColor: "000000", secondaryColor: "A5ACAF", apiAbbr: "LV"),
            Team(id: "lac_nfl", name: "Chargers", city: "Los Angeles", abbreviation: "LAC", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/lac.png", primaryColor: "0080C6", secondaryColor: "FFC20E", apiAbbr: "LAC"),
            Team(id: "lar", name: "Rams", city: "Los Angeles", abbreviation: "LAR", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/lar.png", primaryColor: "003594", secondaryColor: "FFA300", apiAbbr: "LAR"),
            Team(id: "mia_nfl", name: "Dolphins", city: "Miami", abbreviation: "MIA", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/mia.png", primaryColor: "008E97", secondaryColor: "FC4C02", apiAbbr: "MIA"),
            Team(id: "min_nfl", name: "Vikings", city: "Minnesota", abbreviation: "MIN", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/min.png", primaryColor: "4F2683", secondaryColor: "FFC62F", apiAbbr: "MIN"),
            Team(id: "ne", name: "Patriots", city: "New England", abbreviation: "NE", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/ne.png", primaryColor: "002244", secondaryColor: "C60C30", apiAbbr: "NE"),
            Team(id: "no", name: "Saints", city: "New Orleans", abbreviation: "NO", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/no.png", primaryColor: "101820", secondaryColor: "D3BC8D", apiAbbr: "NO"),
            Team(id: "nyg", name: "Giants", city: "New York", abbreviation: "NYG", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/nyg.png", primaryColor: "0B2265", secondaryColor: "A71930", apiAbbr: "NYG"),
            Team(id: "nyj", name: "Jets", city: "New York", abbreviation: "NYJ", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/nyj.png", primaryColor: "125740", secondaryColor: "000000", apiAbbr: "NYJ"),
            Team(id: "phi_nfl", name: "Eagles", city: "Philadelphia", abbreviation: "PHI", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/phi.png", primaryColor: "004C54", secondaryColor: "A5ACAF", apiAbbr: "PHI"),
            Team(id: "pit_nfl", name: "Steelers", city: "Pittsburgh", abbreviation: "PIT", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/pit.png", primaryColor: "FFB612", secondaryColor: "101820", apiAbbr: "PIT"),
            Team(id: "sf", name: "49ers", city: "San Francisco", abbreviation: "SF", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/sf.png", primaryColor: "AA0000", secondaryColor: "B3995D", apiAbbr: "SF"),
            Team(id: "sea_nfl", name: "Seahawks", city: "Seattle", abbreviation: "SEA", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/sea.png", primaryColor: "002244", secondaryColor: "69BE28", apiAbbr: "SEA"),
            Team(id: "tb", name: "Buccaneers", city: "Tampa Bay", abbreviation: "TB", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/tb.png", primaryColor: "D50A0A", secondaryColor: "FF7900", apiAbbr: "TB"),
            Team(id: "ten", name: "Titans", city: "Tennessee", abbreviation: "TEN", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/ten.png", primaryColor: "0C2340", secondaryColor: "4B92DB", apiAbbr: "TEN"),
            Team(id: "was_nfl", name: "Commanders", city: "Washington", abbreviation: "WAS", logoURL: "https://a.espncdn.com/i/teamlogos/nfl/500/wsh.png", primaryColor: "5A1414", secondaryColor: "FFB612", apiAbbr: "WAS")
        ]
    )

    static let mlb = League(
        id: "mlb",
        name: "Major League Baseball",
        shortName: "MLB",
        logoURL: "https://a.espncdn.com/i/teamlogos/leagues/500/mlb.png",
        teams: [
            Team(id: "ari_mlb", name: "Diamondbacks", city: "Arizona", abbreviation: "ARI", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/ari.png", primaryColor: "A71930", secondaryColor: "E3D4AD", apiAbbr: "ARI"),
            Team(id: "atl_mlb", name: "Braves", city: "Atlanta", abbreviation: "ATL", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/atl.png", primaryColor: "CE1141", secondaryColor: "13274F", apiAbbr: "ATL"),
            Team(id: "bal_mlb", name: "Orioles", city: "Baltimore", abbreviation: "BAL", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/bal.png", primaryColor: "DF4601", secondaryColor: "000000", apiAbbr: "BAL"),
            Team(id: "bos_mlb", name: "Red Sox", city: "Boston", abbreviation: "BOS", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/bos.png", primaryColor: "BD3039", secondaryColor: "0C2340", apiAbbr: "BOS"),
            Team(id: "chc", name: "Cubs", city: "Chicago", abbreviation: "CHC", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/chc.png", primaryColor: "0E3386", secondaryColor: "CC3433", apiAbbr: "CHC"),
            Team(id: "cws", name: "White Sox", city: "Chicago", abbreviation: "CWS", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/chw.png", primaryColor: "27251F", secondaryColor: "C4CED4", apiAbbr: "CWS"),
            Team(id: "cin_mlb", name: "Reds", city: "Cincinnati", abbreviation: "CIN", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/cin.png", primaryColor: "C6011F", secondaryColor: "000000", apiAbbr: "CIN"),
            Team(id: "cle_mlb", name: "Guardians", city: "Cleveland", abbreviation: "CLE", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/cle.png", primaryColor: "00385D", secondaryColor: "E50022", apiAbbr: "CLE"),
            Team(id: "col_mlb", name: "Rockies", city: "Colorado", abbreviation: "COL", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/col.png", primaryColor: "33006F", secondaryColor: "C4CED4", apiAbbr: "COL"),
            Team(id: "det_mlb", name: "Tigers", city: "Detroit", abbreviation: "DET", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/det.png", primaryColor: "0C2340", secondaryColor: "FA4616", apiAbbr: "DET"),
            Team(id: "hou_mlb", name: "Astros", city: "Houston", abbreviation: "HOU", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/hou.png", primaryColor: "002D62", secondaryColor: "EB6E1F", apiAbbr: "HOU"),
            Team(id: "kc_mlb", name: "Royals", city: "Kansas City", abbreviation: "KC", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/kc.png", primaryColor: "004687", secondaryColor: "BD9B60", apiAbbr: "KC"),
            Team(id: "laa", name: "Angels", city: "Los Angeles", abbreviation: "LAA", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/laa.png", primaryColor: "BA0021", secondaryColor: "003263", apiAbbr: "LAA"),
            Team(id: "lad", name: "Dodgers", city: "Los Angeles", abbreviation: "LAD", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/lad.png", primaryColor: "005A9C", secondaryColor: "EF3E42", apiAbbr: "LAD"),
            Team(id: "mil_mlb", name: "Brewers", city: "Milwaukee", abbreviation: "MIL", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/mil.png", primaryColor: "12284B", secondaryColor: "FFC52F", apiAbbr: "MIL"),
            Team(id: "min_mlb", name: "Twins", city: "Minnesota", abbreviation: "MIN", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/min.png", primaryColor: "002B5C", secondaryColor: "D31145", apiAbbr: "MIN"),
            Team(id: "nym", name: "Mets", city: "New York", abbreviation: "NYM", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/nym.png", primaryColor: "002D72", secondaryColor: "FF5910", apiAbbr: "NYM"),
            Team(id: "nyy", name: "Yankees", city: "New York", abbreviation: "NYY", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/nyy.png", primaryColor: "003087", secondaryColor: "E4002C", apiAbbr: "NYY"),
            Team(id: "oak", name: "Athletics", city: "Oakland", abbreviation: "OAK", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/oak.png", primaryColor: "003831", secondaryColor: "EFB21E", apiAbbr: "OAK"),
            Team(id: "phi_mlb", name: "Phillies", city: "Philadelphia", abbreviation: "PHI", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/phi.png", primaryColor: "E81828", secondaryColor: "002D72", apiAbbr: "PHI"),
            Team(id: "pit_mlb", name: "Pirates", city: "Pittsburgh", abbreviation: "PIT", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/pit.png", primaryColor: "27251F", secondaryColor: "FDB827", apiAbbr: "PIT"),
            Team(id: "sd", name: "Padres", city: "San Diego", abbreviation: "SD", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/sd.png", primaryColor: "2F241D", secondaryColor: "FFC425", apiAbbr: "SD"),
            Team(id: "sf_mlb", name: "Giants", city: "San Francisco", abbreviation: "SF", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/sf.png", primaryColor: "FD5A1E", secondaryColor: "27251F", apiAbbr: "SF"),
            Team(id: "sea_mlb", name: "Mariners", city: "Seattle", abbreviation: "SEA", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/sea.png", primaryColor: "0C2C56", secondaryColor: "005C5C", apiAbbr: "SEA"),
            Team(id: "stl_mlb", name: "Cardinals", city: "St. Louis", abbreviation: "STL", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/stl.png", primaryColor: "C41E3A", secondaryColor: "0C2340", apiAbbr: "STL"),
            Team(id: "tb_mlb", name: "Rays", city: "Tampa Bay", abbreviation: "TB", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/tb.png", primaryColor: "092C5C", secondaryColor: "8FBCE6", apiAbbr: "TB"),
            Team(id: "tex", name: "Rangers", city: "Texas", abbreviation: "TEX", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/tex.png", primaryColor: "003278", secondaryColor: "C0111F", apiAbbr: "TEX"),
            Team(id: "tor_mlb", name: "Blue Jays", city: "Toronto", abbreviation: "TOR", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/tor.png", primaryColor: "134A8E", secondaryColor: "1D2D5C", apiAbbr: "TOR"),
            Team(id: "was_mlb", name: "Nationals", city: "Washington", abbreviation: "WAS", logoURL: "https://a.espncdn.com/i/teamlogos/mlb/500/wsh.png", primaryColor: "AB0003", secondaryColor: "14225A", apiAbbr: "WAS")
        ]
    )

    static let mls = League(
        id: "mls",
        name: "Major League Soccer",
        shortName: "MLS",
        logoURL: "https://a.espncdn.com/combiner/i?img=/i/leaguelogos/soccer/500/19.png&w=200&h=200",
        teams: [
            Team(id: "atl_mls", name: "Atlanta United", city: "Atlanta", abbreviation: "ATL", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/18296.png", primaryColor: "80000A", secondaryColor: "A29061", apiAbbr: "ATL"),
            Team(id: "aus", name: "Austin FC", city: "Austin", abbreviation: "ATX", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/23703.png", primaryColor: "00B140", secondaryColor: "000000", apiAbbr: "ATX"),
            Team(id: "clb", name: "Columbus Crew", city: "Columbus", abbreviation: "CLB", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9906.png", primaryColor: "000000", secondaryColor: "FEDD00", apiAbbr: "CLB"),
            Team(id: "cin_mls", name: "FC Cincinnati", city: "Cincinnati", abbreviation: "CIN", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/21400.png", primaryColor: "F05323", secondaryColor: "263B80", apiAbbr: "CIN"),
            Team(id: "col_mls", name: "Rapids", city: "Colorado", abbreviation: "COL", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9907.png", primaryColor: "862633", secondaryColor: "8BB8E8", apiAbbr: "COL"),
            Team(id: "hou_mls", name: "Dynamo", city: "Houston", abbreviation: "HOU", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9910.png", primaryColor: "F68712", secondaryColor: "101820", apiAbbr: "HOU"),
            Team(id: "inter", name: "Inter Miami", city: "Miami", abbreviation: "MIA", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/22152.png", primaryColor: "F7B5CD", secondaryColor: "231F20", apiAbbr: "MIA"),
            Team(id: "lafc", name: "LAFC", city: "Los Angeles", abbreviation: "LAFC", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/21154.png", primaryColor: "000000", secondaryColor: "C39E6D", apiAbbr: "LAFC"),
            Team(id: "lag", name: "LA Galaxy", city: "Los Angeles", abbreviation: "LAG", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9909.png", primaryColor: "00245D", secondaryColor: "FFD200", apiAbbr: "LAG"),
            Team(id: "min_mls", name: "Minnesota United", city: "Minnesota", abbreviation: "MIN", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/18294.png", primaryColor: "E4E5E6", secondaryColor: "231F20", apiAbbr: "MIN"),
            Team(id: "mtl_mls", name: "CF Montréal", city: "Montreal", abbreviation: "MTL", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9908.png", primaryColor: "000000", secondaryColor: "0033A1", apiAbbr: "MTL"),
            Team(id: "nsh_mls", name: "Nashville SC", city: "Nashville", abbreviation: "NSH", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/22153.png", primaryColor: "ECE83A", secondaryColor: "1F1646", apiAbbr: "NSH"),
            Team(id: "ne_mls", name: "Revolution", city: "New England", abbreviation: "NE", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9913.png", primaryColor: "0A2240", secondaryColor: "CE0E2D", apiAbbr: "NE"),
            Team(id: "nyc", name: "NYCFC", city: "New York", abbreviation: "NYC", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/17012.png", primaryColor: "6CACE4", secondaryColor: "F15524", apiAbbr: "NYC"),
            Team(id: "nyrb", name: "Red Bulls", city: "New York", abbreviation: "NYRB", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9912.png", primaryColor: "ED1E36", secondaryColor: "23326A", apiAbbr: "NYRB"),
            Team(id: "orl_mls", name: "Orlando City", city: "Orlando", abbreviation: "ORL", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/15573.png", primaryColor: "633492", secondaryColor: "FDE192", apiAbbr: "ORL"),
            Team(id: "phi_mls", name: "Union", city: "Philadelphia", abbreviation: "PHI", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9917.png", primaryColor: "071B2C", secondaryColor: "B18500", apiAbbr: "PHI"),
            Team(id: "por_mls", name: "Timbers", city: "Portland", abbreviation: "POR", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9911.png", primaryColor: "004812", secondaryColor: "D69A00", apiAbbr: "POR"),
            Team(id: "rsl", name: "Real Salt Lake", city: "Salt Lake", abbreviation: "RSL", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9914.png", primaryColor: "B30838", secondaryColor: "013A81", apiAbbr: "RSL"),
            Team(id: "sea_mls", name: "Sounders", city: "Seattle", abbreviation: "SEA", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9918.png", primaryColor: "005595", secondaryColor: "658D1B", apiAbbr: "SEA"),
            Team(id: "skc", name: "Sporting KC", city: "Kansas City", abbreviation: "SKC", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9916.png", primaryColor: "002F65", secondaryColor: "91B0D5", apiAbbr: "SKC"),
            Team(id: "sj_mls", name: "Earthquakes", city: "San Jose", abbreviation: "SJ", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9915.png", primaryColor: "0067B1", secondaryColor: "000000", apiAbbr: "SJ"),
            Team(id: "stl_mls", name: "St. Louis City", city: "St. Louis", abbreviation: "STL", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/24102.png", primaryColor: "D22630", secondaryColor: "0A1E42", apiAbbr: "STL"),
            Team(id: "tor_mls", name: "Toronto FC", city: "Toronto", abbreviation: "TOR", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9919.png", primaryColor: "B81137", secondaryColor: "455560", apiAbbr: "TOR"),
            Team(id: "van_mls", name: "Whitecaps", city: "Vancouver", abbreviation: "VAN", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9920.png", primaryColor: "00245E", secondaryColor: "9DC2EA", apiAbbr: "VAN"),
            Team(id: "dc", name: "D.C. United", city: "Washington", abbreviation: "DC", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/9905.png", primaryColor: "000000", secondaryColor: "EF3E42", apiAbbr: "DC"),
            Team(id: "cha_mls", name: "Charlotte FC", city: "Charlotte", abbreviation: "CLT", logoURL: "https://a.espncdn.com/i/teamlogos/soccer/500/23998.png", primaryColor: "1A85C8", secondaryColor: "000000", apiAbbr: "CLT")
        ]
    )

    static func league(for id: String) -> League? {
        allLeagues.first { $0.id == id }
    }

    static func team(for teamId: String) -> Team? {
        allLeagues.flatMap(\.teams).first { $0.id == teamId }
    }

    static func teamByAPIAbbr(_ abbr: String, leagueId: String) -> Team? {
        guard let league = league(for: leagueId) else { return nil }
        return league.teams.first { $0.apiAbbr == abbr }
    }

    static func teamNameForAPIAbbr(_ abbr: String, leagueId: String) -> String {
        if let team = teamByAPIAbbr(abbr, leagueId: leagueId) {
            return "\(team.city) \(team.name)"
        }
        return abbr
    }

    static func logoURLForAPIAbbr(_ abbr: String, leagueId: String) -> String? {
        teamByAPIAbbr(abbr, leagueId: leagueId)?.logoURL
    }
}
