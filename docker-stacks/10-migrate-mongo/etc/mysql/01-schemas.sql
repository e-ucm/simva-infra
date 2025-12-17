CREATE TABLE IF NOT EXISTS `SIMLETs` (
	`simlet_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(100) NOT NULL,
	`created` DATETIME,
	`sandbox_session_id` INTEGER,
	`description` VARCHAR(255) NOT NULL,
	`objective` VARCHAR(255),
	`allocator_id` INTEGER NOT NULL,
	`simlet_coordinator_id` INTEGER NOT NULL,
	PRIMARY KEY(`simlet_id`)
);


CREATE TABLE IF NOT EXISTS `SIMLETs_groups` (
	`simlet_id` INTEGER NOT NULL,
	`group_id` INTEGER NOT NULL,
	PRIMARY KEY(`simlet_id`, `group_id`)
);


CREATE TABLE IF NOT EXISTS `SIMLETs_shlinks` (
	`simlet_id` INTEGER NOT NULL UNIQUE,
	`short_url` VARCHAR(100) NOT NULL,
	`short_code` VARCHAR(25) NOT NULL,
	`date_created` DATETIME NOT NULL,
	`valid_date` DATETIME,
	`expiration_date` DATETIME,
	`title` VARCHAR(255) NOT NULL,
	`domain` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`simlet_id`)
);


CREATE TABLE IF NOT EXISTS `Sessions` (
	`simlet_id` INTEGER NOT NULL,
	`session_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(100) NOT NULL,
	`description` VARCHAR(255) NOT NULL,
	`date` DATETIME,
	`experimental_method` VARCHAR(20),
	`active` BOOLEAN,
	`session_start_date` DATETIME,
	`session_end_date` DATETIME,
	`session_supervisor_id` INTEGER NOT NULL,
	PRIMARY KEY(`session_id`)
);


CREATE TABLE IF NOT EXISTS `Activities` (
	`session_id` INTEGER NOT NULL,
	`activity_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(100) NOT NULL,
	`activity_type` ENUM('default', 'manual', 'gameplay', 'limesurvey', 'lti-tool') NOT NULL,
	`presignedUrl` VARCHAR(50),
	`generated_at` DATETIME,
	`expire_on_seconds` INTEGER,
	`trace_storage` BOOLEAN NOT NULL,
	`description` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`activity_id`)
);


CREATE TABLE IF NOT EXISTS `Limesurvey_Activities` (
	`activity_id` INTEGER NOT NULL UNIQUE,
	`survey_id` INTEGER NOT NULL,
	`survey_owner` INTEGER,
	`language` VARCHAR(10) NOT NULL,
	`lrsset` INTEGER,
	PRIMARY KEY(`activity_id`)
);


CREATE TABLE IF NOT EXISTS `GamePlay_Activities` (
	`activity_id` INTEGER NOT NULL UNIQUE,
	`backup` BOOLEAN NOT NULL,
	`scorm_xapi_by_game` BOOLEAN NOT NULL,
	`category` VARCHAR(50),
	`subject_area` VARCHAR(50),
	`game_type` ENUM('WEB', 'DESKTOP') NOT NULL,
	`game_url` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`activity_id`)
);


CREATE TABLE IF NOT EXISTS `Manual_Activities` (
	`activity_id` INTEGER NOT NULL UNIQUE,
	`user_managed` BOOLEAN NOT NULL,
	`ressource_type` ENUM('WEB', 'EXTERNAL') NOT NULL,
	`ressource_url` VARCHAR(100) NOT NULL,
	PRIMARY KEY(`activity_id`)
);


CREATE TABLE IF NOT EXISTS `Activities_completion` (
	`activity_id` INTEGER NOT NULL,
	`participant_id` INTEGER NOT NULL,
	`initialized` BOOLEAN NOT NULL,
	`completed` BOOLEAN NOT NULL,
	`progress` NUMERIC,
	PRIMARY KEY(`activity_id`, `participant_id`)
);


CREATE TABLE IF NOT EXISTS `Users` (
	`user_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`username` VARCHAR(255) NOT NULL UNIQUE,
	`isToken` BOOLEAN NOT NULL,
	`token` VARCHAR(50),
	`email` VARCHAR(255) NOT NULL,
	`role` VARCHAR(50) NOT NULL,
	PRIMARY KEY(`user_id`)
);


