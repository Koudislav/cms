<?php

declare(strict_types=1);

namespace App\Presentation\Administration\ArticleTemplates;

use App\Forms\BootstrapFormFactory;
use Nette\Forms\Form;

final class ArticleTemplatesPresenter extends \App\Presentation\Administration\BaseAdministrationPresenter {

	public function renderDefault(int $templateId = 0): void {
		$this->template->currentTemplateId = $templateId;
		$data = $this->templateRepository->findAll();
		$templates = [];
		foreach ($data as $key => $article) {
			$templates[$key] = $article;
		}
		$this->template->templateName = $data[$templateId]->name ?? null;
		$this->template->menus = $templates;
	}

	public function createComponentTemplateForm() {
		$form = BootstrapFormFactory::create('oneLine');
		$templateId = (int) $this->getParameter('templateId');

		$form->addText('name', 'Název šablony:')
			->setRequired('Zadejte název šablony.');

		$form->addText('description', 'Popis šablony:');

		$form->addTextArea('content', 'Obsah:')
			->setHtmlAttribute('rows', 10)
			->setHtmlAttribute('class', 'tiny-editor');

		$form->addSubmit('submit', 'Uložit')
			->setHtmlAttribute('class', 'btn btn-primary');

		if ($templateId !== 0) {
			$templateData = $this->templateRepository->getTemplateById($templateId);
			$form->setDefaults($templateData->toArray());
		}

		$form->onSuccess[] = [$this, 'templateFormSubmitted'];

		return $form;
	}

	public function templateFormSubmitted(Form $form, $values): void {
		$templateId = (int) $this->getParameter('templateId');

		if ($templateId !== 0) {
			//edit
			$update = $this->templateRepository->updateTemplate($templateId, $values, $this->getUser()->getId());
			if (!$update) {
				$this->flashMessage('Nebyly provedeny žádné změny.', 'danger');
			} else {
				$this->flashMessage('Šablona byla úspěšně upravena.', 'success');
			}
			$this->redirect('this');
		} else {
			//novy
			$create = $this->templateRepository->createTemplate($values, $this->user->getId());
			foreach ($create['messages'] as $message) {
				foreach ($message as $type => $msg) {
					$this->flashMessage($msg, $type);
				}
			}
			$this->redirect('this', ['templateId' => $create['templateId']]);
		}
	}

}
