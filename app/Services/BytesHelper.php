<?php

declare(strict_types=1);

namespace App\Service;

class BytesHelper {

	public static function parseBytes(string $size): int {
		$size = trim($size);
		$unit = strtolower($size[strlen($size)-1]);
		$bytes = (int)$size;
	
		switch ($unit) {
			case 'g':
				$bytes *= 1024;
			case 'm':
				$bytes *= 1024;
			case 'k':
				$bytes *= 1024;
		}
		return $bytes;
	}

	public static function formatBytes(int $bytes, int $precision = 2): string {
		$units = ['B', 'KB', 'MB', 'GB', 'TB'];
		$factor = floor((strlen((string)$bytes) - 1) / 3);
		return sprintf("%.{$precision}f", $bytes / pow(1024, $factor)) . ' ' . $units[(int)$factor];
	}

}
