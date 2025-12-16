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

CREATE OR REPLACE VIEW v_simlets_activities AS
SELECT 
	s.simlet_id,
	s.session_id,
	a.activity_id
FROM SIMLETs_sessions s
JOIN Sessions_Activities a ON a.session_id = s.session_id