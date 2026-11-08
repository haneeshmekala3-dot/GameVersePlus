CREATE DATABASE gameverse_plus;
USE gameverse_plus;

-- 👤 USER & ROLE MANAGEMENT
CREATE TABLE Role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name ENUM('Player', 'Admin', 'Moderator') UNIQUE
);

CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    join_date DATE DEFAULT (CURRENT_DATE),
    country VARCHAR(50),
    role_id INT DEFAULT 1,
    wallet_balance DECIMAL(10,2) DEFAULT 5900.00,
    total_playtime INT DEFAULT 0,
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
);

-- 🧩 PLATFORM & GENRE
CREATE TABLE Platform (
    platform_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    manufacturer VARCHAR(100),
    release_year YEAR
);

CREATE TABLE Genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- 🏭 DEVELOPER & PUBLISHER
CREATE TABLE Developer (
    developer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    headquarters VARCHAR(100),
    founded_year YEAR
);

CREATE TABLE Publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    headquarters VARCHAR(100),
    founded_year YEAR
);

-- 🎮 GAME
CREATE TABLE Game (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    developer_id INT,
    publisher_id INT,
    release_date DATE,
    price DECIMAL(7,2),
    description TEXT,
    FOREIGN KEY (developer_id) REFERENCES Developer(developer_id),
    FOREIGN KEY (publisher_id) REFERENCES Publisher(publisher_id)
);

-- 🎮 GAME-PLATFORM RELATION (M:N)
CREATE TABLE GamePlatform (
    game_id INT,
    platform_id INT,
    PRIMARY KEY (game_id, platform_id),
    FOREIGN KEY (game_id) REFERENCES Game(game_id),
    FOREIGN KEY (platform_id) REFERENCES Platform(platform_id)
);

