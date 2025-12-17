import os
import json
import time
from datetime import datetime
import mysql.connector
from mysql.connector import Error

def convert_iso_to_mysql_datetime_format(date):
    if date is None :
        return
    return datetime.fromisoformat(date.replace("Z", "+00:00")).strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

# ---- Environment variables from docker-compose ----
MYSQL_HOST = os.getenv("MYSQL_HOST")
MYSQL_USER = os.getenv("MYSQL_USER")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")
MYSQL_DB = os.getenv("MYSQL_DB")
MONGO_BACKUP_FOLDER = os.getenv("MONGO_BACKUP_FOLDER")

# ---- Connect to MySQL ----
def wait_for_mysql(host, user, password, database, port=3306, retries=20, delay=3):
    for attempt in range(retries):
        try:
            print(f"Trying to connect to MySQL... attempt {attempt+1}/{retries}")
            conn = mysql.connector.connect(
                host=host,
                user=user,
                password=password,
                database=database,
                port=port
            )
            print("MySQL is available!")
            return conn
        except Error as e:
            print(f"MySQL not ready: {e}")
            time.sleep(delay)
    raise Exception("MySQL did not become available. Migration aborted.")

mysql_conn = wait_for_mysql(
    host=MYSQL_HOST,
    user=MYSQL_USER,
    password=MYSQL_PASSWORD,
    database=MYSQL_DB
)
cursor = mysql_conn.cursor()

print("Starting migration...")
print("------------")
print("Adding Users")
print("------------")

# Get Users from MySQL
cursor.execute("SELECT username FROM Users WHERE mongo_id IS NOT NULL")
mysql_username = cursor.fetchall()
existing_usernames = set(u[0] for u in mysql_username)  # extract string from tuple

# Get Users from Mongo Backup
users=[]
with open(MONGO_BACKUP_FOLDER + "/users.json", "r") as f:
    for line in f:
        if line.strip():  # skip empty lines
            obj = json.loads(line)
            users.append(obj)


# Adding User into Users table
user_sql = """
INSERT INTO Users (mongo_id, username, isToken, token, email, role)
VALUES (%s, %s, %s, %s, %s, %s)
"""

user_values = [
    (
        u["_id"]["$oid"],
        u["username"],
        u.get("isToken", "false") == "true",
        u.get("token",None),
        u["email"],
        u["role"]
    )
    for u in users
    if u["username"] not in existing_usernames
]
print(user_values)
cursor.executemany(user_sql, user_values)
mysql_conn.commit()

print("Inserted:")
print("  Users:", len(user_values))

#Dict to map Username to MySQL Id
cursor.execute("SELECT user_id, username FROM Users WHERE mongo_id IS NOT NULL")
mysql_users_ids = cursor.fetchall()
mongo_user_to_mysql_id = {username: user_id for user_id, username in mysql_users_ids}
print(mongo_user_to_mysql_id)

print("-------------")
print("Adding Groups")
print("-------------")

# Get existing Groups from MySQL
cursor.execute("SELECT mongo_id FROM ParticipantGroups WHERE mongo_id IS NOT NULL")
mysql_group_mongo_ids = cursor.fetchall()
existing_group_mongo_db = set(id[0] for id in mysql_group_mongo_ids)  # extract string from tuple

# Get Groups from Mongo Backup
groups=[]
with open(MONGO_BACKUP_FOLDER + "/groups.json", "r") as f:
    for line in f:
        if line.strip():  # skip empty lines
            obj = json.loads(line)
            groups.append(obj)

# Adding Group into Groups table
groups_sql = """
INSERT INTO ParticipantGroups (mongo_id, name, created, version)
VALUES (%s, %s, %s, %s)
"""

filtered_groups = [
    ( g )
    for g in groups
    if g["_id"]["$oid"] not in existing_group_mongo_db
]
groups_values = [
    (u["_id"]["$oid"], u["name"], convert_iso_to_mysql_datetime_format(u["created"]["$date"]), u["version"])
    for u in filtered_groups
]
print(groups_values)

