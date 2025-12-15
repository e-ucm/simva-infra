CREATE TABLE IF NOT EXISTS `SIMLETs` (
	`simlet_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(100) NOT NULL,
	`created` DATETIME,
	`sandbox_id` INTEGER,
	`version` INTEGER,
	`description` VARCHAR(255) NOT NULL,
	`objective` VARCHAR(255),
	`allocator_id` INTEGER NOT NULL,
	PRIMARY KEY(`simlet_id`)
);


CREATE UNIQUE INDEX `SIMLET_index_0`
ON `SIMLETs` (`simlet_id`);
CREATE TABLE IF NOT EXISTS `SIMLETs_sessions` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`simlet_id` INTEGER NOT NULL,
	`session_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `SIMLET-session_index_0`
ON `SIMLETs_sessions` (`simlet_id`, `session_id`);
CREATE TABLE IF NOT EXISTS `Users_Roles` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`user_id` INTEGER NOT NULL,
	`role_id` INTEGER NOT NULL,
	`simlet_id` INTEGER,
	`session_id` INTEGER,
	`activity_id` INTEGER,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `SIMLET-coordinator_index_0`
ON `Users_Roles` (`simlet_id`, `session_id`, `activity_id`);
CREATE TABLE IF NOT EXISTS `SIMLETs_groups` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`simlet_id` INTEGER NOT NULL,
	`group_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `SIMLET-group_index_0`
ON `SIMLETs_groups` (`simlet_id`, `group_id`);
CREATE TABLE IF NOT EXISTS `SIMLETs_shlinks` (
	`simlet_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`short_url` VARCHAR(100) NOT NULL,
	`short_code` VARCHAR(25) NOT NULL,
	`date_created` DATETIME NOT NULL,
	`valid_date` DATETIME,
	`expiration_date` DATETIME,
	`title` VARCHAR(255) NOT NULL,
	`domain` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`simlet_id`)
);


