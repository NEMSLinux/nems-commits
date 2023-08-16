#!/usr/bin/php
<?php

chdir(__DIR__); // just in case we're running in cron

printf('Please wait...');
exec("./pull.sh");
echo ' ready.' . PHP_EOL;

$reposfolder = "repos";
$repos = array_diff(scandir($reposfolder), array('..', '.')); // get a list of the repos. Add new with: git submodule add https://github.com/Cat5TV/reponame
chdir($reposfolder); // enter the repos folder

if (is_array($repos)) {
  $sorted=array();

  foreach ($repos as $repo) {
    printf('Importing log for ' . $repo . '...');

    // Change To Repo Directory
    chdir($repo);

    // Load Git Logs for this repo
    $git_history = [];
    $git_logs = [];
    exec("git log", $git_logs);

    // Parse Logs
    $last_hash = null;
    foreach ($git_logs as $line)
    {
        // Clean Line
        $line = trim($line);

        // Proceed If There Are Any Lines
        if (!empty($line))
        {
            // Commit
            if (strpos($line, 'commit') !== false)
            {
                $hash = explode(' ', $line);
                $hash = trim(end($hash));
                $git_history[$hash] = [
                    'message' => ''
                ];
                $last_hash = $hash;
            }

            // Author
            else if (strpos($line, 'Author') !== false) {
                $author = explode(':', $line);
                $author = trim(end($author));
                $git_history[$last_hash]['author'] = $author;
            }

            // Date
            else if (strpos($line, 'Date') !== false) {
                $date = explode(':', $line, 2);
                $date = trim(end($date));
                $git_history[$last_hash]['date'] = date('c', strtotime($date));
            }

            // Message
            else {
                $git_history[$last_hash]['message'] .= $line ." ";
            }
        }
    }

    if (is_array($git_history) && count($git_history) > 0) {
      foreach ($git_history as $commit=>$record) {
        if (isset($record['date']) && strlen($record['date']) > 0) {
          $timestamp = strtotime($record['date']);
            if ($timestamp > 1478696230) { // one second before the first NEMS push
            while (isset($sorted[$timestamp])) {
              $timestamp++; // we don't have to be THAT accurate - so if a
            }
            $sorted[$timestamp]['repo'] = $repo;
            $sorted[$timestamp]['commit'] = $commit;
            $sorted[$timestamp]['message'] = $record['message'];
            $sorted[$timestamp]['author'] = $record['author'];
            $sorted[$timestamp]['date'] = $record['date'];
          }
        }
      }
    }

    // return to repos base folder
    chdir("..");
    echo ' done.' . PHP_EOL;
  }
  krsort($sorted);
}
chdir(".."); // return to the root of the aggregator

echo 'Exporting data:';

# Add more output options if you like (eg., JSON, XML)
printf(' - Serialized Array...');
file_put_contents(__DIR__.'/data/nems-commits.ser',serialize($sorted));
echo ' done.' . PHP_EOL;

echo 'All done.' . PHP_EOL;
?>