-- 🎮 GAME-GENRE RELATION (M:N)
CREATE TABLE GameGenre (
    game_id INT,
    genre_id INT,
    PRIMARY KEY (game_id, genre_id),
    FOREIGN KEY (game_id) REFERENCES Game(game_id),
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

-- 🧩 DLC
CREATE TABLE DLC (
    dlc_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT,
    title VARCHAR(100),
    price DECIMAL(6,2),
    release_date DATE,
    FOREIGN KEY (game_id) REFERENCES Game(game_id)
);

-- 💾 USER GAME COLLECTION
CREATE TABLE GameCollection (
    collection_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    game_id INT,
    status ENUM('Playing', 'Completed', 'Wishlist', 'Dropped', 'On Hold') DEFAULT 'Wishlist',
    hours_played DECIMAL(6,1) DEFAULT 0,
    rating DECIMAL(2,1),
    added_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (game_id) REFERENCES Game(game_id)
);

-- 🏆 ACHIEVEMENTS
CREATE TABLE Achievement (
    achievement_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT,
    name VARCHAR(100),
    description TEXT,
    points INT DEFAULT 10,
    FOREIGN KEY (game_id) REFERENCES Game(game_id)
);

-- 🔓 USER ACHIEVEMENTS
CREATE TABLE UserAchievement (
    user_id INT,
    achievement_id INT,
    unlocked_date DATE,
    PRIMARY KEY (user_id, achievement_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (achievement_id) REFERENCES Achievement(achievement_id)
);

-- 🧾 REVIEWS & COMMENTS
CREATE TABLE Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    game_id INT,
    rating DECIMAL(2,1),
    review_text TEXT,
    review_date DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (game_id) REFERENCES Game(game_id)
);

CREATE TABLE Comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    review_id INT,
    user_id INT,
    comment_text TEXT,
    comment_date DATETIME DEFAULT NOW(),
    FOREIGN KEY (review_id) REFERENCES Review(review_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- 🤝 FRIENDSHIP
CREATE TABLE Friendship (
    user_id INT,
    friend_id INT,
    since DATE DEFAULT (CURRENT_DATE),
    status ENUM('Pending', 'Accepted', 'Blocked') DEFAULT 'Pending',
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (friend_id) REFERENCES User(user_id)
);

-- 🎮 MULTIPLAYER MATCHES
CREATE TABLE Matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT,
    match_date DATETIME DEFAULT NOW(),
    duration INT,
    winner_id INT,
    FOREIGN KEY (game_id) REFERENCES Game(game_id),
    FOREIGN KEY (winner_id) REFERENCES User(user_id)
);

CREATE TABLE MatchParticipant (
    match_id INT,
    user_id INT,
    score INT DEFAULT 0,
    PRIMARY KEY (match_id, user_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- 🛒 E-COMMERCE SYSTEM
CREATE TABLE Purchase (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    item_type ENUM('Game', 'DLC'),
    item_id INT,
    price DECIMAL(7,2),
    purchase_date DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE TABLE Cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    item_type ENUM('Game', 'DLC'),
    item_id INT,
    added_date DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- 🔔 NOTIFICATIONS
CREATE TABLE Notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    message TEXT,
    type ENUM('System', 'FriendRequest', 'Achievement', 'Purchase'),
    created_at DATETIME DEFAULT NOW(),
    is_read BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- 🏅 LEADERBOARD
CREATE TABLE Leaderboard (
    leaderboard_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    total_achievements INT DEFAULT 0,
    total_points INT DEFAULT 0,
    rank_position INT DEFAULT NULL,
    last_updated DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);


-- 👥 ROLES
INSERT INTO Role (role_name)
VALUES ('Player'), ('Admin'), ('Moderator');


-- 👤 USERS
INSERT INTO User (username, email, password_hash, country, role_id)
VALUES
('Haneesh', 'haneesh@example.com', SHA2('12345', 256), 'India', 1),
('Ravi', 'ravi@gmail.com', SHA2('67890', 256), 'India', 1),
('AdminUser', 'admin@gameverse.com', SHA2('admin123', 256), 'India', 2);


-- ⚙️ GAME-GENRE LINK
INSERT INTO GameGenre VALUES (1, 1), (2, 2), (3, 3);

-- ⚙️ GAME-PLATFORM LINK
INSERT INTO GamePlatform VALUES (1, 1), (2, 1), (3, 1);

-- 🏆 ACHIEVEMENTS
INSERT INTO Achievement (game_id, name, description, points)
VALUES
(1, 'Monster Slayer', 'Defeat 100 monsters', 50),
(2, 'Crime Lord', 'Complete 50 missions', 40),
(3, 'Sharp Shooter', 'Get 100 headshots', 30);

-- 💾 GAME COLLECTIONS
INSERT INTO GameCollection (user_id, game_id, status, hours_played, rating)
VALUES
(1, 1, 'Completed', 120, 9.5),
(1, 2, 'Playing', 45, 8.8),
(2, 3, 'Wishlist', 0, NULL);

-- 🏅 LEADERBOARD
INSERT INTO Leaderboard (user_id, total_achievements, total_points, rank_position)
VALUES
(1, 5, 200, 1),
(2, 2, 90, 2);

INSERT INTO Notification (user_id, message, type, is_read)
VALUES
(1, 'You unlocked the achievement "Monster Slayer"!', 'Achievement', FALSE),
(2, 'Your friend request to Haneesh was accepted.', 'FriendRequest', TRUE),
(1, 'Your purchase of "GTA V" is successful.', 'Purchase', TRUE),
(3, 'System maintenance scheduled at midnight.', 'System', FALSE);

INSERT INTO Review (user_id, game_id, rating, review_text)
VALUES
(1, 1, 9.5, 'Absolutely incredible world and story!'),
(2, 2, 9.0, 'Best open-world experience with tons of missions.'),
(1, 3, 8.5, 'Fun to play with friends, very competitive.');

INSERT INTO Comment (review_id, user_id, comment_text)
VALUES
(1, 2, 'Totally agree, Witcher 3 is epic!'),
(2, 1, 'Nice review, I love GTA too!'),
(3, 2, 'Valorant is life 🔥');

INSERT INTO Friendship (user_id, friend_id, status)
VALUES
(1, 2, 'Accepted'),
(2, 1, 'Accepted'),
(1, 3, 'Pending'),
(3, 1, 'Pending');


INSERT INTO MatchParticipant (match_id, user_id, score)
VALUES
(1, 1, 20),
(1, 2, 17),
(2, 1, 15),
(2, 2, 25);

INSERT INTO Matches (game_id, match_date, duration, winner_id)
VALUES 
(1, NOW(), 45, 1),
(2, NOW(), 60, 2);


SELECT user_id, username FROM User;



INSERT INTO Purchase (user_id, item_type, item_id, price)
VALUES
(1, 'Game', 2, 24.99),
(2, 'Game', 1, 29.99),
(3, 'DLC', 1, 9.99);
INSERT INTO Cart (user_id, item_type, item_id)
VALUES
(1, 'Game', 3),
(2, 'DLC', 1),
(3, 'Game', 1);

SELECT * FROM Notification;
SELECT * FROM Review;
SELECT * FROM Comment;
SELECT * FROM Friendship;
SELECT * FROM Matches;
SELECT * FROM MatchParticipant;
SELECT * FROM Purchase;
SELECT * FROM Cart;

SET SQL_SAFE_UPDATES = 0;
DELETE n1 FROM Notification n1
JOIN Notification n2 
  ON n1.user_id = n2.user_id
 AND n1.message = n2.message
 AND n1.created_at < n2.created_at;
 SET SQL_SAFE_UPDATES = 1;
 
INSERT INTO MatchParticipant (match_id, user_id, score)
VALUES
(3, 1, 30),
(3, 2, 22),
(4, 1, 19),
(4, 2, 26),
(5, 1, 28),
(5, 2, 24),
(6, 1, 33),
(6, 2, 29);

/*
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE UserAchievement;
TRUNCATE TABLE Comment;
TRUNCATE TABLE Review;
TRUNCATE TABLE Achievement;
TRUNCATE TABLE GamePlatform;
TRUNCATE TABLE GameGenre;
TRUNCATE TABLE GameCollection;
TRUNCATE TABLE Game; 
TRUNCATE TABLE DLC;
TRUNCATE TABLE Matches;
TRUNCATE TABLE MatchParticipant;
TRUNCATE TABLE Purchase;
TRUNCATE TABLE Cart;
TRUNCATE TABLE Notification;
TRUNCATE TABLE Leaderboard;
-- keep Role, User (if you don't want to remove users), Developer, Publisher, Genre, Platform
SET FOREIGN_KEY_CHECKS = 1;
*/

-- =========================
-- 50 GAMES 
-- =========================

INSERT INTO Game (title, developer_id, publisher_id, release_date, price, description) VALUES
('Valorant', 1, 1, '2020-06-02', 0.00, 'Competitive 5v5 tactical shooter'),
('The Witcher 3: Wild Hunt', 2, 2, '2015-05-19', 29.99, 'Open-world fantasy RPG'),
('GTA V', 3, 3, '2013-09-17', 24.99, 'Open world crime-adventure'),
('Red Dead Redemption 2', 3, 3, '2018-10-26', 39.99, 'Open-world western RPG'),
('Cyberpunk 2077', 2, 2, '2020-12-10', 59.99, 'Futuristic open-world RPG'),
('Assassin''s Creed Valhalla', 4, 4, '2020-11-10', 39.99, 'Viking action-adventure'),
('FIFA 23', 5, 5, '2022-09-27', 69.99, 'Football simulation'),
('Elden Ring', 6, 6, '2022-02-25', 59.99, 'Open-world action RPG'),
('God of War (2018)', 7, 7, '2018-04-20', 49.99, 'Story-driven action adventure'),
('God of War Ragnarök', 7, 7, '2022-11-09', 69.99, 'Sequel to God of War'),
('Forza Horizon 5', 32, 32, '2021-11-09', 59.99, 'Open world racing'),
('Need for Speed Heat', 5, 5, '2019-11-08', 39.99, 'Street racing adventure'),
('Minecraft', 8, 8, '2011-11-18', 26.95, 'Sandbox building survival'),
('Fortnite', 20, 20, '2017-07-21', 0.00, 'Battle royale shooter'),
('PUBG: Battlegrounds', 9, 9, '2017-12-20', 0.00, 'Battle royale survival'),
('Call of Duty: Modern Warfare II', 14, 10, '2022-10-28', 69.99, 'FPS, campaign + multiplayer'),
('Halo Infinite', 15, 8, '2021-12-08', 59.99, 'First-person shooter'),
('The Last of Us Part II', 11, 7, '2020-06-19', 39.99, 'Narrative action-adventure'),
('Uncharted 4: A Thief''s End', 11, 7, '2016-05-10', 19.99, 'Action-adventure'),
('Ghost of Tsushima', 35, 7, '2020-07-17', 39.99, 'Open-world samurai action'),
('Battlefield V', 38, 10, '2018-11-20', 29.99, 'WW2 first-person shooter'),
('Doom Eternal', 36, 10, '2020-03-20', 39.99, 'Fast-paced FPS'),
('Half-Life: Alyx', 21, 14, '2020-03-23', 59.99, 'VR first-person shooter'),
('Resident Evil Village', 48, 16, '2021-05-07', 49.99, 'Survival horror'),
('Sekiro: Shadows Die Twice', 6, 6, '2019-03-22', 59.99, 'Action-adventure with precision combat'),
('Dark Souls III', 6, 6, '2016-03-24', 49.99, 'Souls-like action RPG'),
('The Elder Scrolls V: Skyrim Special Edition', 12, 13, '2016-10-28', 39.99, 'Open-world RPG'),
('Mass Effect Legendary Edition', 17, 12, '2021-05-14', 59.99, 'Remastered RPG trilogy'),
('Horizon Zero Dawn', 19, 7, '2017-02-28', 19.99, 'Open-world action RPG'),
('Overwatch', 21, 21, '2016-05-24', 39.99, 'Team-based hero shooter'),
('Apex Legends', 23, 23, '2019-02-04', 0.00, 'Free-to-play hero shooter battle royale'),
('Dota 2', 21, 21, '2013-07-09', 0.00, 'MOBA multiplayer strategy'),
('Stardew Valley', 30, 19, '2016-02-26', 14.99, 'Farming and life simulation'), 
('The Last of Us (Remastered)', 11, 7, '2014-07-29', 29.99, 'Narrative action-adventure remaster'),
('Forza Motorsport 7', 32, 32, '2017-10-03', 59.99, 'Circuit racing sim'),
('Gran Turismo 7', 33, 33, '2022-03-04', 69.99, 'Realistic racing sim'),
('Fable Anniversary', 31, 20, '2014-09-03', 19.99, 'Action RPG classic remaster'),
('God of War (Ragnarok Collector''s)', 7, 7, '2022-11-09', 79.99, 'Collector edition'),
('Batman: Arkham City', 31, 20, '2011-10-18', 14.99, 'Action-adventure'),
('Minecraft Dungeons', 8, 8, '2020-05-26', 19.99, 'Dungeon crawler spin-off'),
('Sea of Thieves', 23, 8, '2018-03-20', 39.99, 'Open-world pirate multiplayer'),
('No Man''s Sky', 30, 30, '2016-08-09', 29.99, 'Procedural space exploration'),
('Gears 5', 8, 8, '2019-09-10', 39.99, 'Third-person shooter'),
('The Sims 4', 5, 5, '2014-09-02', 39.99, 'Life simulator'),
('Portal 2', 21, 14, '2011-04-19', 9.99, 'Puzzle-platformer'),
('Left 4 Dead 2', 21, 14, '2009-11-17', 19.99, 'Cooperative zombie shooter'),
('The Witcher 2: Assassins of Kings', 2, 2, '2011-05-17', 9.99, 'Follow-up RPG to Witcher'),
('Fallout 4', 12, 13, '2015-11-10', 29.99, 'Post-apocalyptic RPG'),
('Dragon Age: Inquisition', 17, 18, '2014-11-18', 19.99, 'Fantasy RPG'),
('Street Fighter V', 16, 16, '2016-02-16', 39.99, 'Fighting game'),
('Tekken 7', 41, 41, '2015-06-02', 39.99, 'Fighting game'),
('Shadow of the Tomb Raider', 4, 4, '2018-09-14', 39.99, 'Action-adventure')
;



INSERT INTO Developer (name, headquarters, founded_year) VALUES
('Riot Games', 'USA', 2006),
('CD Projekt Red', 'Poland', 2002),
('Rockstar Games', 'USA', 1998),
('Ubisoft', 'France', 1986),
('EA Sports', 'USA', 1991),
('FromSoftware', 'Japan', 1986),
('Santa Monica Studio', 'USA', 1999),
('Mojang', 'Sweden', 2009),
('PUBG Corp', 'Korea', 2009),
('Activision', 'USA', 1979),
('Naughty Dog', 'USA', 1984),
('Bethesda', 'USA', 1986),
('BioWare', 'Canada', 1995),
('Valve', 'USA', 1996),
('343 Industries', 'USA', 2007),
('Capcom', 'Japan', 1979),
('Respawn Entertainment', 'USA', 2010),
('Guerrilla Games', 'Netherlands', 2000),
('ConcernedApe', 'USA', 2012),
('Epic Games', 'USA', 1991),
('Bungie', 'USA', 1991),
('Turtle Rock Studios', 'USA', 2002),
('Rare', 'UK', 1985),
('Hello Games', 'UK', 2008),
('The Coalition', 'Canada', 2015),
('Maxis', 'USA', 1987),
('Psyonix', 'USA', 2000),
('Rocksteady Studios', 'UK', 2004),
('Crystal Dynamics', 'USA', 1992),
('Sledgehammer Games', 'USA', 2009),
('Turn 10 Studios', 'USA', 2001),
('Polyphony Digital', 'Japan', 1998),
('Playground Games', 'UK', 2010),
('Monolith', 'USA', 1994),
('Sucker Punch Productions', 'USA', 1997),
('MachineGames', 'Sweden', 2009),
('EA DICE', 'Sweden', 1992),
('id Software', 'USA', 1991),
('Creative Assembly', 'UK', 1987),
('Remedy Entertainment', 'Finland', 1995),
('Bandai Namco', 'Japan', 2005),
('Obsidian Entertainment', 'USA', 2003),
('Larian Studios', 'Belgium', 1996),
('Arkane Studios', 'France', 1999),
('Tango Gameworks', 'Japan', 2010),
('Infinity Ward', 'USA', 2002),
('Treyarch', 'USA', 1996),
('Supercell', 'Finland', 2010),
('Bluehole Studio', 'Korea', 2007);

INSERT INTO Publisher (name, headquarters, founded_year) VALUES
('Riot Games Publishing', 'USA', 2009),
('CD Projekt', 'Poland', 1994),
('Rockstar Games', 'USA', 1998),
('Ubisoft Entertainment', 'France', 1986),
('Electronic Arts (EA)', 'USA', 1982),
('Bandai Namco Entertainment', 'Japan', 2006),
('PlayStation Studios', 'USA', 2005),
('Xbox Game Studios', 'USA', 2000),
('PUBG Corporation', 'South Korea', 2009),
('Activision Publishing', 'USA', 1979),
('Sony Interactive Entertainment', 'USA', 1993),
('Bethesda Softworks', 'USA', 1986),
('2K Games', 'USA', 2005),
('Valve Corporation', 'USA', 1996),
('343 Industries Publishing', 'USA', 2007),
('Capcom Co.', 'Japan', 1979),
('Respawn Publishing', 'USA', 2010),
('Guerrilla Publishing', 'Netherlands', 2000),
('Chucklefish', 'UK', 2011),
('Epic Games Publishing', 'USA', 1991),
('Bungie Publishing', 'USA', 1991),
('Turtle Rock Publishing', 'USA', 2002),
('Rare Publishing', 'UK', 1985),
('Hello Games Publishing', 'UK', 2008),
('The Coalition Publishing', 'Canada', 2015),
('Maxis Publishing', 'USA', 1987),
('Psyonix Publishing', 'USA', 2000),
('Rocksteady Publishing', 'UK', 2004),
('Crystal Dynamics Publishing', 'USA', 1992),
('Sledgehammer Publishing', 'USA', 2009),
('Turn 10 Publishing', 'USA', 2001),
('Polyphony Digital Publishing', 'Japan', 1998),
('Playground Games Publishing', 'UK', 2010),
('Monolith Productions', 'USA', 1994),
('Sucker Punch Publishing', 'USA', 1997),
('MachineGames Publishing', 'Sweden', 2009),
('EA DICE Publishing', 'Sweden', 1992),
('id Software Publishing', 'USA', 1991),
('Creative Assembly Publishing', 'UK', 1987),
('Remedy Publishing', 'Finland', 1995),
('Bandai Namco Publishing', 'Japan', 2005),
('Obsidian Publishing', 'USA', 2003),
('Larian Publishing', 'Belgium', 1996),
('Arkane Publishing', 'France', 1999),
('Tango Gameworks Publishing', 'Japan', 2010),
('Infinity Ward Publishing', 'USA', 2002),
('Treyarch Publishing', 'USA', 1996),
('Supercell Publishing', 'Finland', 2010),
('Bluehole Publishing', 'South Korea', 2007);


INSERT IGNORE INTO Genre (name, description) VALUES
('RPG', 'Role-playing games'),
('Action', 'Action and adventure'),
('Shooter', 'First/Third-person shooters'),
('Sports', 'Sports simulation'),
('Racing', 'Racing and driving'),
('Strategy', 'Strategy/Tactics'),
('Simulation', 'Simulation / Sandbox'),
('Adventure', 'Narrative/Exploration'),
('Fighting', 'Fighting games'),
('Puzzle', 'Puzzle/Platformer'),
('MOBA', 'Multiplayer battle arena'),
('Horror', 'Survival horror');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='Shooter')
FROM Game
WHERE title IN ('Valorant','Fortnite','PUBG: Battlegrounds','Call of Duty: Modern Warfare II',
'Halo Infinite','Battlefield V','Doom Eternal','Resident Evil Village','Left 4 Dead 2','Gears 5');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='RPG')
FROM Game
WHERE title IN ('The Witcher 3: Wild Hunt','Red Dead Redemption 2','Cyberpunk 2077','Elden Ring',
'The Elder Scrolls V: Skyrim Special Edition','Mass Effect Legendary Edition',
'Horizon Zero Dawn','Fallout 4','Dragon Age: Inquisition','Sekiro: Shadows Die Twice');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='Action')
FROM Game
WHERE title IN ('God of War (2018)','God of War Ragnarök','Assassin''s Creed Valhalla','Uncharted 4: A Thief''s End',
'Ghost of Tsushima','The Last of Us Part II','The Last of Us (Remastered)',
'Batman: Arkham City','Shadow of the Tomb Raider','GTA V');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='Racing')
FROM Game
WHERE title IN ('Forza Horizon 5','Forza Motorsport 7','Gran Turismo 7','Need for Speed Heat');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='Simulation')
FROM Game
WHERE title IN ('Minecraft','Stardew Valley','The Sims 4','No Man''s Sky','Sea of Thieves');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='MOBA')
FROM Game
WHERE title IN ('Dota 2');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='Strategy')
FROM Game
WHERE title IN ('Overwatch','Apex Legends');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='Puzzle')
FROM Game
WHERE title IN ('Portal 2');

