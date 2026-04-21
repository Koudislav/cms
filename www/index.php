<?php

declare(strict_types=1);

use App\Repository\ArticleRepository;
use App\Repository\NewsRepository;
use Nette\Caching\Cache;
use Nette\Caching\Storages\FileStorage;

require __DIR__ . '/../vendor/autoload.php';

setlocale(LC_ALL, 'cs_CZ.UTF-8');
date_default_timezone_set('Europe/Prague');

$bootstrap = new App\Bootstrap;
$container = $bootstrap->bootWebApplication();

$storage = new FileStorage(__DIR__ . '/../temp/cache');
$cache = new Cache($storage);

if ($cache->load(ArticleRepository::ALL_ARTICLE_PATHS_CACHE_KEY) === null) {
	$articleRepository = $container->getByType(ArticleRepository::class);
	$cache->save(ArticleRepository::ALL_ARTICLE_PATHS_CACHE_KEY, $articleRepository->getAllPaths(true), [Cache::Expire => '15 minutes']);
}

if ($cache->load(NewsRepository::ALL_NEWS_SLUGS_CACHE_KEY) === null) {
	$newsRepository = $container->getByType(NewsRepository::class);
	$cache->save(NewsRepository::ALL_NEWS_SLUGS_CACHE_KEY, $newsRepository->getAllSlugs(true), [Cache::Expire => '15 minutes']);
}

$application = $container->getByType(Nette\Application\Application::class);
$application->run();
