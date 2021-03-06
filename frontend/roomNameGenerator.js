// This file is taken, with small modifications, from
// https://github.com/jitsi/js-utils, random/roomNameGenerator.js.
//
// It is licensed under the Apache License 2.0.

// Compared with the original, this version contains just half as many words.

/*
const _NOUN_ = [
];
*/

/**
 * The list of plural nouns.
 * @const
 */
const _PLURALNOUN_ = [
    'Abilities', 'Absences', 'Abundances', 'Academics',
    'Accommodations', 'Accomplishments', 'Accordances', 'Accountabilities',
    'Accused', 'Achievements', 'Acids', 'Acquisitions', 'Acres', 'Actions',
    'Adaptations', 'Addictions', 'Additions', 'Addresses', 'Adjustments',
    'Adoptions', 'Ads', 'Adults', 'Advances', 'Advantages', 'Adventures',
    'Affections', 'Aftermaths', 'Afternoons', 'Agencies', 'Agendas',
    'Alarms', 'Albums', 'Alerts', 'Aliens', 'Alignments',
    'Alternatives', 'Aluminium', 'Amateurs', 'Ambassadors', 'Ambitions',
    'Analysts', 'Ancestors', 'Anchors', 'Angels', 'Angers', 'Angles',
    'Answers', 'Anxieties', 'Apartments', 'Apologies', 'Apparatus',
    'Applications', 'Appointments', 'Appreciations', 'Approaches',
    'Archives', 'Areas', 'Arenas', 'Arguments', 'Armies',
    'Artists', 'Arts', 'Artworks', 'Ashes', 'Aspects', 'Aspirations',
    'Assets', 'Assignments', 'Assistances', 'Assistants', 'Associations',
    'Attachments', 'Attacks', 'Attempts', 'Attendances',
    'Auctions', 'Audiences', 'Audits', 'Augusts', 'Aunts', 'Authorities',
    'Averages', 'Awards', 'Awarenesses', 'Babies', 'Backdrops',
    'Bags', 'Bails', 'Balances', 'Ballets', 'Balloons', 'Ballots', 'Balls',
    'Barriers', 'Bars', 'Baseballs', 'Basements', 'Bases',
    'Batteries', 'Battlefields', 'Battles', 'Bays', 'Beaches', 'Beams',
    'Beefs', 'Beers', 'Bees', 'Beginnings', 'Behalves', 'Behaviours',
    'Beneficiaries', 'Benefits', 'Bests', 'Bets', 'Betters', 'Biases',
    'Biologies', 'Birds', 'Birthdays', 'Births', 'Biscuits', 'Bishops',
    'Blasts', 'Blends', 'Blessings', 'Blocks', 'Blogs', 'Bloods', 'Blows',
    'Bones', 'Bonus', 'Bookings', 'Books', 'Booms', 'Boosts', 'Boots',
    'Bows', 'Boxes', 'Brains', 'Branches', 'Brands',
    'Breakthroughs', 'Breathings', 'Breaths', 'Breeds',
    'Broadcasts', 'Browsers', 'Brushes', 'Bubbles', 'Bucks',
    'Bullets', 'Bunches', 'Burdens', 'Bureaucracies', 'Burials', 'Burns',
    'Cabinets', 'Cabins', 'Cables', 'Cafes', 'Cakes', 'Calculations',
    'Canals', 'Candidates', 'Candles', 'Cans', 'Canvas',
    'Captains', 'Captures', 'Carbons', 'Cards', 'Careers', 'Cares',
    'Cases', 'Cashes', 'Casinos', 'Castles', 'Casts',
    'Cautions', 'Caves', 'Cds', 'Ceilings', 'Celebrations', 'Celebrities',
    'Certainties', 'Certificates', 'Chains', 'Chairmen', 'Chairs',
    'Changes', 'Channels', 'Chaos', 'Chapters', 'Characteristics',
    'Chases', 'Chats', 'Cheats', 'Checks', 'Cheeks', 'Cheers', 'Cheeses',
    'Childhoods', 'Chips', 'Chocolates', 'Choices', 'Choirs', 'Chunks',
    'Circulations', 'Circumstances', 'Cities', 'Citizens', 'Citizenships',
    'Classes', 'Classics', 'Classifications', 'Classrooms', 'Clauses',
    'Clinics', 'Clips', 'Clocks', 'Closes', 'Closures', 'Clothes',
    'Coaches', 'Coalitions', 'Coals', 'Coasts', 'Coats', 'Cocktails',
    'Collapses', 'Colleagues', 'Collections', 'Collectors', 'Colleges',
    'Combinations', 'Comedies', 'Comforts', 'Comics', 'Commanders',
    'Commercials', 'Commissioners', 'Commissions', 'Commitments',
    'Companies', 'Companions', 'Comparisons', 'Compassions',
    'Complaints', 'Completions', 'Complexes', 'Complexities', 'Compliances',
    'Compromises', 'Computers', 'Concentrations', 'Conceptions', 'Concepts',
    'Conditions', 'Conducts', 'Conferences', 'Confessions', 'Confidences',
    'Confusions', 'Congregations', 'Connections', 'Consciences',
    'Conservations', 'Conservatives', 'Considerations', 'Consistencies',
    'Constructions', 'Consultants', 'Consultations', 'Consumers',
    'Contentions', 'Contents', 'Contests', 'Contexts', 'Continents',
    'Contributions', 'Contributors', 'Controls', 'Controversies',
    'Convictions', 'Cookers', 'Cookings', 'Cooks', 'Coordinations',
    'Corners', 'Corporations', 'Corrections', 'Correlations',
    'Costs', 'Costumes', 'Cottages', 'Cottons', 'Councillors', 'Councils',
    'Countries', 'Countrysides', 'Counts', 'Couples', 'Coups', 'Courages',
    'Cows', 'Cracks', 'Crafts', 'Crashes', 'Creams', 'Creations',
    'Crews', 'Cries', 'Crises', 'Criteria',
    'Crowns', 'Cruises', 'Crystals', 'Cues', 'Cults', 'Cultures',
    'Curricula', 'Curtains', 'Custodies', 'Customers', 'Customs',
    'Dancers', 'Dances', 'Dancings', 'Dangers', 'Darknesses', 'Darks',
    'Deadlines', 'Dealers', 'Deals', 'Debates', 'Debris', 'Debts',
    'Decks', 'Declarations', 'Declines', 'Decorations', 'Decreases',
    'Defenders', 'Deficiencies', 'Deficits', 'Definitions', 'Degrees',
    'Demands', 'Democracies', 'Demons', 'Demonstrations', 'Denials',
    'Deployments', 'Deposits', 'Depressions', 'Depths', 'Deputies',
    'Desires', 'Desks', 'Desktops', 'Destinations', 'Destructions',
    'Developments', 'Devices', 'Devils', 'Diagnoses', 'Diagrams',
    'Diets', 'Differences', 'Difficulties', 'Dignities', 'Dilemmas',
    'Directors', 'Dirts', 'Disabilities', 'Disadvantages', 'Disagreements',
    'Discounts', 'Discourses', 'Discoveries', 'Discretions',
    'Disks', 'Dislikes', 'Dismissals', 'Disorders', 'Displays', 'Disposals',
    'Distributions', 'Districts', 'Diversities', 'Dives', 'Divides',
    'Documentations', 'Documents', 'Dogs', 'Dollars', 'Domains',
    'Downloads', 'Downtowns', 'Dozens', 'Drafts', 'Dramas', 'Drawings',
    'Droughts', 'Drums', 'Duos', 'Durations', 'Dusts', 'Duties',
    'Eases', 'Easts', 'Echoes', 'Economics', 'Economies', 'Economists',
    'Effectivenesses', 'Effects', 'Efficiencies', 'Efforts', 'Eggs', 'Egos',
    'Elephants', 'Elites', 'Emails', 'Embarrassments', 'Embassies',
    'Empires', 'Employees', 'Employers', 'Employments', 'Encounters',
    'Enemies', 'Energies', 'Enforcements', 'Engagements', 'Engineerings',
    'Enthusiasms', 'Enthusiasts', 'Entities', 'Entrances', 'Entrepreneurs',
    'Equalities', 'Equals', 'Equations', 'Equipment', 'Equivalents', 'Eras',
    'Estimates', 'Ethics', 'Euros', 'Evaluations', 'Evenings', 'Events',
    'Excellences', 'Exceptions', 'Excesses', 'Exchanges', 'Excitements',
    'Exhibitions', 'Exhibits', 'Exiles', 'Existences', 'Exits',
    'Experiences', 'Experiments', 'Expertises', 'Experts', 'Explanations',
    'Exposures', 'Expressions', 'Extensions', 'Extents', 'Extracts',
    'Facilities', 'Factions', 'Factories', 'Factors', 'Facts', 'Faculties',
    'Fans', 'Fantasies', 'Fares', 'Farmers', 'Farmings', 'Farms',
    'Feathers', 'Feats', 'Features', 'Februaries', 'Feedbacks', 'Feeds',
    'Festivals', 'Fevers', 'Fibres', 'Fictions', 'Fields', 'Fightings',
    'Finals', 'Finances', 'Findings', 'Fines', 'Fingers', 'Finishes',
    'Fish', 'Fishings', 'Fitnesses', 'Fits', 'Fixes', 'Fixtures', 'Flags',
    'Flexibilities', 'Flies', 'Flights', 'Floods', 'Floors', 'Flours',
    'Folks', 'Followings', 'Foods', 'Fools', 'Footages', 'Footballs',
    'Formats', 'Forms', 'Formulae', 'Fortunes', 'Forums', 'Fossils',
    'Frameworks', 'Franchises', 'Frauds', 'Freedoms', 'Frequencies',
    'Fruits', 'Frustrations', 'Fuels', 'Functions', 'Fundings',
    'Futures', 'Gains', 'Galleries', 'Gallons', 'Gamblings', 'Games',
    'Gatherings', 'Gazes', 'Gears', 'Genders', 'Generations', 'Genes',
    'Ghosts', 'Giants', 'Gifts', 'Gigs', 'Glances', 'Glasses', 'Glimpses',
    'Goes', 'Gold', 'Golfs', 'Goodbyes', 'Goodnesses', 'Goods',
    'Graduates', 'Grains', 'Grandfathers', 'Grandmothers', 'Grandparents',
    'Greenhouses', 'Greens', 'Greys', 'Grids', 'Griefs', 'Grins', 'Grips',
    'Guerrillas', 'Guesses', 'Guests', 'Guidances', 'Guidelines', 'Guides',
    'Habits', 'Hairs', 'Halls', 'Halts', 'Halves', 'Handfuls', 'Handles',
    'Hardwares', 'Harmonies', 'Harms', 'Harvests',
    'Healthcares', 'Healths', 'Hearings', 'Hearts', 'Heatings', 'Heats',
    'Helmets', 'Helps', 'Herbs', 'Heritages', 'Heroes', 'Hierarchies',
    'Historians', 'Histories', 'Hits', 'Hobbies', 'Hockeys', 'Holds',
    'Honours', 'Hooks', 'Hopes', 'Horizons', 'Horns', 'Horrors', 'Horses',
    'Households', 'Houses', 'Housings', 'Humanities', 'Humans', 'Humours',
    'Hydrogens', 'Hypotheses', 'Ices', 'Icons', 'Ideals', 'Ideas',
    'Ignorances', 'Illusions', 'Illustrations', 'Imageries',
    'Implementations', 'Implications', 'Importances', 'Imports',
    'Incentives', 'Inches', 'Incidences', 'Incidents', 'Inclusions',
    'Indices', 'Indictments', 'Individuals', 'Industries', 'Inequalities',
    'Infos', 'Infrastructures', 'Ingredients', 'Inhabitants', 'Initiatives',
    'Innovations', 'Inputs', 'Inquiries', 'Insects', 'Insertions',
    'Inspirations', 'Installations', 'Instances', 'Instincts', 'Institutes',
    'Insurances', 'Intakes', 'Integrations', 'Integrities', 'Intellectuals',
    'Interests', 'Interfaces', 'Interferences', 'Interiors',
    'Introductions', 'Invasions', 'Inventions', 'Investigations',
    'Involvements', 'Ironies', 'Irons', 'Islands', 'Isolations', 'Issues',
    'Jeans', 'Jets', 'Jewelleries', 'Jobs', 'Joints', 'Jokes',
    'Judgements', 'Judges', 'Juices', 'Julies', 'Jumps', 'Junctions',
    'Keyboards', 'Keys', 'Kicks', 'Kidneys', 'Kilometres',
    'Knives', 'Knocks', 'Knowledges', 'Labels', 'Laboratories', 'Labours',
    'Landings', 'Landlords', 'Landmarks', 'Lands', 'Landscapes', 'Lanes',
    'Laughters', 'Launches', 'Lawns', 'Laws', 'Lawsuits', 'Lawyers',
    'Leagues', 'Leaks', 'Leaps', 'Learnings', 'Leathers',
    'Legislatures', 'Legs', 'Leisures', 'Lemons', 'Lengths', 'Lens',
    'Libraries', 'Licences', 'Lies', 'Lifestyles', 'Lifetimes', 'Lifts',
    'Limits', 'LineUps', 'Lines', 'Links', 'Lions', 'Lips', 'Liquids',
    'Litters', 'Livers', 'Lives', 'Livings', 'Loads', 'Loans', 'Lobbies',
    'Loops', 'Lords', 'Lorries', 'Losses', 'Lotteries', 'Loves', 'Lows',
    'Machineries', 'Machines', 'Magazines', 'Magics', 'Magistrates',
    'Majorities', 'MakeUps', 'Makes', 'Makings', 'Malls',
    'Manufacturings', 'Manuscripts', 'Maps', 'Marathons',
    'Markets', 'Marks', 'Marriages', 'Masks', 'Masses',
    'Matters', 'Maximums', 'Mayors', 'Mays', 'Meals', 'Meanings', 'Means',
    'Mechanisms', 'Medals', 'Media', 'Medications', 'Medicines',
    'Memoirs', 'Memorials', 'Memories', 'Memos', 'Mentions',
    'Messages', 'Messes', 'Metals', 'Metaphors', 'Methodologies', 'Methods',
    'Miles', 'Milks', 'Mills',
    'Ministers', 'Ministries', 'Minutes', 'Miracles',
    'Mixtures', 'Mobiles', 'Mobilities', 'Mobs', 'Modes',
    'Monkeys', 'Monks', 'Monopolies', 'Monsters', 'Months', 'Monuments',
    'Mothers', 'Motions', 'Motivations', 'Motives',
    'Movements', 'Moves', 'Movies', 'Muds', 'Mums', 'Muscles',
    'Nails', 'Names', 'Narratives', 'Nationals', 'Nations',
    'Negatives', 'Neglects', 'Negotiations', 'Neighbourhoods', 'Neighbours',
    'Newspapers', 'Niches', 'Nightmares', 'Nights', 'Noises', 'Nominations',
    'Notebooks', 'Notes', 'Notices', 'Notions', 'Novelists', 'Novels',
    'Nuts', 'Obesities', 'Objections', 'Objectives', 'Objects',
    'Occasions', 'Occupations', 'Occurrences', 'Oceans', 'Octobers', 'Odds',
    'Officials', 'Offspring', 'Oils', 'Onions', 'Openings', 'Operas',
    'Opposites', 'Oppositions', 'Optimisms', 'Options', 'Oranges',
    'Orientations', 'Originals', 'Origins', 'Outbreaks', 'Outcomes',
    'Outrages', 'Outsiders', 'Outsides', 'Ovens', 'Owners', 'Ownerships',
    'Pains', 'Painters', 'Paintings', 'Paints', 'Pairs', 'Palaces', 'Palms',
    'Parallels', 'Parameters', 'Parents', 'Parishes', 'Parkings', 'Parks',
    'Partnerships', 'Parts', 'Passages', 'Passengers', 'Passes', 'Passings',
    'Patents', 'Paths', 'Pathways', 'Patiences', 'Patients', 'Patrols',
    'Peasants', 'Peers', 'Penalties', 'Pencils', 'Pennies', 'Pens',
    'Perceptions', 'Performances', 'Periods', 'Permissions', 'Permits',
    'Pets', 'Phases', 'Phenomena', 'Philosophers', 'Philosophies', 'Phones',
    'Physicians', 'Physics', 'Pianos', 'Picks', 'Pictures', 'Pieces',
    'Pipelines', 'Pipes', 'Pirates', 'Pitches', 'Pities', 'Pits',
    'Plants', 'Plastics', 'Plates', 'Platforms', 'Players', 'Plays',
    'Poems', 'Poetries', 'Poets', 'Points', 'Poisons', 'Poles', 'Police',
    'Pollutions', 'Ponds', 'Pools', 'Pops', 'Popularities', 'Populations',
    'Positives', 'Possessions', 'Possibilities', 'Posters', 'Posts',
    'Powers', 'Practices', 'Practitioners', 'Praises', 'Prayers',
    'Preferences', 'Pregnancies', 'Prejudices', 'Premises', 'Premiums',
    'Presents', 'Preservations', 'Presidencies', 'Presidents', 'Presses',
    'Priests', 'Princes', 'Princesses', 'Principals', 'Principles',
    'Privacies', 'Privatizations', 'Privileges', 'Prizes', 'Probabilities',
    'Processes', 'Processings', 'Processors', 'Producers', 'Produces',
    'Professions', 'Professors', 'Profiles', 'Profits', 'Programmes',
    'Promises', 'Promotions', 'Proofs', 'Propagandas', 'Properties',
    'Prosecutors', 'Prospects', 'Prosperities', 'Protections', 'Proteins',
    'Psychologies', 'Psychologists', 'Publications', 'Publicities',
    'Punishments', 'Punks', 'Pupils', 'Purchases', 'Purples', 'Purposes',
    'Quantities', 'Quarters', 'Queens', 'Queries', 'Questionnaires',
    'Races', 'Racings', 'Radars', 'Radiations',
    'Ranges', 'Rankings', 'Ranks', 'Rates', 'Ratings', 'Ratios',
    'Realities', 'Realizations', 'Realms', 'Rears', 'Reasonings', 'Reasons',
    'Recessions', 'Recipes', 'Recipients', 'Recognitions',
    'Recoveries', 'Recruitments', 'Recruits', 'Reductions',
    'Refusals', 'Regards', 'Regimes', 'Regions',
    'Rehabilitations', 'Reigns', 'Rejections', 'Relations', 'Relationships',
    'Religions', 'Remainders', 'Remains', 'Remarks', 'Remedies',
    'Replacements', 'Replies', 'Reporters', 'Reportings', 'Reports',
    'Reputations', 'Requests', 'Requirements', 'Rescues', 'Researchers',
    'Residues', 'Resignations', 'Resistances', 'Resolutions', 'Resorts',
    'Restorations', 'Restraints', 'Restrictions', 'Rests', 'Results',
    'Revenges', 'Revenues', 'Reverses', 'Reviews', 'Revisions', 'Revivals',
    'Rifles', 'Rights', 'Rings', 'Riots', 'Rises', 'Risks', 'Rituals',
    'Rods', 'Roles', 'Rolls', 'Romances', 'Roofs', 'Rooms', 'Roots',
    'Rubbers', 'Rubbishes', 'Rugbies', 'Ruins', 'Rules', 'Rulings',
    'Safeties', 'Sailings', 'Sailors', 'Sails', 'Saints', 'Sakes', 'Salads',
    'Sandwiches', 'Satellites', 'Satisfactions', 'Saturdays', 'Sauces',
    'Scenes', 'Schedules', 'Schemes', 'Scholars', 'Scholarships', 'Schools',
    'Screenings', 'Screens', 'Screws', 'Scripts', 'Scrutinies',
    'Seconds', 'Secretaries', 'Secrets', 'Sections', 'Sectors',
    'Seminars', 'Senators', 'Sensations', 'Senses', 'Sensitivities',
    'Series', 'Servants', 'Services', 'Sessions', 'SetUps', 'Sets',
    'Shadows', 'Shakes', 'Shames', 'Shapes', 'Shareholders', 'Shares',
    'Shippings', 'Ships', 'Shirts', 'Shocks', 'Shoes', 'Shootings',
    'Shoulders', 'Shouts', 'Showers', 'Shows', 'Siblings', 'Sides', 'Sighs',
    'Silks', 'Silver', 'Similarities', 'Simulations', 'Singers', 'Singings',
    'Sketches', 'Skies', 'Skiings', 'Skills', 'Skins', 'Skirts', 'Skis',
    'Slogans', 'Slopes', 'Slots', 'Smartphones', 'Smells', 'Smiles',
    'Societies', 'Socks', 'Softwares', 'Soils', 'Soldiers', 'Solicitors',
    'Sorts', 'Souls', 'Sounds', 'Soups', 'Sources',
    'Species', 'Specifications', 'Specimens', 'Spectacles', 'Spectators',
    'Spendings', 'Spheres', 'Spices', 'Spiders', 'Spies', 'Spines', 'Spins',
    'Sponsorships', 'Spoons', 'Sports', 'Spotlights', 'Spots', 'Spouses',
    'Staffs', 'Stages', 'Stairs', 'Stakes', 'Stalls', 'Stamps', 'Stances',
    'Stations', 'Statistics', 'Statues', 'Status', 'Stays', 'Steams',
    'Stocks', 'Stomachs', 'Stones', 'Stops', 'Storages', 'Stores',
    'Streams', 'Streets', 'Strengths', 'Stresses', 'Stretches', 'Strikes',
    'Studies', 'Studios', 'Stuffs', 'Styles', 'Subjects', 'Submissions',
    'Substitutes', 'Substitutions', 'Suburbs', 'Successes', 'Successions',
    'Suites', 'Suits', 'Summaries', 'Summers', 'Summits', 'Sums', 'Sundays',
    'Supplies', 'Supporters', 'Supports', 'Surfaces', 'Surgeons',
    'Surveys', 'Survivals', 'Survivors', 'Suspects', 'Suspensions',
    'Switches', 'Swords', 'Symbols', 'Sympathies', 'Symptoms', 'Syndromes',
    'Tactics', 'Tags', 'Tails', 'Talents', 'Tales', 'Talks', 'Tanks',
    'Taxpayers', 'Teachers', 'Teachings', 'Teams', 'Tears', 'Teas',
    'Telephones', 'Televisions', 'Temperatures', 'Temples', 'Tenants',
    'Terms', 'Terrains', 'Territories',
    'Textures', 'Thanks', 'Theatres', 'Thefts', 'Themes', 'Theologies',
    'Thinkings', 'Thirds', 'Thoughts', 'Threads', 'Threats', 'Thresholds',
    'Times', 'Timings', 'Tins', 'Tips', 'Tissues', 'Titles', 'Tobaccos',
    'Tomorrows', 'Tones', 'Tongues', 'Tonights', 'Tonnes', 'Tons', 'Tools',
    'Tourists', 'Tournaments', 'Tours', 'Towels', 'Towers', 'Towns', 'Toys',
    'Traffics', 'Tragedies', 'Trailers', 'Trails', 'Trainers', 'Trainings',
    'Transformations', 'Transitions', 'Transits', 'Translations',
    'Traps', 'Traumas', 'Travellers', 'Travels', 'Treasures', 'Treaties',
    'Tributes', 'Tricks', 'Tries', 'Triggers', 'Trios', 'Trips', 'Triumphs',
    'Trusts', 'Truths', 'Tsunamis', 'Tubes', 'Tuesdays', 'Tuitions',
    'Twists', 'Types', 'Tyres', 'Umbrellas', 'Uncertainties', 'Uncles',
    'Uniforms', 'Unions', 'Unities', 'Units', 'Universes', 'Universities',
    'Vacations', 'Vacuums', 'Validities', 'Valleys', 'Values', 'Vans',
    'Veins', 'Ventures', 'Venues', 'Verdicts', 'Verses', 'Versions',
    'Viewers', 'Viewpoints', 'Views', 'Villagers', 'Villages', 'Violations',
    'Visits', 'Vitamins', 'Voices', 'Volumes', 'Volunteers', 'Votes',
    'Walls', 'Wards', 'Warehouses', 'Warfares', 'Warmings', 'Warnings',
    'Watches', 'Waters', 'Waves', 'Ways', 'Weaknesses', 'Wealths',
    'Weeds', 'Weekends', 'Weeks', 'Weights', 'Welcomes', 'Welfares',
    'Wholes', 'Widows', 'Widths', 'Wildlives', 'Willingnesses',
    'Winters', 'Wires', 'Wisdoms', 'Wishes', 'Withdrawals', 'Witnesses',
    'Workouts', 'Workplaces', 'Works', 'Workshops', 'Worlds', 'Worms',
    'Writers', 'Writings', 'Wrongs', 'Yards', 'Years', 'Yellows',
];

