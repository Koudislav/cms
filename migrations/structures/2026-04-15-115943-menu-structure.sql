ALTER TABLE `menus`
ADD COLUMN `render_type` VARCHAR(20) DEFAULT 'link' AFTER `menu_key`;