INSERT INTO GameGenre (game_id, genre_id)
SELECT game_id, (SELECT genre_id FROM Genre WHERE name='Fighting')
FROM Game
WHERE title IN ('Street Fighter V','Tekken 7');

INSERT INTO Achievement (game_id, name, description, points) VALUES
-- Game 1
(53, 'Sharp Shooter', 'Win a match with 30+ kills in Valorant.', 20),
(53, 'Clutch Master', 'Win a 1v3 clutch round.', 25),

-- Game 2
(54, 'Monster Slayer', 'Defeat a high-level contract monster.', 30),
(54, 'Gwent Champion', 'Win a Gwent tournament.', 20),

-- Game 3
(55, 'Five Stars', 'Achieve 5-star wanted level and escape.', 25),
(55, 'Street King', 'Win 10 street races.', 20),

-- Game 4
(56, 'Legend of the West', 'Complete the full epilogue.', 35),
(56, 'Dead-Eye Expert', 'Get 50 kills using Dead Eye.', 20),

-- Game 5
(57, 'Cyber Samurai', 'Complete all main missions.', 40),
(57, 'NetRunner Pro', 'Hack 25 enemies successfully.', 20),

-- Game 6
(58, 'Viking Conqueror', 'Capture 5 enemy fortresses.', 30),
(58, 'Silent Assassin', 'Perform 20 stealth kills.', 20),