cursor.executemany(groups_sql, groups_values)
mysql_conn.commit()

print("Inserted:")
print("  Groups:", len(groups_values))

#Dict to map Mongo Id to MySQL Id
cursor.execute("SELECT group_id, mongo_id FROM ParticipantGroups WHERE mongo_id IS NOT NULL")
mysql_groups_ids = cursor.fetchall()
mongo_group_to_mysql_id = {mongo_id: group_id for group_id, mongo_id in mysql_groups_ids}
print(mongo_group_to_mysql_id)

#adding groups participants
print("Adding Groups Participants")
groups_participant_sql = """
INSERT INTO ParticipantGroups_participants (group_id, participant_id)
VALUES (%s, %s)
"""

groups_participant_values=[]
for g in filtered_groups:
    mongo_id=g["_id"]["$oid"]
    for participant in g["participants"]:
        groups_participant_values.append((mongo_group_to_mysql_id[mongo_id],mongo_user_to_mysql_id[participant]))
print(groups_participant_values)

cursor.executemany(groups_participant_sql, groups_participant_values)
mysql_conn.commit()

print("Inserted:")
print("  ParticipantGroups_participants:", len(groups_participant_values))

#adding groups owners
print("Adding Groups owners")
groups_owners_sql = """
INSERT INTO ParticipantGroups_participants (group_id, owner_id)
VALUES (%s, %s)
"""
groups_owners_values=[]
for g in filtered_groups:
    mongo_id=g["_id"]["$oid"]
    for owner in g["owners"]:
        groups_owners_values.append((mongo_group_to_mysql_id[mongo_id],mongo_user_to_mysql_id[owner]))
print(groups_owners_values)

cursor.executemany(groups_owners_sql, groups_owners_values)
mysql_conn.commit()

print("Inserted:")
print("  ParticipantGroups_participants owners:", len(groups_owners_values))

print("-----------------")
print("Adding Activities")
print("-----------------")
# Get Activities from MySQL
cursor.execute("SELECT mongo_id FROM Activities WHERE mongo_id IS NOT NULL")
mysql_activities_mongo_ids = cursor.fetchall()
existing_activities_mongo_db = set(id[0] for id in mysql_activities_mongo_ids)  # extract string from tuple

# Get Activities from Mongo Backup
activities=[]
with open(MONGO_BACKUP_FOLDER + "/activities.json", "r") as f:
    for line in f:
        if line.strip():  # skip empty lines
            obj = json.loads(line)
            activities.append(obj)

