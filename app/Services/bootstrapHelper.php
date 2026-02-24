<?php

declare(strict_types=1);

namespace App\Services;

use Nette\Utils\Html;
use Stringable;

class BootstrapHelper {

	public const BOOTSTRAP_POSITION_ENUM = [
		'start' => 'Vlevo',
		'center' => 'Uprostřed',
		'end' => 'Vpravo',
		'between' => 'Roztáhnout do krajů',
		'around' => 'Roztáhnout (s mezerami kolem)',
	];

	public const BOOTSTRAP_TEXT_COLOR_ENUM = [
		'primary' => 'Primární',
		'secondary' => 'Sekundární',
		'success' => 'Úspěch',
		'danger' => 'Nebezpečí',
		'warning' => 'Varování',
		'info' => 'Info',
		'light' => 'Světlá',
		'dark' => 'Tmavá',

		'body' => 'Text body',
		'body-secondary' => 'Text body secondary',
		'body-tertiary' => 'Text body tertiary',
		'body-emphasis' => 'Text emphasis',
		'black' => 'Černá',
		'white' => 'Bílá',
		'muted' => 'Tlumená',
	];

	public const BOOTSTRAP_BG_COLOR_ENUM = [
		'primary' => 'Primární',
		'primary-subtle' => 'Primární jemná',
		'secondary' => 'Sekundární',
		'secondary-subtle' => 'Sekundární jemná',
		'success' => 'Úspěch',
		'success-subtle' => 'Úspěch jemná',
		'danger' => 'Nebezpečí',
		'danger-subtle' => 'Nebezpečí jemná',
		'warning' => 'Varování',
		'warning-subtle' => 'Varování jemná',
		'info' => 'Info',
		'info-subtle' => 'Info jemná',
		'light' => 'Světlá',
		'light-subtle' => 'Světlá jemná',
		'dark' => 'Tmavá',
		'dark-subtle' => 'Tmavá jemná',

		'body' => 'Pozadí body',
		'body-secondary' => 'Pozadí body secondary',
		'body-tertiary' => 'Pozadí body tertiary',
		'transparent' => 'Transparentní',
		'white' => 'Bílá',
		'black' => 'Černá',
	];

	public const BOOTSTRAP_SPACING_SIZES = [
		'0' => '0',
		'1' => '1',
		'2' => '2',
		'3' => '3',
		'4' => '4',
		'5' => '5',
		'auto' => 'Auto',
	];
	
	public const BOOTSTRAP_SPACING_SIDES = [
		'' => 'Všechny strany',
		't' => 'Nahoře',
		'b' => 'Dole',
		's' => 'Start',
		'e' => 'End',
		'x' => 'Horizontálně',
		'y' => 'Vertikálně',
	];
	
	public const BOOTSTRAP_SPACING_TYPES = [
		'p' => 'Padding',
		'm' => 'Margin',
	];

	private const SPACING_TYPE_MAP = [
		'padding' => 'p',
		'margin' => 'm',
	];

	public static function getBootstrapPositionEnum(): array {
		return self::BOOTSTRAP_POSITION_ENUM;
	}

	public static function getBootstrapTextColorEnum(): array {
		return self::BOOTSTRAP_TEXT_COLOR_ENUM;
	}

	public static function getBootstrapBgColorEnum(): array {
		return self::BOOTSTRAP_BG_COLOR_ENUM;
	}

	public static function getEnum($type) {
		$enum = match ($type) {
			'position' => self::getBootstrapPositionEnum(),
			'color' => self::getBootstrapTextColorEnum(),
			'bgColor' => self::getBootstrapBgColorEnum(),
			default => throw new \InvalidArgumentException("Neznámý typ enum: $type"),
		};
		return self::putBadges($enum, $type);
	}

	public static function putBadges(array $items, $type): array {
		if ($type === 'position') {
			return $items;
		}
		$badges = [];
		foreach ($items as $key => $value) {
			$badges[$key] = self::putBadge($key, $value, $type);
		}
		return $badges;
	}

	public static function putBadge(string $color, string $text, $type): Stringable {
		$prefix = match ($type) {
			'color' => 'text-',
			'bgColor' => 'bg-',
			default => '',
		};
		$label = Html::el('span')
			->class('badge ' . $prefix . $color)
			->setText($text ?: $color);
		return $label;
	}

	public static function buildSpacingClass(?string $value): ?string {
		if (!$value) {
			return null;
		}
		// validace bootstrap spacing
		if (!preg_match('~^(p|m)([tbsexy]?)-(0|1|2|3|4|5|auto)$~', $value)) {
			return null;
		}

		return $value;
	}

	/**
	 * Generuje všechny možné kombinace spacing tříd pro Bootstrap 5.
	 * @param ?string $type Pokud je zadán konkrétní typ (padding/margin), generuje pouze pro tento typ.
	 */
	public static function getSpacingOptions(?string $type = null): array {
		$options = [];
		// filtr typů
		$allowedTypes = self::BOOTSTRAP_SPACING_TYPES;

		if ($type !== null) {
			if (!isset(self::SPACING_TYPE_MAP[$type])) {
				throw new \InvalidArgumentException("Neznámý spacing type: $type");
			}
			$bsType = self::SPACING_TYPE_MAP[$type];

			$allowedTypes = [
				$bsType => self::BOOTSTRAP_SPACING_TYPES[$bsType],
			];
		}
		foreach ($allowedTypes as $typeKey => $typeLabel) {
			foreach (self::BOOTSTRAP_SPACING_SIDES as $sideKey => $sideLabel) {
				foreach (self::BOOTSTRAP_SPACING_SIZES as $sizeKey => $sizeLabel) {
					// auto jen pro margin
					if ($sizeKey === 'auto' && $typeKey !== 'm') {
						continue;
					}
					$class = $typeKey . $sideKey . '-' . $sizeKey;
	
					$options[$class] =
						$typeLabel . ' • ' .
						$sideLabel . ' • ' .
						$sizeLabel;
				}
			}
		}
		return $options;
	}

}
