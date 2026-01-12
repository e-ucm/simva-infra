DROP VIEW IF EXISTS v_owners_games;
CREATE VIEW v_owners_games AS
SELECT
    g.game_id,
    "OWNER" AS permission,
    g.owner_id as user_id,
    u.username,
    u.role,
    u.email
FROM
    Games g
LEFT JOIN Users u ON g.owner_id = u.user_id;

DROP VIEW IF EXISTS v_direct_permissions;
CREATE VIEW v_direct_permissions AS
SELECT
    gp.game_id,
    gp.permission,
    gp.user_id,
    u.username,
    u.role,
    u.email
FROM
    Games_permissions gp
LEFT JOIN Users u ON gp.user_id = u.user_id;

DROP VIEW IF EXISTS v_public_games;
CREATE VIEW v_public_games AS
SELECT
    g.game_id,
    g.owner_id
FROM
    Games g
WHERE g.public = true;

DROP VIEW IF EXISTS v_public_games_permissions;
CREATE VIEW v_public_games_permissions AS
SELECT
    g.game_id,
    "READ" AS permission,
    u.user_id,
    u.username,
    u.role,
    u.email
FROM
    v_public_games g
LEFT JOIN Users u ON g.owner_id != u.user_id
LEFT JOIN v_direct_permissions dp ON g.game_id = dp.game_id AND u.user_id = dp.user_id AND dp.user_id IS NULL;

DROP VIEW IF EXISTS v_effective_permissions;
CREATE VIEW v_effective_permissions AS
SELECT * FROM v_owners_games
UNION
SELECT * FROM v_direct_permissions
UNION
SELECT * FROM v_public_games_permissions;

DROP VIEW IF EXISTS v_complete_game;
CREATE VIEW v_complete_game AS
SELECT
    g.game_id,
    g.name,
    g.public,
    g.description,
    g.owner_id,
    g.type,
    g.createdAt,
    g.updatedAt,
    gv.version_id as actual_version_id,
    gv.external_url as actual_version_url,
    t.technology as technology_name,
    tr.tracker as tracker_name
FROM
    Games g
LEFT JOIN Game_Version gv ON g.game_id = gv.game_id AND g.actual = gv.version_id
LEFT JOIN Technology t ON g.technology_id = t.technology_id
LEFT JOIN Tracker tr ON g.tracker_id = tr.tracker_id;

DROP VIEW IF EXISTS v_complete_game_guide_url;
CREATE VIEW v_complete_game_guide_url AS
SELECT
    tg.game_id,
    tg.createdAt,
    tg.updatedAt,
    l.language,
    tg.url AS teacher_guide_url
FROM 
    Teacher_Guide tg
LEFT JOIN languages l ON tg.language_id = l.language_id;

DROP VIEW IF EXISTS v_complete_game_permissions;
CREATE VIEW v_complete_game_permissions AS
SELECT
    ep.user_id,
    ep.username,
    ep.role,
    ep.email,
    ep.permission,
    g.*
FROM
    v_complete_game g
LEFT JOIN v_effective_permissions ep ON g.game_id = ep.game_id;

DROP VIEW IF EXISTS v_game_guide_url_permissions;
CREATE VIEW v_game_guide_url_permissions AS
SELECT
    ep.user_id,
    ep.username,
    ep.role,
    ep.email,
    ep.permission,
    g.*
FROM
    v_complete_game_guide_url g
LEFT JOIN v_effective_permissions ep ON g.game_id = ep.game_id;