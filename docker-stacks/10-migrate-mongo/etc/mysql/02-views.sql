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
    al.mongo_id as allocator_mongo_id,
    al_type.allocator_type_name,
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
LEFT JOIN Allocators al ON sim.allocator_id = al.allocator_id
LEFT JOIN Allocators_types al_type ON al.allocator_type_id = al_type.allocator_type_id
LEFT JOIN v_activity_to_simlet upa ON upa.object_type = "SIMLET" AND sim.simlet_id = upa.object_id
LEFT JOIN v_session_to_simlet upses ON upses.object_type = "SIMLET" AND sim.simlet_id = upses.object_id
LEFT JOIN v_direct_permissions upsim ON upsim.object_type = "SIMLET" AND sim.simlet_id = upsim.object_id
GROUP BY sim.simlet_id;

CREATE OR REPLACE VIEW v_complete_simlets_sessions AS
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
LEFT JOIN v_activity_to_session upses ON upses.object_type = "SESSION" AND sim.session_id = upses.object_id
LEFT JOIN v_direct_permissions upa ON upa.object_type = "SESSION" AND sim.session_id = upa.object_id
GROUP BY sim.simlet_id, sim.session_id;

CREATE OR REPLACE VIEW v_complete_sessions_activities AS
SELECT
    ses.session_id,
    act.*,
    typ.activity_type_name,
    COUNT(DISTINCT upsim.user_id) as total_direct_supervisors,
    COUNT(DISTINCT upses.user_id) as total_direct_coordinators,
    COUNT(DISTINCT upa.user_id) as total_direct_owners
FROM Sessions_Activities ses
JOIN Activities act ON ses.activity_id = act.activity_id
JOIN Activities_types typ ON act.activity_type_id = typ.activity_type_id
LEFT JOIN v_simlet_to_activity upsim ON upsim.object_type = "ACTIVITY" AND ses.activity_id = upsim.object_id
LEFT JOIN v_session_to_activity upses ON upses.object_type = "ACTIVITY" AND ses.activity_id = upses.object_id
LEFT JOIN v_direct_permissions upa ON upa.object_type = "ACTIVITY" AND ses.activity_id = upa.object_id
GROUP BY ses.session_id, ses.activity_id;

CREATE OR REPLACE VIEW v_complete_groups AS
SELECT
    g.*,
    COUNT(DISTINCT p.participant_id) as total_participants,
    COUNT(DISTINCT o.owner_id) as total_owners
FROM ParticipantGroups g
LEFT JOIN ParticipantGroups_participants p ON g.group_id = p.group_id AND p.participant_id is not NULL
LEFT JOIN ParticipantGroups_participants o ON g.group_id = o.group_id AND o.owner_id is not NULL
GROUP BY g.group_id;

CREATE OR REPLACE VIEW v_complete_new_groups AS
SELECT
    * 
FROM v_complete_groups
WHERE version = 1;

CREATE OR REPLACE VIEW v_complete_previous_groups AS
SELECT
    * 
FROM v_complete_groups
WHERE version = 0;

CREATE OR REPLACE VIEW v_complete_group_participants AS
SELECT
    p.group_id,
    u.*
FROM ParticipantGroups_participants p
JOIN Users u ON u.user_id = p.participant_id
WHERE p.participant_id is not NULL;

CREATE OR REPLACE VIEW v_complete_group_owners AS
SELECT
    p.group_id,
    u.*
FROM ParticipantGroups_participants p
JOIN Users u ON u.user_id = p.owner_id
WHERE p.owner_id is not NULL;

CREATE OR REPLACE VIEW v_complete_default_random_allocation_participants AS
SELECT
    a.allocator_id,
    a.session_id,
    u.*
FROM Allocations a
JOIN Users u ON u.user_id = a.participant_id
WHERE a.participant_id is not NULL;

CREATE OR REPLACE VIEW v_complete_group_allocation_groups AS
SELECT
    a.allocator_id,
    a.session_id,
    g.*
FROM Allocations a
JOIN ParticipantGroups g ON g.group_id = a.group_id
WHERE a.group_id is not NULL;

CREATE OR REPLACE VIEW v_complete_group_allocation_participants AS
SELECT
    a.allocator_id,
    a.session_id,
    g.*
FROM Allocations a
JOIN v_complete_group_participants g ON g.group_id = a.group_id
WHERE a.group_id is not NULL;

CREATE OR REPLACE VIEW v_complete_simlets_users_permissions AS
SELECT 
    u.user_id,
    u.role_id,
    u.role_name,
    s.*
FROM v_complete_simlets s 
LEFT JOIN v_user_permissions u ON s.simlet_id = u.object_id AND u.object_type = "SIMLET";

CREATE OR REPLACE VIEW v_complete_sessions_users_permissions AS
SELECT 
    u.user_id,
    u.role_id,
    u.role_name,
    s.*
FROM v_complete_simlets_sessions s
LEFT JOIN v_user_permissions u ON s.session_id = u.object_id AND u.object_type = "SESSION";

CREATE OR REPLACE VIEW v_complete_activities_users_permissions AS
SELECT 
    u.user_id,
    u.role_id,
    u.role_name,
    a.*
FROM v_complete_sessions_activities a
LEFT JOIN v_user_permissions u ON a.activity_id = u.object_id AND u.object_type = "ACTIVITY"