-- Game 7
(59, 'Ultimate Champion', 'Win 5 consecutive FIFA matches.', 20),
(59, 'Golden Boot', 'Score 50 goals in career mode.', 25),

-- Game 8
(60, 'Elden Lord', 'Defeat the final boss.', 40),
(60, 'Unbreakable Spirit', 'Defeat 5 bosses without taking damage.', 35),

-- Game 9
(61, 'Ghost of Sparta', 'Unlock all main weapons.', 25),
(61, 'Rage Unleashed', 'Activate Spartan Rage 50 times.', 20),

-- Game 10
(62, 'Ragnarok Warrior', 'Complete all story quests.', 40),
(62, 'Berserker Slayer', 'Defeat 12 Berserker bosses.', 35),

-- Game 11
(63, 'Drift King', 'Earn 500,000 drift points.', 25),
(63, 'Speed Demon', 'Reach the max speed in any car.', 20),

-- Game 12
(64, 'Heat Master', 'Escape 10 high-level pursuits.', 25),
(64, 'Street Legend', 'Win 20 night races.', 20),

-- Game 13
(65, 'Master Builder', 'Build a mega structure.', 30),
(65, 'Survival Expert', 'Survive 50 nights.', 25),

-- Game 14
(66, 'Victory Royale', 'Win a solo match.', 20),
(66, 'Pro Builder', 'Build 500 structures.', 25),

