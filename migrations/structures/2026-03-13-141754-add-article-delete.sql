ALTER TABLE articles
ADD deleted_at DATETIME NULL,
ADD deleted_by INT(10) UNSIGNED NULL,
ADD CONSTRAINT fk_articles_deleted_by
FOREIGN KEY (deleted_by) REFERENCES users(id)
ON DELETE SET NULL;