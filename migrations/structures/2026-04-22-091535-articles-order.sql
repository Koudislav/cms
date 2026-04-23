ALTER TABLE `articles`
ADD COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `parent_id`;

ALTER TABLE `articles_history`
ADD COLUMN `sort_order` int(10) unsigned NOT NULL DEFAULT 0 AFTER `parent_id`;

DROP TRIGGER IF EXISTS `articles_bu`;
DELIMITER ;;

CREATE TRIGGER `articles_bu` BEFORE UPDATE ON `articles` FOR EACH ROW
BEGIN
	INSERT INTO articles_history (
		article_id,
		parent_id,
		sort_order,
		inherits_from_id,
		title,
		show_title,
		slug,
		path,
		content,
		type,
		template_id,
		template_version,
		template_data_json,
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
		OLD.parent_id,
		OLD.sort_order,
		OLD.inherits_from_id,
		OLD.title,
		OLD.show_title,
		OLD.slug,
		OLD.path,
		OLD.content,
		OLD.type,
		OLD.template_id,
		OLD.template_version,
		OLD.template_data_json,
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
	);
END;;

DELIMITER ;