-- Game 15
(67, 'Chicken Dinner', 'Win a match with 10+ kills.', 25),
(67, 'Sharpshooter Elite', 'Get 50 sniper headshots.', 20),

-- Game 16
(68, 'Tactical Expert', 'Complete all campaign missions.', 35),
(68, 'Killstreak Master', 'Achieve a 20-kill streak.', 25),

-- Game 17
(69, 'Spartan Warrior', 'Win 50 multiplayer matches.', 25),
(69, 'Master Chief', 'Complete the story on Heroic difficulty.', 30),

-- Game 18
(70, 'Survivor', 'Complete story mode.', 30),
(70, 'Stealth Specialist', 'Finish 5 missions without alerts.', 20),

-- Game 19
(71, 'Treasure Hunter', 'Collect all hidden treasures.', 30),
(71, 'Sharpshooter', 'Get 100 headshots.', 20),

-- Game 20
(72, 'Ghost Samurai', 'Defeat a boss in stealth.', 25),
(72, 'Island Liberator', 'Clear all Mongol camps.', 30),

-- Game 21
(73, 'War Hero', 'Complete 50 matches.', 20),
(73, 'Squad Leader', 'Revive 100 teammates.', 20),

-- Game 22
(74, 'Hell Walker', 'Complete campaign on Ultra-Violence.', 35),
(74, 'Demon Slayer', 'Defeat 500 demons.', 25),

-- Game 23
(75, 'VR Master', 'Complete campaign in VR.', 30),
(75, 'Headcrab Eliminator', 'Kill 100 headcrabs.', 20),

