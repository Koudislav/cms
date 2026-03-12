SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

CREATE TABLE `articles` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`title` varchar(255) NOT NULL,
	`show_title` tinyint(1) NOT NULL DEFAULT 1,
	`slug` varchar(255) NOT NULL,
	`content` longtext NOT NULL,
	`type` enum('article','news','index') NOT NULL DEFAULT 'article',
	`seo_title` varchar(255) DEFAULT NULL,
	`seo_description` varchar(255) DEFAULT NULL,
	`seo_robots` varchar(50) DEFAULT NULL,
	`og_image` varchar(255) DEFAULT NULL,
	`is_published` tinyint(1) NOT NULL DEFAULT 1,
	`published_at` datetime DEFAULT NULL,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	`updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
	`created_by` int(10) unsigned DEFAULT NULL,
	`updated_by` int(10) unsigned DEFAULT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `slug` (`slug`),
	KEY `fk_articles_created_by` (`created_by`),
	KEY `fk_articles_updated_by` (`updated_by`),
	KEY `idx_articles_slug` (`slug`),
	KEY `idx_articles_published` (`is_published`),
	CONSTRAINT `fk_articles_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
	CONSTRAINT `fk_articles_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

DELIMITER ;;

CREATE TRIGGER `articles_bu` BEFORE UPDATE ON `articles` FOR EACH ROW
INSERT INTO `articles_history` (
	article_id,
	title,
	show_title,
	slug,
	content,
	type,
	seo_title,
	seo_description,
	seo_robots,
	og_image,
	is_published,
	published_at,
	created_at,
	updated_at,
	created_by,
	updated_by,
	changed_by,
	changed_at
)
VALUES (
	OLD.id,
	OLD.title,
	OLD.show_title,
	OLD.slug,
	OLD.content,
	OLD.type,
	OLD.seo_title,
	OLD.seo_description,
	OLD.seo_robots,
	OLD.og_image,
	OLD.is_published,
	OLD.published_at,
	OLD.created_at,
	OLD.updated_at,
	OLD.created_by,
	OLD.updated_by,
	NEW.updated_by,
	NOW()
);;

DELIMITER ;

CREATE TABLE `articles_history` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`article_id` int(10) unsigned NOT NULL,
	`title` varchar(255) NOT NULL,
	`show_title` tinyint(1) NOT NULL DEFAULT 1,
	`slug` varchar(255) NOT NULL,
	`content` longtext NOT NULL,
	`type` enum('article','news','index') NOT NULL DEFAULT 'article',
	`seo_title` varchar(255) DEFAULT NULL,
	`seo_description` varchar(255) DEFAULT NULL,
	`seo_robots` varchar(50) DEFAULT NULL,
	`og_image` varchar(255) DEFAULT NULL,
	`is_published` tinyint(1) NOT NULL DEFAULT 1,
	`published_at` datetime DEFAULT NULL,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	`updated_at` datetime DEFAULT NULL,
	`created_by` int(10) unsigned DEFAULT NULL,
	`updated_by` int(10) unsigned DEFAULT NULL,
	`changed_by` int(10) unsigned NOT NULL,
	`changed_at` datetime NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`),
	KEY `created_by` (`created_by`),
	KEY `updated_by` (`updated_by`),
	KEY `changed_by` (`changed_by`),
	CONSTRAINT `articles_history_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
	CONSTRAINT `articles_history_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
	CONSTRAINT `articles_history_ibfk_3` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