CREATE TABLE IF NOT EXISTS `ParticipantGroups` (
	`group_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`mongo_id` VARCHAR(50),
	`name` VARCHAR(255) NOT NULL,
	`created` DATETIME NOT NULL,
	`use_new_generation` BOOLEAN NOT NULL,
	`group_owner_id` INTEGER NOT NULL,
	PRIMARY KEY(`group_id`)
);


CREATE TABLE IF NOT EXISTS `ParticipantGroups_permission` (
	`group_id` INTEGER NOT NULL,
	`user_id` INTEGER NOT NULL,
	`permission` ENUM('READ', 'WRITE') NOT NULL,
	PRIMARY KEY(`group_id`, `user_id`)
);


CREATE TABLE IF NOT EXISTS `Allocators` (
	`allocator_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`allocator_type` ENUM('default', 'group', 'random') NOT NULL,
	`mongo_id` VARCHAR(50),
	PRIMARY KEY(`allocator_id`)
);


CREATE UNIQUE INDEX `Allocator_index_0`
ON `Allocators` (`allocator_id`);
CREATE TABLE IF NOT EXISTS `Experimental_Participants` (
	`allocator_id` INTEGER NOT NULL,
	`session_id` INTEGER NOT NULL,
	`participant_id` INTEGER NOT NULL,
	PRIMARY KEY(`allocator_id`, `session_id`, `participant_id`)
);


CREATE TABLE IF NOT EXISTS `Random_Allocators` (
	`allocator_id` INTEGER NOT NULL,
	`session_id` INTEGER NOT NULL,
	`percentage` FLOAT NOT NULL,
	PRIMARY KEY(`allocator_id`, `session_id`)
);


CREATE TABLE IF NOT EXISTS `SIMLETs_tags` (
	`simlet_id` INTEGER NOT NULL,
	`tag_id` INTEGER NOT NULL,
	PRIMARY KEY(`simlet_id`, `tag_id`)
);


CREATE TABLE IF NOT EXISTS `Sessions_tags` (
	`session_id` INTEGER NOT NULL,
	`tag_id` INTEGER NOT NULL,
	PRIMARY KEY(`session_id`, `tag_id`)
);


CREATE TABLE IF NOT EXISTS `ParticipantGroups_participants` (
	`group_id` INTEGER NOT NULL,
	`participant_id` INTEGER NOT NULL,
	PRIMARY KEY(`group_id`, `participant_id`)
);


CREATE TABLE IF NOT EXISTS `Sessions_permission` (
	`session_id` INTEGER NOT NULL,
	`user_id` INTEGER NOT NULL,
	`permission` ENUM('READ', 'WRITE') NOT NULL,
	PRIMARY KEY(`session_id`, `user_id`)
);


CREATE TABLE IF NOT EXISTS `SIMLETs_permission` (
	`simlet_id` INTEGER NOT NULL,
	`user_id` INTEGER NOT NULL,
	`permission` ENUM('READ', 'WRITE') NOT NULL,
	PRIMARY KEY(`simlet_id`, `user_id`)
);


CREATE TABLE IF NOT EXISTS `Activities_template` (
	`activity_template_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(100) NOT NULL,
	`activity_type` ENUM('default', 'manual', 'gameplay', 'limesurvey', 'lti-tool') NOT NULL,
	`description` VARCHAR(255) NOT NULL,
	`public` BOOLEAN NOT NULL,
	PRIMARY KEY(`activity_template_id`)
);


CREATE UNIQUE INDEX `Activity_index_0`
ON `Activities_template` (`activity_id`);
CREATE TABLE IF NOT EXISTS `Manual_Template_Activities` (
	`activity_template_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`ressource_type` ENUM('EXTERNAL', 'WEB') NOT NULL,
	`ressource_url` VARCHAR(100) NOT NULL,
	PRIMARY KEY(`activity_template_id`)
);


