<?php

declare(strict_types=1);

namespace App\Service;

use App\Config\Config;
use Nette\Caching\Cache;
use Nette\Caching\Storage;

class DiskQuotaService {

	public const CacheKey = 'diskQuotaUsage';
	public const CacheMinutes = 5;

	private Cache $cache;
	private string $wwwDir;
	private int $limitBytes;

	public function __construct(
		private Storage $storage,
		private Config $config,
		string $wwwDir,
	) {
		$this->cache = new Cache($storage);
		$this->wwwDir = realpath($wwwDir);
		$this->limitBytes = BytesHelper::parseBytes($this->config['aplication_size']);
	}

	public function getUsageBytes(): int {
		return $this->cache->load(self::CacheKey, function (&$dependencies) {
			$dependencies[Cache::Expire] = self::CacheMinutes . ' minutes';

			exec('du -sb ' . escapeshellarg($this->wwwDir), $size);
			return (int)explode("\t", $size[0])[0];
		});
	}

	public function getLimitBytes(): int {
		return $this->limitBytes;
	}

	public function getUsagePercent(): float {
		return round(($this->getUsageBytes() / $this->limitBytes) * 100, 2);
	}

	public function isQuotaExceeded(): bool {
		return $this->getUsageBytes() >= $this->limitBytes;
	}

	public function isQuotaWarning(): bool {
		return $this->getUsagePercent() >= 75;
	}

	public function isQuotaCritical(): bool {
		return $this->getUsagePercent() >= 90;
	}

	public function getUsageFormatted(): string {
		return BytesHelper::formatBytes($this->getUsageBytes());
	}

	public function getLimitFormatted(): string {
		return BytesHelper::formatBytes($this->limitBytes);
	}

	public function clearCache(): void {
		$this->cache->remove(self::CacheKey);
	}

	public function getCacheMinutes(): int {
		return self::CacheMinutes;
	}

	public function canStore(int $bytes): bool {
		return ($this->getUsageBytes() + $bytes) <= $this->limitBytes;
	}
	
	public function assertCanStore(int $bytes): void {
		if (!$this->canStore($bytes)) {
			throw new \RuntimeException('Disková kvóta byla překročena.');
		}
	}

}