# Adding Activities into Activities table
activities_sql = """
INSERT INTO Activities (mongo_id, name, activity_type, presignedUrl, generated_at, expire_on_seconds, version, trace_storage, description, isTemplate)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

filtered_activities = [
    ( a )
    for a in activities
    if a["_id"]["$oid"] not in existing_activities_mongo_db
]

activities_values = [
    (
        a["_id"]["$oid"], 
        a["name"], 
        a["type"],
        a.get("extra_data", {}).get("minio_trace", {}).get("presignedUrl"), 
        convert_iso_to_mysql_datetime_format(a.get("extra_data", {}).get("minio_trace", {}).get("generated_at")),
        a.get("extra_data", {}).get("minio_trace", {}).get("expire_on_sec"), 
        a.get("version", "0"), a.get("extra_data", {}).get("config", {}).get("trace_storage","false") == "true", 
        "", 
        False)
    for a in filtered_activities
]
print(activities_values)

cursor.executemany(activities_sql, activities_values)
mysql_conn.commit()

print("Inserted:")
print("  Activities:", len(activities_values))

##Dict to map Mongo Id to MySQL Id
cursor.execute("SELECT activity_id, mongo_id FROM Activities WHERE mongo_id IS NOT NULL")
mysql_activity_ids = cursor.fetchall()
mongo_activity_to_mysql_id = {mongo_id: activity_id for activity_id, mongo_id in mysql_activity_ids}
print(mongo_activity_to_mysql_id)

#adding Manual Activities
print("Adding Manual Activities")
manual_activities_sql = """
INSERT INTO Manual_Activities (activity_id, user_managed, ressource_type, ressource_url)
VALUES (%s, %s, %s, %s)
"""

manual_activities_values = [
    (
        mongo_activity_to_mysql_id[a["_id"]["$oid"]],
        a.get("extra_data", {}).get("user_managed", "false") == "true",
        "LOCAL" if a.get("extra_data", {}).get("uri", "") == "" else "URL",
        a.get("extra_data", {}).get("uri", "")
    )
    for a in filtered_activities
    if a.get("type") == "manual"
]

print(manual_activities_values)

cursor.executemany(manual_activities_sql, manual_activities_values)
mysql_conn.commit()

print("Inserted:")
print("  ManualActivities:", len(manual_activities_values))

#adding Limesurvey Activities
print("Adding Limesurvey Activities")
limesurvey_activities_sql = """
INSERT INTO Limesurvey_Activities (activity_id, survey_id, survey_owner, language, lrsset)
VALUES (%s, %s, %s, %s, %s)
"""

limesurvey_activities_values = [
    (
        mongo_activity_to_mysql_id[a["_id"]["$oid"]],
        a.get("extra_data", {}).get("surveyId", ""),
        list(mongo_user_to_mysql_id.values())[0] if a.get("extra_data", {}).get("survey_owner", "") == "" else mongo_user_to_mysql_id[a.get("extra_data", {}).get("survey_owner", "")],
        a.get("extra_data", {}).get("language", ""),
        a.get("extra_data", {}).get("lrsset", "false") == "true"
    )
    for a in filtered_activities
    if a.get("type") == "limesurvey"
]
print(limesurvey_activities_values)

cursor.executemany(limesurvey_activities_sql, limesurvey_activities_values)
mysql_conn.commit()

print("Inserted:")
print("  LimesurveyActivities:", len(limesurvey_activities_values))

#adding Gameplay Activities
print("Adding Gameplay Activities")
gameplay_activities_sql = """
INSERT INTO GamePlay_Activities (activity_id, backup, scorm_xapi_by_game, game_type, game_url)
VALUES (%s, %s, %s, %s, %s)
"""

gameplay_activities_values = [
    (
        mongo_activity_to_mysql_id[a["_id"]["$oid"]],
        a.get("extra_data", {}).get("config", {}).get("backup", "false") == "true",
        a.get("extra_data", {}).get("config", {}).get("scorm_xapi_by_game", "false") == "true",
        "LOCAL" if a.get("extra_data", {}).get("game_uri", "") == "" else "URL",
        a.get("extra_data", {}).get("game_uri", "")
    )
    for a in filtered_activities
    if a.get("type") == "gameplay"
]
print(gameplay_activities_values)

cursor.executemany(gameplay_activities_sql, gameplay_activities_values)
mysql_conn.commit()

print("Inserted:")
print("  GameplayActivities:", len(gameplay_activities_values))

#adding Activities completion
print("Adding Activities completion")
activities_completion_sql = """
INSERT INTO Activities_completion (activity_id, participant_id, initialized, progress, completed)
VALUES (%s, %s, %s, %s, %s)
"""

activities_completion_values=[]
for a in filtered_activities:
    activity_mongo_id=a["_id"]["$oid"]
    for participant_mongo_id in a.get("extra_data", {}).get("participants", {}):
        participant_value = a.get("extra_data", {}).get("participants", {})[participant_mongo_id]
        completed=participant_value.get("completion", "false") == "true"
        actual_progress=participant_value.get("progress", 0)
        progress=None if actual_progress == 0 and not completed else actual_progress
        initialized=False if progress is None else True
        activities_completion_values.append((mongo_activity_to_mysql_id[activity_mongo_id],mongo_user_to_mysql_id[participant_mongo_id], initialized, progress, completed))
print(activities_completion_values)

cursor.executemany(activities_completion_sql, activities_completion_values)
mysql_conn.commit()

print("Inserted:")
print("  Activities_completion:", len(activities_completion_values))

print("----------------")
print("Adding sessions ")
print("----------------")
# Get Sessions from MySQL
cursor.execute("SELECT mongo_id FROM Sessions WHERE mongo_id IS NOT NULL")
mysql_session_mongo_ids = cursor.fetchall()
existing_session_mongo_db = set(id[0] for id in mysql_session_mongo_ids)  # extract string from tuple

# Get Sessions from Mongo Backup
sessions=[]
with open(MONGO_BACKUP_FOLDER + "/tests.json", "r") as f:
    for line in f:
        if line.strip():  # skip empty lines
            obj = json.loads(line)
            sessions.append(obj)

# Adding Sessions into sesions table
sessions_sql = """
INSERT INTO Sessions (mongo_id, name, description, version, active)
VALUES (%s, %s, %s, %s, %s)
"""

filtered_sessions = [
    ( s )
    for s in sessions
    if s["_id"]["$oid"] not in existing_session_mongo_db
]
sessions_values = [
    (s["_id"]["$oid"], s["name"], "", 0, True)
    for s in filtered_sessions
]

cursor.executemany(sessions_sql, sessions_values)
mysql_conn.commit()

print("Inserted:")
print("  Sessions:", len(sessions_values))

#Dict to map Mongo Id to MySQL Id
cursor.execute("SELECT session_id, mongo_id FROM Sessions WHERE mongo_id IS NOT NULL")
mysql_session_ids = cursor.fetchall()
mongo_session_to_mysql_id = {mongo_id: session_id for session_id, mongo_id in mysql_session_ids}
print(mongo_session_to_mysql_id)

#adding Sessions Activities
print("Adding Sessions Activities mapping")
session_activities_sql = """
INSERT INTO Sessions_Activities (session_id, activity_id)
VALUES (%s, %s)
"""
session_activities_values=[]
for s in filtered_sessions:
    session_mongo_id=s["_id"]["$oid"]
    for activitiy_mongo_id in s.get("activities", []):
        session_activities_values.append((mongo_session_to_mysql_id[session_mongo_id], mongo_activity_to_mysql_id[activitiy_mongo_id]))
print(session_activities_values)

cursor.executemany(session_activities_sql, session_activities_values)
mysql_conn.commit()

print("Inserted:")
print("  Sessions_Activities:", len(session_activities_values))

print("----------------")
print("Adding Allocator ")
print("----------------")
# Get existing Allocators from MySQL
cursor.execute("SELECT mongo_id FROM Allocators WHERE mongo_id IS NOT NULL")
mysql_allocator_mongo_ids = cursor.fetchall()
existing_allocator_mongo_db = set(id[0] for id in mysql_allocator_mongo_ids)  # extract string from tuple

# Get allocators from Mongo Backup
allocators=[]
with open(MONGO_BACKUP_FOLDER + "/allocators.json", "r") as f:
    for line in f:
        if line.strip():  # skip empty lines
            obj = json.loads(line)
            allocators.append(obj)

#adding allocators into allocators table
allocators_sql = """
INSERT INTO Allocators (mongo_id, allocator_type)
VALUES (%s, %s)
"""

filtered_allocators = [
    ( a )
    for a in allocators
    if a["_id"]["$oid"] not in existing_allocator_mongo_db
]
allocators_values = [
    (a["_id"]["$oid"], a["type"])
    for a in filtered_allocators
]
print(allocators_values)
cursor.executemany(allocators_sql, allocators_values)
mysql_conn.commit()

print("Inserted:")
print("  Allocators:", len(filtered_allocators))

#Dict to map Mongo Id to MySQL Id
cursor.execute("SELECT allocator_id, mongo_id FROM Allocators WHERE mongo_id IS NOT NULL")
mysql_allocator_ids = cursor.fetchall()
mongo_allocator_to_mysql_id = {mongo_id: allocator_id for allocator_id, mongo_id in mysql_allocator_ids}
print(mongo_allocator_to_mysql_id)

#adding Default and groups Allocators
print("Adding Default and groups Allocators")
default_allocator_sql = """
INSERT INTO Allocations (allocator_id, session_id, participant_id)
VALUES (%s, %s, %s)
"""

group_allocator_sql = """
INSERT INTO Allocations (allocator_id, session_id, group_id)
VALUES (%s, %s, %s)
"""

default_allocator_values=[]
group_allocator_values=[]
for a in filtered_allocators:
    allocator_mongo_id=a["_id"]["$oid"]
    allocator_type=a["type"]
    for allocation_mongo_id in a.get("extra_data", {}).get("allocations", {}):
        session_mongo_id = a.get("extra_data", {}).get("allocations", {})[allocation_mongo_id]
        if allocator_type == "default":
            default_allocator_values.append((mongo_allocator_to_mysql_id[allocator_mongo_id],mongo_session_to_mysql_id[session_mongo_id], mongo_user_to_mysql_id[allocation_mongo_id]))
        elif allocator_type == "group":
            group_allocator_values.append((mongo_allocator_to_mysql_id[allocator_mongo_id], mongo_session_to_mysql_id[session_mongo_id], mongo_group_to_mysql_id[allocation_mongo_id]))
        else:
            continue
print(default_allocator_values)
print(group_allocator_values)
cursor.executemany(default_allocator_sql, default_allocator_values)
cursor.executemany(group_allocator_sql, group_allocator_values)
mysql_conn.commit()

print("Inserted:")
print("  Allocations - Default:", len(default_allocator_values))
print("  Allocations - Groups:", len(group_allocator_values))

print("---------------")
print("Adding SIMLETS ")
print("---------------")
# Get SIMLETs from MySQL
cursor.execute("SELECT mongo_id FROM SIMLETs WHERE mongo_id IS NOT NULL")
mysql_simlet_mongo_ids = cursor.fetchall()
existing_simlet_mongo_db = set(id[0] for id in mysql_simlet_mongo_ids)  # extract string from tuple

#Get simlets from Mongo Backup
simlets=[]
with open(MONGO_BACKUP_FOLDER + "/studies.json", "r") as f:
    for line in f:
        if line.strip():  # skip empty lines
            obj = json.loads(line)
            simlets.append(obj)

#adding simlets into simlets table
simlets_sql = """
INSERT INTO SIMLETs (mongo_id, name, created, description, sandbox_id, version, allocator_id)
VALUES (%s, %s, %s, %s, %s, %s, %s)
"""

filtered_simlets = [
    ( s )
    for s in simlets
    if s["_id"]["$oid"] not in existing_simlet_mongo_db
]
simlets_values = [
    (
        s["_id"]["$oid"], 
        s["name"], 
        convert_iso_to_mysql_datetime_format(s.get("created", {}).get("$date", None)),
        "", 
        mongo_session_to_mysql_id[s.get("sandbox")] if s.get("sandbox", None) is not None else None, 
        None,
        mongo_allocator_to_mysql_id[s["allocator"]])
    for s in filtered_simlets
]
print(simlets_values)

cursor.executemany(simlets_sql, simlets_values)
mysql_conn.commit()

print("Inserted:")
print("  SIMLETs:", len(simlets_values))

#Dict to map Mongo Id to MySQL Id
cursor.execute("SELECT simlet_id, mongo_id FROM SIMLETs WHERE mongo_id IS NOT NULL")
mysql_simlet_ids = cursor.fetchall()
mongo_simlet_to_mysql_id = {mongo_id: simlet_id for simlet_id, mongo_id in mysql_simlet_ids}
print(mongo_simlet_to_mysql_id)

#adding SIMLETs Sessions, groups, coordinators and shlinks
print("Adding SIMLETs Sessions, groups and coordinators mapping")
simlet_sesions_sql = """
INSERT INTO SIMLETs_sessions (simlet_id, session_id)
VALUES (%s, %s)
"""
simlet_group_sql = """
INSERT INTO SIMLETs_groups (simlet_id, group_id)
VALUES (%s, %s)
"""
simlet_shlinks_sql = """
INSERT INTO SIMLETs_shlinks (simlet_id, short_url, short_code, date_created, title, valid_date, expiration_date, domain )
VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
"""

simlet_sessions_values=[]
simlet_group_values=[]

simlet_shlinks_values=[]
for s in filtered_simlets:
    simlet_mongo_id=s["_id"]["$oid"]
    simlet_mysql_id=mongo_simlet_to_mysql_id[simlet_mongo_id]
    if s.get("shlink",None) is not None:
        simlet_shlinks_values.append((
            simlet_mysql_id, 
            s.get("shlink",{}).get("shortUrl"), 
            s.get("shlink",{}).get("shortCode"), 
            convert_iso_to_mysql_datetime_format(s.get("shlink",{}).get("dateCreated")),
            s.get("shlink",{}).get("title"),
            s.get("shlink",{}).get("meta").get("validSince"),
            s.get("shlink",{}).get("meta").get("validUntil"),
            s.get("shlink",{}).get("domain")
        ))
    for session_mongo_id in s.get("tests", []):
        simlet_sessions_values.append((simlet_mysql_id, mongo_session_to_mysql_id[session_mongo_id]))
    for group_mongo_id in s.get("groups", []):
        simlet_group_values.append((simlet_mysql_id, mongo_group_to_mysql_id[group_mongo_id]))
print(simlet_sessions_values)
print(simlet_shlinks_values)
print(simlet_group_values)
cursor.executemany(simlet_sesions_sql, simlet_sessions_values)
cursor.executemany(simlet_group_sql, simlet_group_values)
cursor.executemany(simlet_shlinks_sql, simlet_shlinks_values)
mysql_conn.commit()

print("Inserted:")
print("  SIMLETs_shlinks:", len(simlet_shlinks_values))
print("  SIMLETs_sessions:", len(simlet_sessions_values))
print("  SIMLETs_groups:", len(simlet_group_values))

#adding SIMLETs coordinators, test supervisors and activities owners
print("--------------------")
print("Adding OWNERS TABLES")
print("--------------------")
print("Adding SIMLET Coordinator and session supervisor mapping")
users_roles_sql = """
INSERT INTO Users_Roles (user_id, role_name, simlet_id)
VALUES (%s, %s, %s)
"""
users_roles_values=[]
users_ids=[]
for s in filtered_simlets:
    simlet_mongo_id=s["_id"]["$oid"]
    simlet_mysql_id=mongo_simlet_to_mysql_id[simlet_mongo_id]
    for coordinator_mongo_id in s.get("owners", []):
        owner_mysql=mongo_user_to_mysql_id[coordinator_mongo_id]
        users_roles_values.append((owner_mysql, "COORDINATOR", simlet_mysql_id))
        users_ids.append(coordinator_mongo_id)
print(users_roles_values)
cursor.executemany(users_roles_sql, users_roles_values)
mysql_conn.commit()
print("  Users_Roles:", len(users_roles_values))

#adding activities owners
#print("Adding activities owners mapping")
#activities_owners_sql = """
#INSERT INTO Users_Roles (user_id, activity_id)
#VALUES (%s, %s)
#"""
#activities_owners_values=[]
#for a in filtered_activities:
#    activity_mongo_id=a["_id"]["$oid"]
#    activity_mysql_id=mongo_activity_to_mysql_id[activity_mongo_id]
#    for owner_mongo_id in a.get("owners", []):
#        if(not users_ids in users_ids):
#            activities_owners_values.append((mongo_user_to_mysql_id[owner_mongo_id], activity_mysql_id))
#print(activities_owners_values)
#cursor.executemany(activities_owners_sql, activities_owners_values)
#mysql_conn.commit()
#
#print("Inserted:")
#print("  Users_Roles:", len(activities_owners_values))

print("Migration done!")
cursor.close()
mysql_conn.close()