CREATE TABLE `configuration` (
	`key` varchar(50) NOT NULL,
	`category` enum('basic','seo','mail','graphics','licence') NOT NULL,
	`sort_order` int(11) NOT NULL DEFAULT 100,
	`type` enum('label','description','bool','string','int','float','enum') NOT NULL,
	`enum_options` varchar(255) DEFAULT NULL,
	`description` varchar(255) DEFAULT NULL,
	`access_role` varchar(50) DEFAULT NULL,
	`active` tinyint(1) NOT NULL DEFAULT 1,
	`value_bool` tinyint(1) DEFAULT NULL,
	`value_string` varchar(255) DEFAULT NULL,
	`value_int` int(11) DEFAULT NULL,
	`value_float` float DEFAULT NULL,
	`created_at` timestamp NOT NULL DEFAULT current_timestamp(),
	`updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	`edited_by` int(10) unsigned DEFAULT NULL,
	PRIMARY KEY (`key`),
	KEY `edited_by` (`edited_by`),
	CONSTRAINT `configuration_ibfk_1` FOREIGN KEY (`edited_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

DELIMITER ;;

CREATE TRIGGER `configuration_bu` BEFORE UPDATE ON `configuration` FOR EACH ROW
INSERT INTO `configuration_history` (
	`key`, `category`, `sort_order`, `type`, `enum_options`, `description`, `access_role`, `active`,
	`value_bool`, `value_string`, `value_int`, `value_float`,
	`created_at`, `updated_at`, `edited_by`, `edited_at`
) VALUES (
	OLD.`key`, OLD.`category`, OLD.`sort_order`, OLD.`type`, OLD.`enum_options`, OLD.`description`, OLD.`access_role`, OLD.`active`,
	OLD.`value_bool`, OLD.`value_string`, OLD.`value_int`, OLD.`value_float`,
	OLD.`created_at`, OLD.`updated_at`, OLD.`edited_by`, NOW()
);;

DELIMITER ;

CREATE TABLE `configuration_history` (
	`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
	`key` varchar(50) NOT NULL,
	`category` varchar(50) NOT NULL,
	`sort_order` int(11) NOT NULL DEFAULT 100,
	`type` enum('label','description','bool','string','int','float','enum') NOT NULL,
	`enum_options` varchar(255) DEFAULT NULL,
	`description` varchar(255) DEFAULT NULL,
	`access_role` varchar(50) DEFAULT NULL,
	`active` tinyint(1) NOT NULL DEFAULT 1,
	`value_bool` tinyint(1) DEFAULT NULL,
	`value_string` varchar(255) DEFAULT NULL,
	`value_int` int(11) DEFAULT NULL,
	`value_float` float DEFAULT NULL,
	`created_at` timestamp NOT NULL DEFAULT current_timestamp(),
	`updated_at` timestamp NOT NULL DEFAULT current_timestamp(),
	`edited_by` int(10) unsigned DEFAULT NULL,
	`edited_at` timestamp NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`),
	KEY `edited_by` (`edited_by`),
	CONSTRAINT `configuration_history_ibfk_1` FOREIGN KEY (`edited_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

CREATE TABLE `events` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`event_type_id` int(10) unsigned NOT NULL,
	`resource_id` int(10) unsigned DEFAULT NULL,
	`title` varchar(255) NOT NULL,
	`description` text DEFAULT NULL,
	`status` enum('draft','confirmed','blocked','cancelled') NOT NULL DEFAULT 'confirmed',
	`visibility` enum('public','private') NOT NULL DEFAULT 'public',
	`color_override` varchar(20) DEFAULT NULL,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	`updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
	PRIMARY KEY (`id`),
	KEY `idx_type` (`event_type_id`),
	KEY `idx_resource` (`resource_id`),
	KEY `idx_status` (`status`),
	KEY `idx_visibility` (`visibility`),
	CONSTRAINT `fk_events_resource` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT `fk_events_type` FOREIGN KEY (`event_type_id`) REFERENCES `event_types` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `event_occurrences` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`event_id` int(10) unsigned NOT NULL,
	`starts_at` datetime NOT NULL,
	`ends_at` datetime NOT NULL,
	`is_all_day` tinyint(1) NOT NULL DEFAULT 1,
	`capacity_used` int(10) unsigned DEFAULT NULL,
	`note` varchar(255) DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY `idx_range` (`starts_at`,`ends_at`),
	KEY `idx_event` (`event_id`),
	KEY `idx_start` (`starts_at`),
	KEY `idx_end` (`ends_at`),
	CONSTRAINT `fk_occ_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `event_tags` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` varchar(100) NOT NULL,
	`slug` varchar(100) NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `slug` (`slug`),
	KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `event_tag_map` (
	`event_id` int(10) unsigned NOT NULL,
	`tag_id` int(10) unsigned NOT NULL,
	PRIMARY KEY (`event_id`,`tag_id`),
	KEY `idx_tag` (`tag_id`),
	CONSTRAINT `fk_tagmap_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
	CONSTRAINT `fk_tagmap_tag` FOREIGN KEY (`tag_id`) REFERENCES `event_tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `event_types` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` varchar(100) NOT NULL,
	`slug` varchar(100) NOT NULL,
	`color` varchar(20) DEFAULT NULL,
	`blocks_capacity` tinyint(1) NOT NULL DEFAULT 0,
	`is_active` tinyint(1) NOT NULL DEFAULT 1,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`),
	UNIQUE KEY `slug` (`slug`),
	KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `galleries` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`title` varchar(255) NOT NULL,
	`description` longtext DEFAULT NULL,
	`is_published` tinyint(4) NOT NULL DEFAULT 1,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	`updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
	`created_by` int(10) unsigned DEFAULT NULL,
	`updated_by` int(10) unsigned DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY `created_by` (`created_by`),
	KEY `edited_by` (`updated_by`),
	CONSTRAINT `galleries_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
	CONSTRAINT `galleries_edited_by_fk` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

CREATE TABLE `gallery_pictures` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`gallery_id` int(10) unsigned NOT NULL,
	`original_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL,
	`filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci DEFAULT NULL,
	`description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci DEFAULT NULL,
	`path_original` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci DEFAULT NULL,
	`path_big` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci DEFAULT NULL,
	`path_medium` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci DEFAULT NULL,
	`path_small` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci DEFAULT NULL,
	`processed` enum('new','processing','done','error') CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL DEFAULT 'new',
	`is_visible` tinyint(1) unsigned NOT NULL DEFAULT 1,
	`is_cover` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	`created_by` int(10) unsigned DEFAULT NULL,
	`edited_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
	`edited_by` int(10) unsigned DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY `gallery_id` (`gallery_id`),
	KEY `created_by` (`created_by`),
	KEY `edited_by` (`edited_by`),
	CONSTRAINT `pictures_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
	CONSTRAINT `pictures_edited_by_fk` FOREIGN KEY (`edited_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
	CONSTRAINT `pictures_gallery_fk` FOREIGN KEY (`gallery_id`) REFERENCES `galleries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `menus` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`menu_key` varchar(100) NOT NULL,
	`parent_id` int(10) unsigned DEFAULT NULL,
	`label` varchar(255) NOT NULL,
	`presenter` varchar(100) DEFAULT NULL,
	`action` varchar(100) NOT NULL DEFAULT 'default',
	`target_id` int(10) unsigned DEFAULT NULL,
	`params` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`params`)),
	`position` int(11) NOT NULL DEFAULT 0,
	`is_active` tinyint(1) NOT NULL DEFAULT 1,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`),
	KEY `idx_menus_menu_key` (`menu_key`),
	KEY `idx_menus_parent` (`parent_id`),
	CONSTRAINT `fk_menus_parent` FOREIGN KEY (`parent_id`) REFERENCES `menus` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

CREATE TABLE `resources` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` varchar(150) NOT NULL,
	`slug` varchar(150) NOT NULL,
	`capacity` int(10) unsigned DEFAULT NULL,
	`location` varchar(255) DEFAULT NULL,
	`is_active` tinyint(1) NOT NULL DEFAULT 1,
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	`updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
	PRIMARY KEY (`id`),
	UNIQUE KEY `slug` (`slug`),
	KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `templates` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`description` varchar(255) DEFAULT NULL,
	`content` longtext NOT NULL,
	`type` enum('content','layout','component') NOT NULL DEFAULT 'content',
	`is_active` tinyint(1) NOT NULL DEFAULT 1,
	`is_system` tinyint(1) NOT NULL DEFAULT 0,
	`version` int(10) unsigned NOT NULL DEFAULT 1,
	`placeholders_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`placeholders_json`)),
	`created_at` datetime NOT NULL DEFAULT current_timestamp(),
	`updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
	`created_by` int(10) unsigned DEFAULT NULL,
	`updated_by` int(10) unsigned DEFAULT NULL,
	PRIMARY KEY (`id`),
	KEY `idx_templates_type` (`type`),
	KEY `idx_templates_active` (`is_active`),
	KEY `idx_templates_system` (`is_system`),
	KEY `fk_templates_created_by` (`created_by`),
	KEY `fk_templates_updated_by` (`updated_by`),
	CONSTRAINT `fk_templates_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
	CONSTRAINT `fk_templates_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

DELIMITER ;;

CREATE TRIGGER `templates_before_update_version` BEFORE UPDATE ON `templates` FOR EACH ROW
BEGIN
	SET NEW.version = OLD.version + 1;
END;;

CREATE TRIGGER `templates_before_update_history` BEFORE UPDATE ON `templates` FOR EACH ROW
BEGIN
	INSERT INTO `templates_history` (
		template_id,
		name,
		description,
		content,
		type,
		is_active,
		is_system,
		version,
		placeholders_json,
		original_created_at,
		original_updated_at,
		original_created_by,
		original_updated_by,
		history_action
	)
	VALUES (
		OLD.id,
		OLD.name,
		OLD.description,
		OLD.content,
		OLD.type,
		OLD.is_active,
		OLD.is_system,
		OLD.version,
		OLD.placeholders_json,
		OLD.created_at,
		OLD.updated_at,
		OLD.created_by,
		OLD.updated_by,
		'update'
	);
END;;

CREATE TRIGGER `templates_before_delete_history` BEFORE DELETE ON `templates` FOR EACH ROW
BEGIN
	INSERT INTO `templates_history` (
		template_id,
		name,
		description,
		content,
		type,
		is_active,
		is_system,
		version,
		placeholders_json,
		original_created_at,
		original_updated_at,
		original_created_by,
		original_updated_by,
		history_action
	)
	VALUES (
		OLD.id,
		OLD.name,
		OLD.description,
		OLD.content,
		OLD.type,
		OLD.is_active,
		OLD.is_system,
		OLD.version,
		OLD.placeholders_json,
		OLD.created_at,
		OLD.updated_at,
		OLD.created_by,
		OLD.updated_by,
		'delete'
	);
END;;

DELIMITER ;

CREATE TABLE `templates_history` (
  `history_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `template_id` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `content` longtext NOT NULL,
  `type` enum('content','layout','component') NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_system` tinyint(1) NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `placeholders_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`placeholders_json`)),
  `original_created_at` datetime NOT NULL,
  `original_updated_at` datetime DEFAULT NULL,
  `original_created_by` int(10) unsigned DEFAULT NULL,
  `original_updated_by` int(10) unsigned DEFAULT NULL,
  `history_action` enum('update','delete') NOT NULL,
  `history_created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`history_id`),
  KEY `idx_history_template_id` (`template_id`),
  KEY `idx_history_action` (`history_action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('superadmin','admin','owner') NOT NULL DEFAULT 'admin',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;