-- Game 24
(76, 'Night Hunter', 'Defeat Lady Dimitrescu.', 25),
(76, 'Survivalist', 'Complete game on Hardcore mode.', 35),

-- Game 25
(77, 'Perfect Parry', 'Parry 500 attacks.', 25),
(77, 'Shinobi Master', 'Finish game without dying.', 40),

-- Game 26
(78, 'Ashen One', 'Defeat Soul of Cinder.', 30),
(78, 'Champion of Ash', 'Complete all boss fights.', 35),

-- Game 27
(79, 'Dragonborn', 'Slay a legendary dragon.', 25),
(79, 'Master Mage', 'Learn 20 spells.', 20),

-- Game 28
(80, 'Galaxy Savior', 'Complete trilogy storyline.', 40),
(80, 'Paragon Elite', 'Max out Paragon or Renegade.', 25),

-- Game 29
(81, 'Huntress Master', 'Defeat all robotic beasts.', 30),
(81, 'Silent Archer', 'Get 50 bow stealth kills.', 20),

-- Game 30
(82, 'Grandmaster', 'Reach level 100.', 25),
(82, 'Team MVP', 'Get 50 play-of-the-games.', 20),

-- Game 31
(83, 'Apex Champion', 'Win 10 ranked matches.', 20),
(83, 'Legendary Hunter', 'Unlock 20 legends.', 25),

-- Game 32
(84, 'Ancient Destroyer', 'Defeat Roshan 10 times.', 20),
(84, 'Strategist', 'Win 50 matches.', 20),

-- Game 33
(85, 'Farmer King', 'Earn 1 million gold.', 30),
(85, 'Community Hero', 'Complete 25 village quests.', 20),

-- Game 34
(86, 'Remastered Hero', 'Finish the remastered campaign.', 25),
(86, 'Survivor Legend', 'Complete on hard difficulty.', 30),

-- Game 35
(87, 'Track Champion', 'Win 20 championship races.', 20),
(87, 'Car Collector', 'Own 50 cars.', 25),

-- Game 36
(88, 'GT Master', 'Finish career mode.', 35),
(88, 'Pro Racer', 'Achieve 10 pole positions.', 20),

-- Game 37
(89, 'Fable Hero', 'Complete all moral quests.', 25),
(89, 'Pure/Corrupt Master', 'Reach max morality.', 20),

-- Game 38
(90, 'God Killer', 'Unlock special edition armor.', 30),
(90, 'Collector Supreme', 'Find all rare items.', 25),

-- Game 39
(91, 'Arkham Knight', 'Defeat 100 thugs.', 20),
(91, 'Shadow Stalker', 'Perform 25 silent takedowns.', 20),

-- Game 40
(92, 'Dungeon Savior', 'Clear 50 dungeons.', 25),
(92, 'Ultimate Warrior', 'Defeat the Arch-Illager.', 20),

-- Game 41
(93, 'Pirate Legend', 'Reach Pirate Legend rank.', 30),
(93, 'Treasure Master', 'Bury 20 treasure chests.', 20),

-- Game 42
(94, 'Galactic Traveler', 'Visit 50 star systems.', 25),
(94, 'World Builder', 'Build 10 bases.', 20),

-- Game 43
(95, 'Gear Master', 'Complete campaign.', 30),
(95, 'Elite Soldier', 'Kill 1000 enemies.', 25),

-- Game 44
(96, 'Sim Architect', 'Build a perfect household.', 20),
(96, 'Life Master', 'Complete all aspirations.', 25),

-- Game 45
(97, 'Puzzle Genius', 'Solve all test chambers.', 25),
(97, 'Portal Master', 'Beat game without dying.', 30),

-- Game 46
(98, 'Zombie Slayer', 'Kill 1000 zombies.', 25),
(98, 'Survival Expert', 'Survive 10 rounds without damage.', 30),

-- Game 47
(99, 'Kingslayer', 'Defeat Letho.', 25),
(99, 'Master Alchemist', 'Craft 50 potions.', 20),

-- Game 48
(100, 'Vault Survivor', 'Complete all factions missions.', 30),
(100, 'Wasteland Warrior', 'Defeat 200 enemies.', 20),

-- Game 49
(101, 'Dragon Knight', 'Defeat a High Dragon.', 30),
(101, 'Battle Strategist', 'Win 10 tactical battles.', 25),

-- Game 50
(102, 'World Warrior', 'Win 20 online battles.', 25),
(102, 'Iron Fist', 'Perform 500 combos.', 20);



SELECT * FROM game;





-- Create 50 unique review texts
CREATE TEMPORARY TABLE TempReviews (
    text_id INT AUTO_INCREMENT PRIMARY KEY,
    review_text VARCHAR(300)
);