CREATE UNIQUE INDEX `SIMLET_shlink_index_0`
ON `SIMLETs_shlinks` (`simlet_id`);
CREATE TABLE IF NOT EXISTS `Sessions` (
	`session_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(100) NOT NULL,
	`version` INTEGER,
	`description` VARCHAR(255) NOT NULL,
	`date` DATETIME,
	`experimental_method` VARCHAR(20),
	`active` BOOLEAN,
	`session_start_date` DATETIME,
	`session_end_date` DATETIME,
	`session_duration` NUMERIC,
	PRIMARY KEY(`session_id`)
);


CREATE UNIQUE INDEX `Session_index_0`
ON `Sessions` (`session_id`);
CREATE TABLE IF NOT EXISTS `Sessions_Activities` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`session_id` INTEGER NOT NULL,
	`activity_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `Session-Activity_index_0`
ON `Sessions_Activities` (`session_id`, `activity_id`);
CREATE TABLE IF NOT EXISTS `Activities` (
	`activity_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(100) NOT NULL,
	`type` VARCHAR(20) NOT NULL,
	`presignedUrl` VARCHAR(50),
	`generated_at` DATETIME,
	`expire_on_seconds` INTEGER,
	`version` INTEGER,
	`trace_storage` BOOLEAN NOT NULL,
	`description` VARCHAR(255) NOT NULL,
	`isTemplate` BOOLEAN NOT NULL,
	PRIMARY KEY(`activity_id`)
);


CREATE UNIQUE INDEX `Activity_index_0`
ON `Activities` (`activity_id`);
CREATE TABLE IF NOT EXISTS `Limesurvey_Activities` (
	`activity_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`survey_id` INTEGER NOT NULL,
	`survey_owner` INTEGER,
	`language` VARCHAR(10) NOT NULL,
	`lrsset` INTEGER,
	PRIMARY KEY(`activity_id`)
);


CREATE UNIQUE INDEX `Limesurvey_Activity_index_0`
ON `Limesurvey_Activities` (`activity_id`);
CREATE TABLE IF NOT EXISTS `GamePlay_Activities` (
	`activity_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`backup` BOOLEAN NOT NULL,
	`scorm_xapi_by_game` BOOLEAN NOT NULL,
	`category` VARCHAR(50),
	`subject_area` VARCHAR(50),
	`game_type` VARCHAR(50) NOT NULL,
	`game_technology` VARCHAR(50),
	`game_tracker` VARCHAR(50),
	`game_url` VARCHAR(255) NOT NULL,
	`game_version` INTEGER,
	PRIMARY KEY(`activity_id`)
);


CREATE UNIQUE INDEX `Manual_Activity_index_0`
ON `GamePlay_Activities` (`activity_id`);
CREATE TABLE IF NOT EXISTS `Manual_Activities` (
	`activity_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`user_managed` BOOLEAN NOT NULL,
	`ressource_type` VARCHAR(50) NOT NULL,
	`ressource_url` VARCHAR(100) NOT NULL,
	PRIMARY KEY(`activity_id`)
);


CREATE UNIQUE INDEX `Manual_Activity_index_0`
ON `Manual_Activities` (`activity_id`);
CREATE TABLE IF NOT EXISTS `Activities_completion` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`activity_id` INTEGER NOT NULL,
	`participant_id` INTEGER NOT NULL,
	`initialized` BOOLEAN NOT NULL,
	`completed` BOOLEAN NOT NULL,
	`progress` FLOAT,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `Activity_index_0`
ON `Activities_completion` (`activity_id`, `participant_id`);
CREATE TABLE IF NOT EXISTS `Users` (
	`user_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`username` VARCHAR(255) NOT NULL UNIQUE,
	`email` VARCHAR(255) NOT NULL,
	`role` VARCHAR(50) NOT NULL,
	PRIMARY KEY(`user_id`)
);


CREATE UNIQUE INDEX `User_index_0`
ON `Users` (`user_id`);
CREATE TABLE IF NOT EXISTS `ParticipantGroups` (
	`group_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(255) NOT NULL,
	`created` DATETIME NOT NULL,
	`version` INTEGER NOT NULL,
	PRIMARY KEY(`group_id`)
);


CREATE UNIQUE INDEX `Group_index_0`
ON `ParticipantGroups` (`group_id`);
CREATE TABLE IF NOT EXISTS `ParticipantGroups_participants` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`group_id` INTEGER NOT NULL,
	`participant_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `Group-participants_index_0`
ON `ParticipantGroups_participants` (`group_id`, `participant_id`);
CREATE TABLE IF NOT EXISTS `ParticipantGroups_owners` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`group_id` INTEGER NOT NULL,
	`owner_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `Group-owner_index_0`
ON `ParticipantGroups_owners` (`group_id`, `owner_id`);
CREATE TABLE IF NOT EXISTS `Allocators` (
	`allocator_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`type` VARCHAR(25) NOT NULL,
	PRIMARY KEY(`allocator_id`)
);


CREATE UNIQUE INDEX `Allocator_index_0`
ON `Allocators` (`allocator_id`);
CREATE TABLE IF NOT EXISTS `Default_Allocators` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`allocator_id` INTEGER NOT NULL,
	`session_id` INTEGER NOT NULL,
	`participant_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `Default_Allocator_index_0`
ON `Default_Allocators` (`allocator_id`, `session_id`, `participant_id`);
CREATE TABLE IF NOT EXISTS `Group_Allocators` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`allocator_id` INTEGER NOT NULL,
	`session_id` INTEGER NOT NULL,
	`group_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `Group_Allocator_index_0`
ON `Group_Allocators` (`allocator_id`, `session_id`, `group_id`);
CREATE TABLE IF NOT EXISTS `SIMLETs_tags` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`simlet_id` INTEGER NOT NULL,
	`tag` VARCHAR(25) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE INDEX `SIMLET_TAG_index_0`
ON `SIMLETs_tags` (`simlet_id`);
CREATE TABLE IF NOT EXISTS `Sessions_tags` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`session_id` INTEGER NOT NULL,
	`tag` VARCHAR(25) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE INDEX `Session_tag_index_0`
ON `Sessions_tags` (`session_id`);
CREATE TABLE IF NOT EXISTS `GamePlay_Versions` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`game_id` INTEGER NOT NULL,
	`version_id` INTEGER NOT NULL,
	`game_type` VARCHAR(50) NOT NULL,
	`game_technology` VARCHAR(50) NOT NULL,
	`game_tracker` VARCHAR(50) NOT NULL,
	`game_url` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE UNIQUE INDEX `GamePlay_Version_index_0`
ON `GamePlay_Versions` (`game_id`, `version_id`);
CREATE TABLE IF NOT EXISTS `Roles` (
	`role_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`role_name` VARCHAR(50) NOT NULL,
	PRIMARY KEY(`role_id`)
);


CREATE INDEX `Roles_index_0`
ON `Roles` (`role_id`);
ALTER TABLE `Users_Roles`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs_sessions`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs_shlinks`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs_groups`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs_tags`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs_sessions`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Default_Allocators`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Group_Allocators`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Sessions_tags`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Sessions_Activities`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Limesurvey_Activities`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Sessions_Activities`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `GamePlay_Activities`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Manual_Activities`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Activities_completion`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Users_Roles`
ADD FOREIGN KEY(`user_id`) REFERENCES `Users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `ParticipantGroups_owners`
ADD FOREIGN KEY(`owner_id`) REFERENCES `Users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `ParticipantGroups_participants`
ADD FOREIGN KEY(`participant_id`) REFERENCES `Users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Activities_completion`
ADD FOREIGN KEY(`participant_id`) REFERENCES `Users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Default_Allocators`
ADD FOREIGN KEY(`participant_id`) REFERENCES `Users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Limesurvey_Activities`
ADD FOREIGN KEY(`survey_owner`) REFERENCES `Users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `ParticipantGroups_owners`
ADD FOREIGN KEY(`group_id`) REFERENCES `ParticipantGroups`(`group_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs_groups`
ADD FOREIGN KEY(`group_id`) REFERENCES `ParticipantGroups`(`group_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `ParticipantGroups_participants`
ADD FOREIGN KEY(`group_id`) REFERENCES `ParticipantGroups`(`group_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Group_Allocators`
ADD FOREIGN KEY(`group_id`) REFERENCES `ParticipantGroups`(`group_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Default_Allocators`
ADD FOREIGN KEY(`allocator_id`) REFERENCES `Allocators`(`allocator_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Group_Allocators`
ADD FOREIGN KEY(`allocator_id`) REFERENCES `Allocators`(`allocator_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs`
ADD FOREIGN KEY(`allocator_id`) REFERENCES `Allocators`(`allocator_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `SIMLETs`
ADD FOREIGN KEY(`sandbox_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Users_Roles`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Users_Roles`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Users_Roles`
ADD FOREIGN KEY(`role_id`) REFERENCES `Roles`(`role_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

INSERT INTO Roles (role_name) VALUES ('(SIMLET)'), ('(Session)'), ('(Activity)');
