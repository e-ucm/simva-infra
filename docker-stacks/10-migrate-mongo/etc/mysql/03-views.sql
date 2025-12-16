CREATE OR REPLACE VIEW v_direct_permissions AS
SELECT
    ur.user_id,
    CASE
        WHEN ur.simlet_id   IS NOT NULL THEN 'SIMLET'
        WHEN ur.session_id IS NOT NULL THEN 'SESSION'
        WHEN ur.activity_id IS NOT NULL THEN 'ACTIVITY'
    END AS object_type,
    COALESCE(ur.simlet_id, ur.session_id, ur.activity_id) AS object_id,
	r.role_id AS role_id,
    r.role_name AS role_name
FROM Users_Roles ur
JOIN Roles r ON r.role_id = ur.role_id;

CREATE OR REPLACE VIEW v_simlet_to_session AS
SELECT
    ur.user_id,
    'SESSION' AS object_type,
    s.session_id AS object_id,
	r.role_id AS role_id,
    r.role_name AS role_name
FROM Users_Roles ur
JOIN Roles r ON r.role_id = ur.role_id
JOIN SIMLETs_sessions s ON s.simlet_id = ur.simlet_id
WHERE ur.simlet_id IS NOT NULL
  AND r.role_name = 'SUPERVISOR';

CREATE OR REPLACE VIEW v_session_to_simlet AS
SELECT
    ur.user_id,
    'SIMLET' AS object_type,
    s.simlet_id AS object_id,
	r.role_id AS role_id,
    r.role_name AS role_name
FROM Users_Roles ur
JOIN Roles r ON r.role_id = ur.role_id
JOIN SIMLETs_sessions s ON s.session_id = ur.session_id
WHERE ur.session_id IS NOT NULL
  AND r.role_name = 'COORDINATOR';

CREATE OR REPLACE VIEW v_simlet_to_activity AS
SELECT
    ur.user_id,
    'ACTIVITY' AS object_type,
    a.activity_id AS object_id,
	r.role_id AS role_id,
    r.role_name AS role_name
FROM Users_Roles ur
JOIN Roles r ON r.role_id = ur.role_id
JOIN SIMLETs_sessions s ON s.simlet_id = ur.simlet_id
JOIN Sessions_Activities a ON a.session_id = s.session_id
WHERE ur.simlet_id IS NOT NULL
  AND r.role_name = 'SUPERVISOR';

CREATE OR REPLACE VIEW v_activity_to_simlet AS
SELECT
    ur.user_id,
    'SIMLET' AS object_type,
    s.simlet_id AS object_id,
	r.role_id AS role_id,
    r.role_name AS role_name
FROM Users_Roles ur
JOIN Roles r ON r.role_id = ur.role_id
JOIN Sessions_Activities a ON a.activity_id = ur.activity_id
JOIN SIMLETs_sessions s ON s.session_id = a.session_id
WHERE ur.activity_id IS NOT NULL
  AND r.role_name = 'OWNER';

CREATE OR REPLACE VIEW v_session_to_activity AS
SELECT
    ur.user_id,
    'ACTIVITY' AS object_type,
    a.activity_id AS object_id,
	r.role_id AS role_id,
    r.role_name AS role_name
FROM Users_Roles ur
JOIN Roles r ON r.role_id = ur.role_id
JOIN Sessions_Activities a ON a.session_id = ur.session_id
WHERE ur.session_id IS NOT NULL
  AND r.role_name = 'COORDINATOR';


CREATE OR REPLACE VIEW v_activity_to_session AS
SELECT
    ur.user_id,
    'SESSION' AS object_type,
    a.session_id AS object_id,
	r.role_id AS role_id,
    r.role_name AS role_name
FROM Users_Roles ur
JOIN Roles r ON r.role_id = ur.role_id
JOIN Sessions_Activities a ON a.activity_id = ur.activity_id
WHERE ur.activity_id IS NOT NULL
  AND r.role_name = 'OWNER';


CREATE OR REPLACE VIEW v_user_permissions AS
SELECT * FROM v_direct_permissions
UNION ALL
SELECT * FROM v_simlet_to_session
UNION ALL
SELECT * FROM v_session_to_simlet
UNION ALL
SELECT * FROM v_simlet_to_activity
UNION ALL
SELECT * FROM v_activity_to_simlet
UNION ALL
SELECT * FROM v_session_to_activity
UNION ALL
SELECT * FROM v_activity_to_session
ORDER BY object_type, role_id;

CREATE OR REPLACE VIEW v_complete_simlets AS
SELECT
    sim.*,
    shlink.short_url,
    COUNT(DISTINCT g.group_id) as total_groups,
    COUNT(DISTINCT ses.session_id) as total_sessions,
    GROUP_CONCAT(tag.tag SEPARATOR ', ') as tags,
    COUNT(DISTINCT upsim.user_id) as total_direct_supervisors,
    COUNT(DISTINCT upses.user_id) as total_direct_coordinators,
    COUNT(DISTINCT upa.user_id) as total_direct_owners
FROM SIMLETs sim
LEFT JOIN SIMLETs_shlinks shlink ON sim.simlet_id = shlink.simlet_id
LEFT JOIN SIMLETs_groups g ON sim.simlet_id = g.simlet_id
LEFT JOIN SIMLETs_sessions ses ON sim.simlet_id = ses.simlet_id
LEFT JOIN SIMLETs_tags tag ON sim.simlet_id = tag.simlet_id
LEFT JOIN v_activity_to_simlet upa ON upa.object_type = "SIMLET" AND sim.simlet_id = upa.object_id
LEFT JOIN v_session_to_simlet upses ON upses.object_type = "SIMLET" AND sim.simlet_id = upses.object_id
LEFT JOIN v_direct_permissions upsim ON upsim.object_type = "SIMLET" AND sim.simlet_id = upsim.object_id
GROUP BY sim.simlet_id;

CREATE OR REPLACE VIEW v_simlets_sessions AS
SELECT
    sim.simlet_id,
    ses.*,
    COUNT(DISTINCT act.activity_id) as total_activities,
    GROUP_CONCAT(tag.tag SEPARATOR ', ') as tags,
    COUNT(DISTINCT upsim.user_id) as total_direct_supervisors,
    COUNT(DISTINCT upses.user_id) as total_direct_coordinators,
    COUNT(DISTINCT upa.user_id) as total_direct_owners
FROM SIMLETs_sessions sim
JOIN Sessions ses ON sim.session_id = ses.session_id
LEFT JOIN Sessions_Activities act ON sim.session_id = act.session_id
LEFT JOIN Sessions_tags tag ON sim.session_id = tag.session_id
LEFT JOIN v_simlet_to_session upsim ON upsim.object_type = "SESSION" AND sim.simlet_id = upsim.object_id
LEFT JOIN v_activity_to_session upa ON upa.object_type = "SESSION" AND sim.session_id = upa.object_id
LEFT JOIN v_direct_permissions upses ON upses.object_type = "SESSION" AND sim.session_id = upses.object_id
GROUP BY sim.simlet_id, sim.session_id;