/*
const _PLACE_ = [
    'Pub', 'University', 'Airport', 'Library', 'Mall', 'Theater', 'Stadium',
    'Office', 'Show', 'Gallows', 'Beach', 'Cemetery', 'Hospital', 'Reception',
    'Restaurant', 'Bar', 'Church', 'House', 'School', 'Square', 'Village',
    'Cinema', 'Movies', 'Party', 'Restroom', 'End', 'Jail', 'PostOffice',
    'Station', 'Circus', 'Gates', 'Entrance', 'Bridge'
];
*/

/**
 * The list of verbs.
 * @const
 */
const _VERB_ = [
    'Abolish', 'Absorb', 'Accelerate', 'Accept',
    'Accumulate', 'Accuse', 'Achieve', 'Acknowledge', 'Acquire', 'Act',
    'Admire', 'Admit', 'Adopt', 'Advance', 'Advertise', 'Advise',
    'Alert', 'Align', 'Allege', 'Allocate', 'Allow', 'Alter', 'Amend',
    'Apologize', 'Appeal', 'Appear', 'Applaud', 'Apply', 'Appoint',
    'Arrest', 'Arrive', 'Articulate', 'Ask', 'Aspire',
    'Assume', 'Assure', 'Attach', 'Attain', 'Attempt', 'Attend',
    'Award', 'Back', 'Bake', 'Balance', 'Ban', 'Bar', 'Base', 'Bat',
    'Believe', 'Belong', 'Bend', 'Benefit', 'Bet', 'Betray', 'Bid', 'Bill',
    'Blow', 'Board', 'Boast', 'Boil', 'Book', 'Boost', 'Border',
    'Breathe', 'Breed', 'Bring', 'Broadcast', 'Brush', 'Build', 'Burn',
    'Cancel', 'Capture', 'Care', 'Carry', 'Carve', 'Cast', 'Catch', 'Cater',
    'Change', 'Characterize', 'Charge', 'Chart', 'Chase', 'Chat', 'Cheat',
    'Claim', 'Clarify', 'Classify', 'Clean', 'Clear', 'Click', 'Climb',
    'Collect', 'Combat', 'Combine', 'Come', 'Comfort', 'Command',
    'Compel', 'Compensate', 'Compete', 'Compile', 'Complain', 'Complement',
    'Conceal', 'Concede', 'Conceive', 'Concentrate', 'Concern', 'Conclude',
    'Conflict', 'Confront', 'Confuse', 'Congratulate', 'Connect', 'Conquer',
    'Constitute', 'Construct', 'Consult', 'Consume', 'Contact', 'Contain',
    'Contribute', 'Control', 'Convert', 'Convey', 'Convict', 'Convince',
    'Correlate', 'Correspond', 'Cost', 'Count', 'Counter', 'Cover', 'Crack',
    'Cross', 'Cruise', 'Crush', 'Cry', 'Cultivate', 'Cure', 'Curve', 'Cut',
    'Declare', 'Decline', 'Decorate', 'Decrease', 'Deem', 'Defeat',
    'Demand', 'Demonstrate', 'Denounce', 'Deny', 'Depart', 'Depend',
    'Describe', 'Desert', 'Deserve', 'Design', 'Designate', 'Desire',
    'Devastate', 'Develop', 'Devise', 'Devote', 'Diagnose', 'Dictate',
    'Disagree', 'Disappear', 'Disappoint', 'Discard', 'Discharge',
    'Dismiss', 'Displace', 'Display', 'Dispose', 'Dispute', 'Disrupt',
    'Distribute', 'Disturb', 'Dive', 'Divert', 'Divide', 'Divorce', 'Do',
    'Draft', 'Drag', 'Drain', 'Draw', 'Dream', 'Dress', 'Drift', 'Drink',
    'Echo', 'Edit', 'Educate', 'Elect', 'Elevate', 'Eliminate', 'Email',
    'Empower', 'Empty', 'Enable', 'Enact', 'Encompass', 'Encounter',
    'Enjoy', 'Enquire', 'Enrich', 'Enrol', 'Ensue', 'Ensure', 'Enter',
    'Escape', 'Establish', 'Estimate', 'Evacuate', 'Evaluate', 'Evoke',
    'Excuse', 'Execute', 'Exercise', 'Exert', 'Exhibit', 'Exist', 'Exit',
    'Explode', 'Exploit', 'Explore', 'Export', 'Expose', 'Express',
    'Fancy', 'Farm', 'Fasten', 'Favour', 'Fear', 'Feature', 'Feed', 'Feel',
    'Fine', 'Finish', 'Fire', 'Fish', 'Fit', 'Fix', 'Flash', 'Flee',
    'Forbid', 'Force', 'Forecast', 'Forge', 'Forget', 'Forgive', 'Form',
    'Fry', 'Fuel', 'Fulfil', 'Function', 'Fund', 'Gain', 'Gather', 'Gaze',
    'Graduate', 'Grant', 'Grasp', 'Greet', 'Grin', 'Grind', 'Grip', 'Grow',
    'Handle', 'Hang', 'Happen', 'Harvest', 'Haunt', 'Have',
    'Highlight', 'Hint', 'Hire', 'Hit', 'Hold', 'Honour', 'Hook', 'Hope',
    'Illustrate', 'Imagine', 'Impact', 'Implement', 'Imply', 'Import',
    'Increase', 'Incur', 'Indicate', 'Induce', 'Indulge', 'Infect', 'Infer',
    'Inject', 'Injure', 'Insert', 'Insist', 'Inspect', 'Inspire', 'Install',
    'Interest', 'Interfere', 'Interpret', 'Interrupt', 'Intervene',
    'Invite', 'Invoke', 'Involve', 'Iron', 'Isolate', 'Issue',
    'Kiss', 'Knock', 'Know', 'Label', 'Lack', 'Land',
    'Learn', 'Leave', 'Lecture', 'Lend', 'Let', 'Level', 'License', 'Lift',
    'Live', 'Load', 'Lobby', 'Locate', 'Lock', 'Log', 'Look', 'Loom',
    'Manifest', 'Manipulate', 'Manufacture', 'Map', 'March', 'Mark',
    'Maximize', 'Mean', 'Measure', 'Meet', 'Melt', 'Mention', 'Merge',
    'Modify', 'Monitor', 'Motivate', 'Mount', 'Move', 'Multiply',
    'Note', 'Notice', 'Notify', 'Number', 'Obey', 'Object', 'Oblige',
    'Open', 'Operate', 'Oppose', 'Opt', 'Order', 'Organize', 'Originate',
    'Overwhelm', 'Owe', 'Own', 'Pace', 'Pack', 'Package', 'Paint', 'Park',
    'Permit', 'Persist', 'Persuade', 'Phone', 'Photograph', 'Pick',
    'Plead', 'Please', 'Pledge', 'Plot', 'Plug', 'Plunge', 'Point',
    'Postpone', 'Pour', 'Power', 'Practise', 'Praise', 'Pray', 'Preach',
    'Preserve', 'Preside', 'Press', 'Presume', 'Pretend', 'Prevail',
    'Produce', 'Program', 'Progress', 'Prohibit', 'Project', 'Promise',
    'Protest', 'Prove', 'Provide', 'Provoke', 'Publish', 'Pull', 'Pump',
    'Question', 'Queue', 'Quit', 'Quote', 'Race', 'Raid', 'Rain', 'Raise',
    'Realize', 'Reassure', 'Rebuild', 'Recall', 'Receive', 'Reckon',
    'Recycle', 'Reduce', 'Refer', 'Reflect', 'Reform', 'Refuse', 'Regain',
    'Reject', 'Relate', 'Relax', 'Release', 'Relieve', 'Rely', 'Remain',
    'Repair', 'Repeat', 'Replace', 'Reply', 'Report', 'Represent',
    'Reserve', 'Reside', 'Resign', 'Resist', 'Resolve', 'Respect',
    'Retire', 'Retreat', 'Retrieve', 'Return', 'Reveal', 'Reverse',
    'Rise', 'Risk', 'Rob', 'Rock', 'Roll', 'Rotate', 'Rub', 'Ruin', 'Rule',
    'Say', 'Scan', 'Scare', 'Schedule', 'Score', 'Scratch', 'Scream',
    'Seize', 'Select', 'Sell', 'Send', 'Sense', 'Sentence', 'Separate',
    'Shelter', 'Shift', 'Shine', 'Ship', 'Shock', 'Shoot', 'Shop', 'Shout',
    'Sing', 'Sink', 'Sit', 'Ski', 'Skip', 'Slam', 'Slap', 'Slash', 'Sleep',
    'Smoke', 'Snap', 'Snow', 'Soak', 'Soar', 'Solve', 'Sort', 'Sound',
    'Speed', 'Spell', 'Spend', 'Spill', 'Spin', 'Split', 'Spoil', 'Sponsor',
    'Stage', 'Stand', 'Star', 'Stare', 'Start', 'Starve', 'State', 'Stay',
    'Store', 'Strengthen', 'Stress', 'Stretch', 'Strike', 'Strip', 'Strive',
    'Substitute', 'Succeed', 'Sue', 'Suffer', 'Suggest', 'Suit',
    'Suppose', 'Suppress', 'Surge', 'Surprise', 'Surrender', 'Surround',
    'Swear', 'Sweep', 'Swim', 'Swing', 'Switch', 'Tackle', 'Tag', 'Take',
    'Tell', 'Tempt', 'Tend', 'Term', 'Terminate', 'Terrify', 'Test',
    'Tidy', 'Tie', 'Tighten', 'Time', 'Tip', 'Title', 'Tolerate', 'Top',
    'Trail', 'Train', 'Transfer', 'Transform', 'Translate', 'Transmit',
    'Trouble', 'Trust', 'Try', 'Turn', 'Twist', 'Type', 'Undergo',
    'Unveil', 'Update', 'Upgrade', 'Uphold', 'Upset', 'Urge', 'Use',
    'Visit', 'Volunteer', 'Vote', 'Vow', 'Wait', 'Wake', 'Walk',
    'Water', 'Wave', 'Weaken', 'Wear', 'Weave', 'Weigh', 'Welcome', 'Whip',
    'Witness', 'Wonder', 'Work', 'Worry', 'Worship', 'Wound', 'Wrap',
];