INSERT INTO TempReviews (review_text) VALUES
('Absolutely loved the gameplay, super immersive.'),
('Storyline was emotional and beautifully crafted.'),
('Graphics are stunning even on medium settings.'),
('Multiplayer mode is fun but needs better matchmaking.'),
('One of the best action titles released in years.'),
('The open world design is breathtaking.'),
('Combat system feels fresh and very responsive.'),
('Great soundtrack! Really sets the mood.'),
('Boss fights are challenging and enjoyable.'),
('AI could be better, but overall great experience.'),
('Very addictive gameplay loop. Kept me hooked.'),
('Excellent character development and writing.'),
('Side missions are surprisingly deep.'),
('Physics engine feels realistic and polished.'),
('Some bugs, but nothing game-breaking.'),
('Highly optimized—runs smoothly even on old hardware.'),
('Crafting system is clever and enjoyable.'),
('Animations are fluid and natural.'),
('A must-play title for RPG fans.'),
('Tons of content and replay value.'),
('One of the most visually pleasing games ever.'),
('The storyline kept me engaged the whole time.'),
('Exploration is rewarding and satisfying.'),
('Fast-paced combat that feels amazing.'),
('Level design is brilliant and creative.'),
('Voice acting is top-tier quality.'),
('Pretty good but pacing feels slow sometimes.'),
('Co-op mode is super fun with friends.'),
('Lots of customization options available.'),
('Very polished game overall.'),
('Atmosphere is dark and deeply immersive.'),
('Perfect balance of story and action.'),
('Open world feels alive and interactive.'),
('Great for casual players and hardcore fans alike.'),
('Enemy variety is impressive.'),
('Beautiful art direction and lighting.'),
('A truly unforgettable experience.'),
('Cutscenes are cinematic and breathtaking.'),
('Sound design is phenomenal.'),
('Very rewarding progression system.'),
('Kept me playing for hours without boredom.'),
('Some missions feel repetitive, but still fun.'),
('One of my favorite games now.'),
('Absolutely worth the price.'),
('The world-building is exceptional.'),
('Super rewarding for completionists.'),
('The final boss fight was epic.'),
('Perfect mix of action and exploration.'),
('Replay value is insane.'),
('Highly recommended to everyone.');

-- Insert reviews with rotating users (1,2,3)
SET @i = 0;
INSERT INTO Review (user_id, game_id, rating, review_text)
SELECT 
    CASE 
        WHEN (@i := @i + 1) % 3 = 1 THEN 1
        WHEN (@i) % 3 = 2 THEN 2
        ELSE 3
    END AS user_id,
    g.game_id,
    ROUND((RAND()*4)+6,1) AS rating,      -- Random rating 6.0 to 10.0
    tr.review_text
FROM Game g
JOIN TempReviews tr ON tr.text_id = g.game_id
LIMIT 50;   -- Ensures exactly 50 reviews


CREATE TEMPORARY TABLE TempComments1 (
    text_id INT AUTO_INCREMENT PRIMARY KEY,
    comment_text VARCHAR(300)
);

INSERT INTO TempComments1 (comment_text) VALUES
('Totally agree with your review! Well said.'),
('I had a similar experience while playing.'),
('You explained it better than most critics!'),
('This review helped me decide to buy the game.'),
('Great insight, thanks for sharing!'),
('Interesting perspective, I respect it.'),
('Agree on the combat mechanics—it’s amazing.'),
('Yes! The graphics blew my mind too.'),
('Thanks for highlighting the positives.'),
('I love how you described the boss fights.'),
('Spot on! Especially the part about exploration.'),
('Glad to see someone else appreciates the story.'),
('Exactly! The sound design is underrated.'),
('You captured the game’s vibe perfectly.'),
('Nice review, very honest and detailed.'),
('This made me want to replay the game.'),
('I felt the same about the world-building.'),
('Great write-up! Short and clear.'),
('You convinced me to give this game a try.'),
('I agree, the pacing could be better.'),
('Thank you for this balanced review!'),
('You noticed details I completely missed.'),
('Very true about the voice acting!'),
('Good point about the combat flow.'),
('Loved reading this!'),
('This review sums up my thoughts perfectly.'),
('This game deserves more love.'),
('Your review was on point!'),
('Completely agree with you.'),
('You described the atmosphere so well.'),
('Exactly my thoughts!'),
('Thanks for your honest feedback.'),
('This is one of the best reviews here.'),
('That’s a fair rating.'),
('Totally valid points.'),
('Nicely written!'),
('I appreciate your viewpoint.'),
('You’re absolutely right.'),
('This review helped a lot!'),
('Couldn’t agree more!'),
('Nice summary.'),
('Solid points made here.'),
('Very reasonable review.'),
('You’re spot on!'),
('I agree with everything here.'),
('Review was very helpful.'),
('I like your writing style.'),
('Great review overall!');

CREATE TEMPORARY TABLE TempComments2 (
    text_id INT AUTO_INCREMENT PRIMARY KEY,
    comment_text VARCHAR(300)
);

INSERT INTO TempComments2 (comment_text) VALUES
('I had the opposite experience but I respect your view.'),
('Interesting take, I didn’t feel the same.'),
('Some parts were better for me, but good review.'),
('I think the game was overrated personally.'),
('Combat felt clunky to me, but nice analysis.'),
('I found the difficulty spikes annoying.'),
('Wish the devs fixed the bugs sooner.'),
('Story was boring for me, but glad you liked it.'),
('I disagree about the graphics, felt outdated.'),
('I thought the pacing was too slow.'),
('Not my favorite game, but good review.'),
('Side missions felt repetitive to me.'),
('The world felt empty IMO.'),
('Boss fights were too easy for me.'),
('I expected more from the ending.'),
('The game felt too short for the price.'),
('I struggled with the controls, honestly.'),
('The AI felt dumb at times.'),
('Characters felt flat to me.'),
('I liked the gameplay but hated the UI.'),
('I think the soundtrack was average.'),
('Didn’t enjoy it as much as you did.'),
('I found the combat too repetitive.'),
('Wish the devs added more content.'),
('Some mechanics were poorly explained.'),
('Game didn’t run well on my PC.'),
('I got bored after a few hours.'),
('Ending felt rushed IMO.'),
('Could’ve been much better.'),
('Very mixed feelings about this game.'),
('I think the hype was exaggerated.'),
('Didn’t connect with the characters.'),
('Movement felt stiff sometimes.'),
('Too many bugs at launch.'),
('Crafting system annoyed me.'),
('Enemy variety was lacking.'),
('Wish the map was bigger.'),
('I found the story predictable.'),
('Not my type of game, but okay.'),
('Good ideas, bad execution.'),
('Graphics were inconsistent.'),
('Too grindy for my taste.'),
('Dialogue felt unnatural.'),
('Multiplayer was disappointing.'),
('Couldn’t finish the game.'),
('Gameplay loop got boring.'),
('Decent review though!');

