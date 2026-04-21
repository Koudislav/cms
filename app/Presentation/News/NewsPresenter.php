<?php

namespace App\Presentation\News;

use App\Repository\GalleryRepository;
use App\Repository\NewsRepository;
use App\Service\SpecialCodesParser;
use Nette\Database\Table\ActiveRow;

final class NewsPresenter extends \App\Presentation\BasePresenter {

	/** @var GalleryRepository @inject */
	public $galleryRepository;

	/** @var NewsRepository @inject */
	public NewsRepository $newsRepository;

	public function actionDefault(string $slug): void {
		// Najdi novinku podle slug
		$new = $this->newsRepository->getBySlug($slug);

		if (!$new || !$new->is_published) {
			$this->error('Novinka nenalezena'); // 404
		}

		// Parsuj obsah pro shortcody, pokud nějaké novinka obsahuje
		$parser = new SpecialCodesParser($this);
		$newContent = $parser->parse($new->content);
		$this->template->articleContainerFluid = $parser->articleContainer($newContent);

		// Předání do šablony
		$this->template->news = $new;
		$this->template->newsContent = $newContent;

		// SEO
		$this->overwriteSeo($new);
	}

	public function actionList(): void {
		$news = $this->newsRepository->findAll();
		$this->template->newsList = $news;
		$this->seo->title = 'Novinky';
		$this->seo->ogTitle = 'Novinky';
		$this->seo->breadcrumbs = $this->buildSeoBreadcrumbs();
		$this->template->breadcrumbs = $this->buildTemplateBreadcrumbs();
	}

	protected function overwriteSeo($new): void {
		$this->seo->title = $new->seo_title ?: $new->title;
		$this->seo->ogTitle = $new->seo_title ?: $new->title;
		$this->seo->description = $new->seo_description ?: $this->seo->description;
		if (!empty($new->og_image)) {
			$this->seo->ogImage = $new->og_image;
		}
		$this->seo->breadcrumbs = $this->buildSeoBreadcrumbs($new);
		$this->template->breadcrumbs = $this->buildTemplateBreadcrumbs($new);
	}

	private function buildTemplateBreadcrumbs(?ActiveRow $new = null): array {
		$breadcrumbs = [];
		if (!$this->config['ui_breadcrumbs_news'])
			return $breadcrumbs;

		if ($this->config['ui_breadcrumbs_home']) {
			$breadcrumbs[$this->config['ui_breadcrumbs_home_text'] ?: 'Home'] = $this->link('//Home:default');
		}
		$breadcrumbs['Novinky'] = $this->link('//News:list');
		if ($new) {
			$breadcrumbs += [$new->title => $this->link('//News:default', ['slug' => $new->slug])];
		}

		if (!$this->config['ui_breadcrumbs_show_current']) {
			array_pop($breadcrumbs);
		}

		if (count($breadcrumbs) < (int) $this->config['ui_breadcrumbs_show_min_items']) {
			return [];
		}
		return $breadcrumbs;
	}

	private function buildSeoBreadcrumbs(?ActiveRow $new = null): array {
		$breadcrumbs = [$this->config['ui_breadcrumbs_home_text'] ?: 'Home' => $this->link('//Home:default')];
		$breadcrumbs += ['Novinky' => $this->link('//News:list')];
		if ($new) {
			$breadcrumbs += [$new->title => $this->link('//News:default', ['slug' => $new->slug])];
		}
		return $breadcrumbs;
	}

}