/**
 * The list of adverbs.
 * @const
 */
const _ADVERB_ = [
    'About', 'Above', 'Abroad', 'Absently', 'Absolutely', 'Accidentally',
    'Additionally', 'Adequately', 'Adorably', 'After', 'Afterwards',
    'Almost', 'Alone', 'Along', 'Already', 'Also', 'Altogether', 'Always',
    'Anywhere', 'Apart', 'Appallingly', 'Apparently', 'Appropriately',
    'Astonishingly', 'Automatically', 'Away', 'Back', 'Backwards', 'Badly',
    'Besides', 'Best', 'Better', 'Between', 'Beyond', 'Blindly', 'Bravely',
    'Carefully', 'Casually', 'Cautiously', 'Certainly', 'Cheaply', 'Clearly',
    'Consequently', 'Considerably', 'Consistently', 'Constantly',
    'Currently', 'Cynically', 'Daily', 'Dangerously', 'Deeply',
    'Differently', 'Directly', 'Discreetly', 'Double', 'Down',
    'Eagerly', 'Early', 'Easily', 'East', 'Effectively', 'Efficiently',
    'Equally', 'Especially', 'Essentially', 'Euphoricly', 'Even', 'Evenly',
    'Expectantly', 'Explicitly', 'Extensively', 'Extra', 'Extremely',
    'Firmly', 'First', 'Firstly', 'Flatly', 'Forever', 'Formerly', 'Forth',
    'Frighteningly', 'FullTime', 'Fully', 'Fundamentally', 'Further',
    'Gradually', 'Greatly', 'Grimly', 'Guiltily', 'Half', 'Halfway',
    'Heroically', 'High', 'Highly', 'Home', 'Hopefully', 'Hourly', 'How',
    'Impartially', 'Impolitely', 'In', 'Increasingly', 'Incredibly',
    'Inside', 'Instantly', 'Instead', 'Intensely', 'Ironically',
    'Lately', 'Later', 'Lazily', 'Least', 'Left', 'Less', 'Lightly',
    'Loud', 'Loudly', 'Lovingly', 'Low', 'Loyally', 'Magnificently',
    'Mightily', 'Miserably', 'More', 'Moreover', 'Most', 'Mostly', 'Much',
    'Necessarily', 'Neither', 'Nervously', 'Never', 'Nevertheless', 'Newly',
    'NOT', 'Notably', 'Now', 'Nowadays', 'Nowhere',
    'Occasionally', 'Off', 'Often', 'Ok', 'On', 'Once', 'Online', 'Only',
    'Outside', 'Over', 'Overall', 'Overly', 'Overnight', 'Overseas',
    'Perfectly', 'Perhaps', 'Permanently', 'Personally', 'Playfully',
    'Predominantly', 'Presently', 'Presumably', 'Pretty', 'Previously',
    'Quietly', 'Quite', 'Randomly', 'Rapidly', 'Rarely', 'Rather',
    'Regardless', 'Regularly', 'Relatively', 'Remarkably', 'Remorsefully',
    'Round', 'Rudely', 'Ruthlessly', 'Sadly', 'Same', 'Scornfully',
    'Seriously', 'Severely', 'Shakily', 'Sharply', 'Shortly', 'Sideways',
    'Since', 'Sleepily', 'Slightly', 'Slowly', 'Slyly', 'Smoothly', 'So',
    'Somewhat', 'Somewhere', 'Soon', 'South', 'Specifically', 'Steadily',
    'Stunningly', 'Subsequently', 'Substantially', 'Successfully',
    'Temporarily', 'Tenderly', 'Terribly', 'Thankfully', 'That', 'Then',
    'Though', 'Thoughtfully', 'Through', 'Throughout', 'Thus', 'Tightly',
    'Twice', 'Typically', 'Ultimately', 'Under', 'Underground',
    'Usually', 'Utterly', 'Vanishingly', 'Very', 'Warmly',
    'Whatever', 'Whatsoever', 'When', 'Where', 'Whereby', 'Wholly', 'Why',
    'Worse', 'Worst', 'Wrong', 'Yearly', 'Yesterday', 'Yet'
];

