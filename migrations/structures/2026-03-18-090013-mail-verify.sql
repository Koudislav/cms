ALTER TABLE `users`
ADD COLUMN `email_verified_at` datetime DEFAULT NULL AFTER `email`,
ADD COLUMN `email_verification_token` varchar(255) DEFAULT NULL AFTER `email_verified_at`,
ADD COLUMN `email_verification_expires_at` datetime DEFAULT NULL AFTER `email_verification_token`,
ADD UNIQUE KEY `email_verification_token` (`email_verification_token`);