CREATE TABLE IF NOT EXISTS `GamePlay_Activities_Template` (
	`activity_template_id` INTEGER NOT NULL UNIQUE,
	`category` VARCHAR(50) NOT NULL,
	`subject_area` VARCHAR(50) NOT NULL,
	`game_type` ENUM('WEB', 'DESKTOP') NOT NULL,
	`game_url` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`activity_template_id`)
);


CREATE UNIQUE INDEX `Manual_Activity_index_0`
ON `GamePlay_Activities_Template` (`activity_id`);
CREATE TABLE IF NOT EXISTS `Limesurvey_Activities_Template` (
	`activity_template_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`survey_id` INTEGER NOT NULL,
	`survey_owner` INTEGER,
	PRIMARY KEY(`activity_template_id`)
);


CREATE UNIQUE INDEX `Limesurvey_Activity_index_0`
ON `Limesurvey_Activities_Template` (`activity_id`);
CREATE TABLE IF NOT EXISTS `SIMLETs_tags_list` (
	`simlet_tag_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`simlet_tag_name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`simlet_tag_id`)
);


CREATE TABLE IF NOT EXISTS `sessions_tags_list` (
	`session_tag_id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`session_tag_name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`session_tag_id`)
);


ALTER TABLE `SIMLETs_shlinks`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs_groups`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs_tags`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Experimental_Participants`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Random_Allocators`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Sessions_tags`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Limesurvey_Activities`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `GamePlay_Activities`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Manual_Activities`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Activities_completion`
ADD FOREIGN KEY(`activity_id`) REFERENCES `Activities`(`activity_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Activities_completion`
ADD FOREIGN KEY(`participant_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Experimental_Participants`
ADD FOREIGN KEY(`participant_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Limesurvey_Activities`
ADD FOREIGN KEY(`survey_owner`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs_groups`
ADD FOREIGN KEY(`group_id`) REFERENCES `ParticipantGroups`(`group_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `ParticipantGroups_permission`
ADD FOREIGN KEY(`group_id`) REFERENCES `ParticipantGroups`(`group_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Experimental_Participants`
ADD FOREIGN KEY(`allocator_id`) REFERENCES `Allocators`(`allocator_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Random_Allocators`
ADD FOREIGN KEY(`allocator_id`) REFERENCES `Allocators`(`allocator_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs`
ADD FOREIGN KEY(`allocator_id`) REFERENCES `Allocators`(`allocator_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs`
ADD FOREIGN KEY(`sandbox_session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE `ParticipantGroups_permission`
ADD FOREIGN KEY(`user_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Sessions`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Activities`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `ParticipantGroups_participants`
ADD FOREIGN KEY(`group_id`) REFERENCES `ParticipantGroups`(`group_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `ParticipantGroups_participants`
ADD FOREIGN KEY(`participant_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Sessions_permission`
ADD FOREIGN KEY(`user_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs_permission`
ADD FOREIGN KEY(`user_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Sessions_permission`
ADD FOREIGN KEY(`session_id`) REFERENCES `Sessions`(`session_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Manual_Template_Activities`
ADD FOREIGN KEY(`activity_template_id`) REFERENCES `Activities_template`(`activity_template_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Limesurvey_Activities_Template`
ADD FOREIGN KEY(`activity_template_id`) REFERENCES `Activities_template`(`activity_template_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `GamePlay_Activities_Template`
ADD FOREIGN KEY(`activity_template_id`) REFERENCES `Activities_template`(`activity_template_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Sessions_tags`
ADD FOREIGN KEY(`tag_id`) REFERENCES `sessions_tags_list`(`session_tag_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs_tags`
ADD FOREIGN KEY(`tag_id`) REFERENCES `SIMLETs_tags_list`(`simlet_tag_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `SIMLETs_permission`
ADD FOREIGN KEY(`simlet_id`) REFERENCES `SIMLETs`(`simlet_id`)
ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE `ParticipantGroups`
ADD FOREIGN KEY(`group_owner_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `Sessions`
ADD FOREIGN KEY(`session_supervisor_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE `SIMLETs`
ADD FOREIGN KEY(`simlet_coordinator_id`) REFERENCES `Users`(`user_id`)
ON UPDATE CASCADE ON DELETE SET NULL;