/**
 * The list of adjectives.
 * @const
 */
const _ADJECTIVE_ = [
    'Able', 'Absent', 'Absolute', 'Abstract', 'Absurd', 'Academic',
    'Actual', 'Acute', 'Additional', 'Adequate', 'Adjacent',
    'Aesthetic', 'Affordable', 'Afraid', 'Aged',
    'Alone', 'Alternative', 'Amateur', 'Amazed', 'Amazing', 'Ambitious',
    'Anonymous', 'Anxious', 'Apparent', 'Appealing', 'Applicable',
    'Artistic', 'Ashamed', 'Asleep', 'Assistant', 'Associated',
    'Available', 'Average', 'Aware', 'Awful', 'Awkward', 'Back', 'Bad',
    'Beneficial', 'Bent', 'Best', 'Better', 'Big', 'Biological', 'Bitter',
    'Boring', 'Bottom', 'Bound', 'Brave', 'Brief', 'Bright', 'Brilliant',
    'Capital', 'Capitalist', 'Careful', 'Careless', 'Casual', 'Cautious',
    'Cheap', 'Cheerful', 'Chemical', 'Chief', 'Chronic', 'Civic', 'Civil',
    'Clinical', 'Close', 'Closed', 'Coastal', 'Cognitive', 'Cold',
    'Comic', 'Commercial', 'Common', 'Communist', 'Comparable',
    'Complex', 'Complicated', 'Comprehensive', 'Compulsory', 'Concerned',
    'Connected', 'Conscious', 'Consecutive', 'Conservative', 'Considerable',
    'Continuous', 'Contrary', 'Controversial', 'Convenient', 'Conventional',
    'Correct', 'Corresponding', 'Costly', 'Countless', 'Covered',
    'Crowded', 'Crucial', 'Crude', 'Cruel', 'Cult', 'Cultural', 'Curious',
    'Damaging', 'Dangerous', 'Dark', 'Dead', 'Dear', 'Decent',
    'Delicate', 'Delicious', 'Delighted', 'Democratic', 'Dense',
    'Destructive', 'Detailed', 'Determined', 'Different', 'Difficult',
    'Disappointing', 'Disastrous', 'Dishonest', 'Distant', 'Distinct',
    'Domestic', 'Dominant', 'Double', 'Downstairs', 'Downtown', 'Dramatic',
    'Dynamic', 'Eager', 'Early', 'East', 'Eastern', 'Easy', 'Ecological',
    'Efficient', 'Elaborate', 'Elderly', 'Electoral', 'Electric',
    'Embarrassed', 'Embarrassing', 'Emotional', 'Empirical', 'Empty',
    'Enormous', 'Entertaining', 'Enthusiastic', 'Entire', 'Environmental',
    'Even', 'Everyday', 'Evident', 'Evil', 'Evolutionary', 'Exact',
    'Exciting', 'Exclusive', 'Executive', 'Exotic', 'Expected', 'Expensive',
    'Extensive', 'External', 'Extra', 'Extraordinary', 'Extreme',
    'Famous', 'Fancy', 'Fantastic', 'Far', 'Fascinating', 'Fashionable',
    'Feminist', 'Few', 'Fierce', 'Final', 'Financial', 'Fine',
    'Folding', 'Folk', 'Following', 'Fond', 'Foreign', 'Formal', 'Former',
    'Fresh', 'Friendly', 'Frightened', 'Frightening', 'Front', 'Frozen',
    'Fundamental', 'Funny', 'Furious', 'Further', 'Future',
    'Giant', 'Glad', 'Global', 'Glorious', 'Gold', 'Golden', 'Good',
    'Grey', 'Gross', 'Guilty', 'Handy', 'Happy', 'Hard', 'Harmful', 'Harsh',
    'Hilarious', 'Historic', 'Historical', 'Hollow', 'Holy', 'Home',
    'Human', 'Humanitarian', 'Humble', 'Humorous', 'Hungry', 'Hurt',
    'Immediate', 'Immense', 'Imminent', 'Immune', 'Impatient', 'Important',
    'Inclined', 'Included', 'Incorrect', 'Incredible', 'Independent',
    'Inevitable', 'Infamous', 'Influential', 'Informal', 'Inherent',
    'Instant', 'Institutional', 'Instrumental', 'Insufficient', 'Intact',
    'Intense', 'Intensive', 'Interactive', 'Interested', 'Interesting',
    'Intimate', 'Intriguing', 'Invisible', 'Involved', 'Ironic',
    'Key', 'Kind', 'Large', 'LargeScale', 'Late', 'Later', 'Latest',
    'Legislative', 'Legitimate', 'Lengthy', 'Lesser',
    'Linear', 'Liquid', 'Literary', 'Little', 'Live', 'Lively', 'Living',
    'LongTerm', 'LongTime', 'Loose', 'Lost', 'Loud', 'Lovely', 'Low',
    'Magnificent', 'Main', 'Mainstream', 'Major', 'Mandatory',
    'Matching', 'Material', 'Mathematical', 'Mature', 'Maximum',
    'Memorable', 'Mental', 'Mere', 'Middle', 'Mild',
    'Missing', 'Mixed', 'Mobile', 'Moderate', 'Modern', 'Modest', 'Monthly',
    'Mutual', 'Mysterious', 'Narrative', 'Narrow',
    'Nearby', 'Neat', 'Necessary', 'Negative', 'Neighbouring', 'Nervous',
    'Normal', 'North', 'Northern', 'Notable', 'Notorious', 'Novel',
    'Offensive', 'Official', 'Ok', 'Old', 'OldFashioned', 'Ongoing',
    'Optical', 'Optimistic', 'Orange', 'Ordinary', 'Organic',
    'Outside', 'Outstanding', 'Overall', 'Overseas', 'Overwhelming', 'Own',
    'Partial', 'Particular', 'Passionate', 'Passive', 'Past', 'Patient',
    'Personal', 'Philosophical', 'Physical', 'Pink', 'Plain', 'Plastic',
    'Political', 'Poor', 'Pop', 'Popular', 'Positive', 'Possible',
    'Predictable', 'Preliminary', 'Premier', 'Prepared',
    'Primary', 'Prime', 'Principal', 'Prior', 'Private', 'Probable',
    'Progressive', 'Prominent', 'Promising', 'Pronounced', 'Proper',
    'Psychological', 'Public', 'Pure', 'Purple', 'Qualified', 'Quick',
    'Rational', 'Raw', 'Ready', 'Real', 'Realistic', 'Rear', 'Reasonable',
    'Relative', 'Relaxed', 'Relaxing', 'Relevant', 'Reliable', 'Relieved',
    'Repeated', 'Representative', 'Resident', 'Residential', 'Respective',
    'Ridiculous', 'Right', 'Risky', 'Rival', 'Robust', 'Romantic', 'Rough',
    'Safe', 'Same', 'Satisfied', 'Scary', 'Scattered',
    'Selective', 'Senior', 'Sensible', 'Sensitive', 'Separate', 'Serial',
    'Sheer', 'Shiny', 'Shocked', 'Shocking', 'Short', 'ShortTerm', 'Shut',
    'Simple', 'Sincere', 'Single', 'Situated', 'Ski', 'Skilled', 'Slight',
    'Soft', 'Solar', 'Sole', 'Solid', 'Solo', 'Sophisticated',
    'Specialized', 'Specific', 'Spectacular', 'Spicy', 'Spiritual',
    'Stark', 'State', 'Statistical', 'Steady', 'Steep', 'Sticky', 'Stiff',
    'Strict', 'Striking', 'Strong', 'Structural', 'Stunning',
    'Successful', 'Successive', 'Sudden', 'Sufficient', 'Suitable', 'Super',
    'Surprised', 'Surprising', 'Surrounding', 'Suspicious', 'Sustainable',
    'Talented', 'Tall', 'Technical', 'Technological',
    'Theoretical', 'Thick', 'Thin', 'Thirsty', 'Thorough',
    'Timely', 'Tiny', 'Tired', 'Top', 'Total', 'Tough', 'Toxic', 'Toy',
    'Tropical', 'True', 'Twin', 'Typical', 'Ultimate',
    'Underlying', 'Unemployed', 'Unexpected', 'Unfair', 'Unfortunate',
    'Unnecessary', 'Unpleasant', 'Unprecedented', 'Unusual', 'Upcoming',
    'Useless', 'Usual', 'Vague', 'Valid', 'Valuable', 'Variable', 'Varied',
    'Virtual', 'Visible', 'Visual', 'Vital', 'Vocal',
    'Weird', 'Welcome', 'Well', 'West', 'Western', 'Wet', 'White', 'Whole',
    'Working', 'Worldwide', 'Worried', 'Worse', 'Worst', 'Worth',
];