-- Insert comment #1 per review
INSERT INTO Comment (review_id, user_id, comment_text)
SELECT 
    r.review_id,
    CASE 
        WHEN r.user_id = 1 THEN 2
        WHEN r.user_id = 2 THEN 3
        ELSE 1
    END,
    tc1.comment_text
FROM Review r
JOIN TempComments1 tc1 ON tc1.text_id = r.review_id;

-- Insert comment #2 per review
INSERT INTO Comment (review_id, user_id, comment_text)
SELECT 
    r.review_id,
    CASE 
        WHEN r.user_id = 1 THEN 3
        WHEN r.user_id = 2 THEN 1
        ELSE 2
    END,
    tc2.comment_text
FROM Review r
JOIN TempComments2 tc2 ON tc2.text_id = r.review_id;



ALTER TABLE User
ADD COLUMN IF NOT EXISTS wallet_balance DECIMAL(10,2) DEFAULT 5900.00;   -- give every user ₹500 starting balance


ALTER TABLE Cart
ADD UNIQUE (user_id, item_type, item_id);

ALTER TABLE GameCollection
ADD UNIQUE (user_id, game_id);

DELIMITER $$

CREATE TRIGGER before_purchase_check_balance
BEFORE INSERT ON Purchase
FOR EACH ROW
BEGIN
    DECLARE bal DECIMAL(10,2);

    SELECT wallet_balance INTO bal 
    FROM User 
    WHERE user_id = NEW.user_id;

    IF bal < NEW.price THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Not enough wallet balance.';
    END IF;

END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_purchase_deduct_balance
AFTER INSERT ON Purchase
FOR EACH ROW
BEGIN
    UPDATE User
    SET wallet_balance = wallet_balance - NEW.price
    WHERE user_id = NEW.user_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_purchase_add_to_collection
AFTER INSERT ON Purchase
FOR EACH ROW
BEGIN
    IF NEW.item_type = 'Game' THEN
        INSERT INTO GameCollection (user_id, game_id, status, hours_played, rating)
        VALUES (NEW.user_id, NEW.item_id, 'Wishlist', 0, NULL)
        ON DUPLICATE KEY UPDATE status = 'Wishlist';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_purchase_remove_cart_item
AFTER INSERT ON Purchase
FOR EACH ROW
BEGIN
    DELETE FROM Cart
    WHERE user_id = NEW.user_id
    AND item_type = NEW.item_type
    AND item_id = NEW.item_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_purchase_send_notification
AFTER INSERT ON Purchase
FOR EACH ROW
BEGIN
    INSERT INTO Notification (user_id, message, type)
    VALUES (
        NEW.user_id,
        CONCAT('Purchase successful for item ', NEW.item_type, ' ID ', NEW.item_id),
        'Purchase'
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_purchase_update_leaderboard
AFTER INSERT ON Purchase
FOR EACH ROW
BEGIN
    IF NEW.item_type = 'Game' THEN
        
        INSERT INTO Leaderboard (user_id, total_achievements, total_points)
        VALUES (NEW.user_id, 0, 2)
        ON DUPLICATE KEY UPDATE total_points = total_points + 2;

    END IF;
END $$

DELIMITER ;

UPDATE User SET wallet_balance = 5900;

SELECT game_id, title FROM Game WHERE game_id IN (2,3);


SELECT g.title, COUNT(r.review_id) AS ReviewCount
FROM Review r
JOIN Game g ON r.game_id = g.game_id
GROUP BY g.title
ORDER BY ReviewCount DESC;


SELECT u.username, SUM(p.price) AS TotalSpent
FROM Purchase p
JOIN User u ON p.user_id = u.user_id
WHERE p.user_id = 2;

SELECT u.username, u.email, r.role_name
FROM User u
JOIN Role r ON u.role_id = r.role_id;

SELECT COUNT(*) AS AlreadyOwned
FROM GameCollection
WHERE user_id = 2 AND game_id = 15;

SELECT game_id, title, price, release_date 
FROM Game;

SELECT g.title, ge.name AS Genre
FROM Game g
JOIN GameGenre gg ON g.game_id = gg.game_id
JOIN Genre ge ON gg.genre_id = ge.genre_id
WHERE ge.name = 'Action';

SELECT title, price
FROM Game
ORDER BY price DESC
LIMIT 5;

SELECT COUNT(*) AS TotalUsers 
FROM User;

SELECT AVG(price) AS AveragePrice
FROM Game;

SELECT ge.name AS Genre, COUNT(*) AS GameCount
FROM GameGenre gg
JOIN Genre ge ON gg.genre_id = ge.genre_id
GROUP BY ge.name;

SELECT ge.name AS Genre, COUNT(*) AS GameCount
FROM GameGenre gg
JOIN Genre ge ON gg.genre_id = ge.genre_id
GROUP BY ge.name
HAVING COUNT(*) > 5;





SELECT g.title, d.name AS developer, p.name AS publisher
FROM Game g
JOIN Developer d ON g.developer_id = d.developer_id
JOIN Publisher p ON g.publisher_id = p.publisher_id;


SHOW TABLES;

SELECT *
FROM GameCollection
WHERE user_id = 6;

SELECT * FROM User;



