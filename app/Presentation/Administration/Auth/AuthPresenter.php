<?php

declare(strict_types=1);

namespace App\Presentation\Administration\Auth;

use App\Repository\UserRepository;

final class AuthPresenter extends \App\Presentation\Administration\BaseAdministrationPresenter {

	/** @var UserRepository @inject */
	public UserRepository $userRepository;

	public function actionVerifyEmail(string $token): void {
		if (strlen($token) !== 64) {
			$this->flashMessage('Neplatný ověřovací odkaz.', 'danger');
			$this->redirect('Dashboard:default');
		}
		$user = $this->userRepository->getByVerificationToken($token);

		if (!$user) {
			$this->flashMessage('Ověřovací odkaz je neplatný, byl již použit, nebo byl vygenerován novější. Pokud máte stále problém s přihlášením, kontaktujte podporu.', 'danger');
			$this->redirect('Dashboard:default');
		}

		if (empty($user->email_verification_expires_at) || $user->email_verification_expires_at < new \DateTime()) {
			$this->flashMessage('Odkaz expiroval.', 'danger');
			$this->redirect('Dashboard:default');
		}

		$this->userRepository->markEmailAsVerified($user->id);

		$this->flashMessage('Email byl úspěšně ověřen.', 'success');
		$this->redirect('Dashboard:default');
	}

}