/*
const _PRONOUN_ = [
];
*/

/*
const _CONJUNCTION_ = [
    'And', 'Or', 'For', 'Above', 'Before', 'Against', 'Between'
];
*/

/**
 * Maps a string (category name) to the array of words from that category.
 * @const
 */
const CATEGORIES = {
    _ADJECTIVE_,
    _ADVERB_,
    _PLURALNOUN_,
    _VERB_

//    _CONJUNCTION_,
//    _NOUN_,
//    _PLACE_,
//    _PRONOUN_,
};

/**
 * The list of room name patterns.
 * @const
 */
const PATTERNS = [
    '_ADJECTIVE__PLURALNOUN__VERB__ADVERB_'

    // BeautifulFungiOrSpaghetti
    //    '_ADJECTIVE__PLURALNOUN__CONJUNCTION__PLURALNOUN_',

    // AmazinglyScaryToy
    //    '_ADVERB__ADJECTIVE__NOUN_',

    // NeitherTrashNorRifle
    //    'Neither_NOUN_Nor_NOUN_',
    //    'Either_NOUN_Or_NOUN_',

    // EitherCopulateOrInvestigate
    //    'Either_VERB_Or_VERB_',
    //    'Neither_VERB_Nor_VERB_',

    //    'The_ADJECTIVE__ADJECTIVE__NOUN_',
    //    'The_ADVERB__ADJECTIVE__NOUN_',
    //    'The_ADVERB__ADJECTIVE__NOUN_s',
    //    'The_ADVERB__ADJECTIVE__PLURALNOUN__VERB_',

    // WolvesComputeBadly
    //    '_PLURALNOUN__VERB__ADVERB_',

    // UniteFacilitateAndMerge
    //    '_VERB__VERB_And_VERB_',

    // NastyWitchesAtThePub
    //    '_ADJECTIVE__PLURALNOUN_AtThe_PLACE_',
];

