CREATE TABLE IF NOT EXISTS "Games" (
	"game_id" INTEGER NOT NULL UNIQUE,
	"public" BOOLEAN NOT NULL,
	"actual" INTEGER NOT NULL,
	"name" VARCHAR NOT NULL,
	"description" VARCHAR NOT NULL,
	"owner_id" INTEGER NOT NULL,
	"type" VARCHAR NOT NULL CHECK(type IN ("WEB","DESKTOP")),
	"technology_id" INTEGER NOT NULL,
	"tracker_id" INTEGER NOT NULL,
	"createdAt" DATE NOT NULL,
	"updatedAt" DATE NOT NULL,
	PRIMARY KEY("game_id"),
	FOREIGN KEY ("actual") REFERENCES "Game_Versions"("version_id")
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY ("owner_id") REFERENCES "Users"("user_id")
	ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY ("technology_id") REFERENCES "Technologies"("technology_id")
	ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY ("tracker_id") REFERENCES "Trackers"("tracker_id")
	ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX IF NOT EXISTS "Games_index_0"
ON "Games" ("game_id");
CREATE TABLE IF NOT EXISTS "Game_Versions" (
	"game_id" INTEGER NOT NULL,
	"version_id" INTEGER NOT NULL UNIQUE,
	"external_url" VARCHAR NOT NULL,
	"createdAt" DATE NOT NULL,
	"updatedAt" DATE NOT NULL,
	PRIMARY KEY("game_id", "version_id"),
	FOREIGN KEY ("game_id") REFERENCES "Games"("game_id")
	ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS "Users" (
	"user_id" INTEGER NOT NULL UNIQUE,
	"username" VARCHAR NOT NULL UNIQUE,
	"email" VARCHAR NOT NULL,
	"role" VARCHAR NOT NULL,
	"createdAt" DATE NOT NULL,
	"updatedAt" DATE NOT NULL,
	PRIMARY KEY("user_id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "Users_index_0"
ON "Users" ("user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "Users_index_1"
ON "Users" ("username");
CREATE TABLE IF NOT EXISTS "Games_Permissions" (
	"user_id" INTEGER NOT NULL,
	"game_id" INTEGER NOT NULL,
	"permission" VARCHAR NOT NULL CHECK(permission IN ("READ","WRITE")),
	"createdAt" DATE NOT NULL,
	"updatedAt" DATE NOT NULL,
	PRIMARY KEY("user_id", "game_id"),
	FOREIGN KEY ("game_id") REFERENCES "Games"("game_id")
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY ("user_id") REFERENCES "Users"("user_id")
	ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS "Games_Permissions_index_0"
ON "Games_Permissions" ("game_id", "user_id");
CREATE TABLE IF NOT EXISTS "Sessions" (
	"player_id" INTEGER NOT NULL,
	"version_id" INTEGER NOT NULL,
	"save_path" VARCHAR NOT NULL,
	PRIMARY KEY("player_id", "version_id"),
	FOREIGN KEY ("version_id") REFERENCES "Game_Versions"("version_id")
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY ("player_id") REFERENCES "Users"("user_id")
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS "Teacher_Guides" (
	"game_id" INTEGER NOT NULL UNIQUE,
	"language_id" INTEGER NOT NULL,
	"url" VARCHAR NOT NULL,
	"createdAt" DATE NOT NULL,
	"updatedAt" DATE NOT NULL,
	PRIMARY KEY("game_id", "language_id"),
	FOREIGN KEY ("game_id") REFERENCES "Games"("game_id")
	ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY ("language_id") REFERENCES "Languages"("language_id")
	ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS "Languages" (
	"language_id" INTEGER NOT NULL UNIQUE,
	"language" VARCHAR NOT NULL,
	"createdAt" DATE,
	"updatedAt" DATE,
	PRIMARY KEY("language_id")
);

CREATE TABLE IF NOT EXISTS "Technologies" (
	"technology_id" INTEGER NOT NULL UNIQUE,
	"technology" VARCHAR NOT NULL,
	"createdAt" DATE NOT NULL,
	"updatedAt" DATE NOT NULL,
	PRIMARY KEY("technology_id")
);

CREATE TABLE IF NOT EXISTS "Trackers" (
	"tracker_id" INTEGER NOT NULL UNIQUE,
	"tracker" VARCHAR NOT NULL,
	"public" BOOLEAN NOT NULL,
	"owner_id" INTEGER NOT NULL,
	"createdAt" DATE NOT NULL,
	"updatedAt" DATE NOT NULL,
	PRIMARY KEY("tracker_id", "owner_id"),
	FOREIGN KEY ("owner_id") REFERENCES "Users"("user_id")
	ON UPDATE NO ACTION ON DELETE NO ACTION
);
