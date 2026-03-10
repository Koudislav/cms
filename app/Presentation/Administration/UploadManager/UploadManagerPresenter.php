<?php

declare(strict_types=1);

namespace App\Presentation\Administration\UploadManager;

use App\Forms\BootstrapFormFactory;
use Nette\Forms\Form;
use Nette\Utils\FileSystem;
use Nette\Utils\Finder;
use Nette\Utils\Strings;

final class UploadManagerPresenter extends \App\Presentation\Administration\BaseAdministrationPresenter {

	public function actionDefault(?string $folder = null) {
		if ($folder === '/') {
			$folder = null;
		}

		$wwwDir = realpath(self::WWW_DIR);
		$uploadDir = realpath(self::UPLOAD_DIR) . DIRECTORY_SEPARATOR;
		$currentFolder = realpath($uploadDir . $folder) . DIRECTORY_SEPARATOR;

		if (!str_starts_with($currentFolder, $uploadDir)) {
			$this->flashMessage('Neplatná cesta ke složce.', 'danger');
			$this->redirect('uploadManager:default', ['folder' => null]);
		} else {
			$relativePath = str_replace($wwwDir, '', rtrim($currentFolder, DIRECTORY_SEPARATOR));
			$this->template->relativePath = $relativePath;
		}
		$dirs = Finder::findDirectories()
			->in($currentFolder);

		$dirsProcessed = [];
		foreach ($dirs as $dir) {
			$name = $dir->getBasename();

			if (str_starts_with($name, '.')) {
				continue;
			}

			$dirsProcessed[] = [
				'relativePath' => str_replace(realpath(self::UPLOAD_DIR), '', rtrim($dir->getRealPath(), DIRECTORY_SEPARATOR)),
				'name' => $dir->getBasename(),
			];
		}

		$files = Finder::findFiles()
			->in($currentFolder);

		$filesProcessed = [];
		foreach ($files as $file) {
			$name = $file->getBasename();

			if (str_starts_with($name, '.')) {
				continue;
			}

			$ext = strtolower($file->getExtension());
			$relative = str_replace(realpath(self::WWW_DIR), '', $file->getRealPath());
		
			$filesProcessed[] = [
				'relativePath' => $relative,
				'publicPath' => $relative, // předpoklad: upload je pod www
				'name' => $file->getBasename(),
				'extension' => $ext,
				'isImage' => in_array($ext, ['jpg','jpeg','png','gif','webp','svg','ico']),
			];
		}

		if ($folder !== null) {
			$parentDir = dirname(rtrim($folder, '/\\'));
			if ($parentDir === '.' || $parentDir === DIRECTORY_SEPARATOR) {
				$parentDir = null;
			}
		}
		$this->template->parentDir = $parentDir ?? null;

		$this->template->dirs = $dirsProcessed;
		$this->template->files = $filesProcessed;
	}

	public function createComponentCreateFolderForm(): Form {
		$form = BootstrapFormFactory::create('inLine');
		$form->addHidden('folder')
			->setDefaultValue($this->getParameter('folder') ?? '');
		$form->addText('folderName', 'Název nové složky:')
			->setHtmlAttribute('placeholder', 'Název nové složky')
			->setRequired('Vyplňte název složky.');
		$form->addSubmit('submit', 'Vytvořit novou složku')
			->setHtmlAttribute('class', 'btn btn-primary');
		$form->onSuccess[] = [$this, 'createFolderFormSubmitted'];
		return $form;
	}

	public function createComponentUploadForm(): Form {
		$form = BootstrapFormFactory::create('inLine');
		$form->addHidden('folder')
			->setDefaultValue($this->getParameter('folder') ?? '');
		$form->addGroup();
		$form->addUpload('file', 'Vyberte soubor k nahrání:')
			->setRequired('Vyberte soubor k nahrání.');
		$form->addGroup();
		$form->addSubmit('submit', 'Nahrát soubor')
			->setHtmlAttribute('class', 'btn btn-primary');
		$form->onSuccess[] = [$this, 'uploadFormSubmitted'];
		return $form;
	}

	public function createFolderFormSubmitted(Form $form, \stdClass $values): void {
		$uploadDir = realpath(self::UPLOAD_DIR) . DIRECTORY_SEPARATOR;
		$currentFolder = $values->folder ? realpath($uploadDir . $values->folder) : $uploadDir;

		// Webalize název složky
		$nameWeb = Strings::webalize($values->folderName);

		$newFolder = $currentFolder . DIRECTORY_SEPARATOR . $nameWeb;
		if (!is_dir($newFolder)) {
			FileSystem::createDir($newFolder, 0755);
			$this->flashMessage('Složka vytvořena.', 'success');
		} else {
			$this->flashMessage('Složka již existuje.', 'warning');
		}

		$this->redirect('this', ['folder' => $values->folder]);
	}

	public function uploadFormSubmitted(Form $form, array $values): void {
		$uploadDir = realpath(self::UPLOAD_DIR) . DIRECTORY_SEPARATOR;
		$currentFolder = $values['folder'] ? realpath($uploadDir . $values['folder']) : $uploadDir;

		$file = $values['file'];

		if ($file->isOk()) {
			$name = $file->getName();
			$ext = pathinfo($name, PATHINFO_EXTENSION);
			$baseName = pathinfo($name, PATHINFO_FILENAME);

			// Webalize jen hlavní část názvu, přípona zůstane
			$safeName = Strings::webalize($baseName) . ($ext ? '.' . $ext : '');

			$filePath = $currentFolder . DIRECTORY_SEPARATOR . $safeName;
			$file->move($filePath);

			$this->flashMessage('Soubor nahrán.', 'success');
		} else {
			$this->flashMessage('Chyba při nahrávání souboru.', 'danger');
		}

		$this->redirect('this', ['folder' => $values['folder']]);
	}

	public function handleDeleteUpload(string $path): void {
		$uploadDir = realpath(self::UPLOAD_DIR);
		$fullPath = realpath(self::WWW_DIR . $path);

		if (!$fullPath || !str_starts_with($fullPath, $uploadDir)) {
			$this->sendJson(['status' => 'error']);
			return;
		}

		try {
			if (is_dir($fullPath)) {
				FileSystem::delete($fullPath);
			} elseif (is_file($fullPath) && !is_link($fullPath)) {
				// Ověření, že soubor není symlink
				unlink($fullPath);
			}
			$this->sendJson(['status' => 'ok']);
		} catch (\Nette\Application\AbortException $e) {
			throw $e;
		} catch (\Throwable $e) {
			\Tracy\Debugger::log($e, 'upload-delete');
			$this->sendJson(['status' => 'error']);
		}
	}

}