/**
 * Generates a new room name.
 *
 * @returns {string} A newly-generated room name.
 */
function generateRoomWithoutSeparator() {
    // XXX Note that if more than one pattern is available, the choice of 'name'
    // won't have a uniform distribution amongst all patterns (names from
    // patterns with fewer options will have higher probability of being chosen
    // that names from patterns with more options).
    let name = PATTERNS[Math.floor(Math.random() * PATTERNS.length)];

    while (_hasTemplate(name)) {
        for (const template in CATEGORIES) { // eslint-disable-line guard-for-in
            const word = CATEGORIES[template][Math.floor(Math.random() * CATEGORIES[template].length)];

            name = name.replace(template, word);
        }
    }

    return name;
}

export default generateRoomWithoutSeparator;

/**
 * Determines whether a specific string contains at least one of the
 * templates/categories.
 *
 * @param {string} s - String containing categories.
 * @private
 * @returns {boolean} True if the specified string contains at least one of the
 * templates/categories; otherwise, false.
 */
function _hasTemplate(s) {
    for (const template in CATEGORIES) {
        if (s.indexOf(template) >= 0) {
            return true;
        }
    }

    return false;
}

/*
function findDuplicates(array) {
    var dups = array.reduce(function (acc, cur) {
        if (!acc[cur]) {
            acc[cur] = 1;
        } else {
            acc[cur] += 1;
        }

        return acc;
    }, {});
    for (const word in dups) {
        if (dups[word] > 1) {
            console.log(`Duplicate: ${word} ${dups[word]}`);
        }
    }
}
findDuplicates(_ADJECTIVE_);
findDuplicates(_PLURALNOUN_);
findDuplicates(_VERB_);
findDuplicates(_ADVERB_);
var combinations = _ADJECTIVE_.length * _PLURALNOUN_.length * _VERB_.length * _ADVERB_.length;
console.log(`${combinations} combinations (${Math.log2(combinations)} bits of entropy)`)
*/
