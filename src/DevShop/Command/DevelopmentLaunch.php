<?php

namespace DevShop\Command;

use DevShop\Console\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\Console\Question\ChoiceQuestion;
use Symfony\Component\Console\Question\ConfirmationQuestion;

use Symfony\Component\Process\Process;
use Github\Client;

use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Symfony\Component\Process\Exception\ProcessFailedException;

class DevelopmentLaunch extends Command
{
  protected function configure()
  {
    $version = $this->getApplication();

    print_r($version);

    $this
      ->setName('development:launch')
      ->setDescription('Launch a development environment with Docker.')
      ->addArgument(
        'devshop-version',
        InputArgument::OPTIONAL,
        'The git tag or branch to install.',
        $version
      )
    ;
  }

  protected function execute(InputInterface $input, OutputInterface $output)
  {
    // Attaches input and output to the Command class.
    parent::execute($input, $output);

    $helper = $this->getHelper('question');

    // Announce ourselves.
    $output->writeln($this->getApplication()->getLogo());
    $this->announce('Launch Development Environment');
    $output->writeln('');

    // Check for 'docker' command and ability to run.
    try {
      $this->getProcess('docker')->mustRun();
    }
    catch (ProcessFailedException $e) {
      $output->writeln('<error>Unable to run `docker` command. See https://docs.docker.com/engine/installation/ for more information on how to install docker.</error>');
      exit(1);
    }

    $output->writeln('<info>SUCCESS</info> docker command found!');
    $output->writeln('Executing docker-development-environment.sh...');

    // Check for 'docker' command and ability to run.
    try {
      $process = $this->getProcess('bash docker-development-environment.sh', __DIR__ . '/../../../');
      $process->setTimeout(NULL);
      $process->mustRun(function ($type, $buffer) {
        if (Process::ERR === $type) {
          echo $buffer;
        } else {
          echo $buffer;
        }
      });
      return TRUE;


    }
    catch (ProcessFailedException $e) {
      $output->writeln("<error>Unable to run the helper script 'docker-development-environment.sh'.</error> Try  `bashdocker-development-environment.sh` to debug.");

      $output->writeln($e->getMessage());
      exit(1);
    }
  }
}