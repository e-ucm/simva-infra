CREATE TABLE IF NOT EXISTS "Games" (
	"game_id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"public" BOOLEAN NOT NULL,
	"actual" INTEGER,
	"name" VARCHAR NOT NULL,
	"description" VARCHAR NOT NULL,
	"owner_id" INTEGER NOT NULL,
	"type" VARCHAR NOT NULL CHECK(type IN ("WEB","DESKTOP")),
	"technology_id" INTEGER NOT NULL,
	"tracker_id" INTEGER,
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL,
	FOREIGN KEY ("owner_id") REFERENCES "Users"("user_id")
	ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY ("technology_id") REFERENCES "Technologies"("technology_id")
	ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY ("tracker_id") REFERENCES "Trackers"("tracker_id")
	ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS "Games_index_0"
ON "Games" ("game_id");
CREATE TABLE IF NOT EXISTS "Games_Versions" (
	"game_id" INTEGER NOT NULL,
	"version_id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"version" VARCHAR NOT NULL,
	"external_url" VARCHAR NOT NULL,
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL,
	FOREIGN KEY ("game_id") REFERENCES "Games"("game_id")
	ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "Users" (
	"user_id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"username" VARCHAR NOT NULL UNIQUE,
	"email" VARCHAR NOT NULL,
	"role" VARCHAR NOT NULL,
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS "Users_index_0"
ON "Users" ("user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "Users_index_1"
ON "Users" ("username");
CREATE TABLE IF NOT EXISTS "Games_Permissions" (
	"user_id" INTEGER NOT NULL,
	"game_id" INTEGER NOT NULL,
	"permission" VARCHAR NOT NULL CHECK(permission IN ("READ","WRITE")),
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL,
	PRIMARY KEY("user_id", "game_id"),
	FOREIGN KEY ("game_id") REFERENCES "Games"("game_id")
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY ("user_id") REFERENCES "Users"("user_id")
	ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "Games_Permissions_index_0"
ON "Games_Permissions" ("game_id", "user_id");
CREATE TABLE IF NOT EXISTS "Sessions" (
	"player_id" INTEGER NOT NULL,
	"game_id" INTEGER NOT NULL,
	"save_path" VARCHAR NOT NULL,
	PRIMARY KEY("player_id", "game_id"),
	FOREIGN KEY ("player_id") REFERENCES "Users"("user_id")
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY ("game_id") REFERENCES "Games"("game_id")
	ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "Teacher_Guides" (
	"game_id" INTEGER NOT NULL,
	"language_id" INTEGER NOT NULL,
	"url" VARCHAR NOT NULL,
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL,
	PRIMARY KEY("game_id", "language_id"),
	FOREIGN KEY ("game_id") REFERENCES "Games"("game_id")
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY ("language_id") REFERENCES "Languages"("language_id")
	ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "Languages" (
	"language_id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"language" VARCHAR NOT NULL,
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS "Technologies" (
	"technology_id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"technology" VARCHAR NOT NULL,
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS "Trackers" (
	"technology_id" INTEGER NOT NULL,
	"tracker_id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"tracker" VARCHAR NOT NULL,
	"createdAt" DATETIME NOT NULL,
	"updatedAt" DATETIME NOT NULL,
	FOREIGN KEY ("technology_id") REFERENCES "Technologies"("technology_id")
	ON UPDATE CASCADE ON DELETE CASCADE
);
