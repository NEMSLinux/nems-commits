# nems-commits
Commit aggregator for NEMS Linux

## Demo
https://nemslinux.com/changelog/

## Install
git clone --recurse-submodules https://github.com/Cat5TV/nems-commits

## Execute the Aggregator
/path/to/aggregator.sh

## Include in PHP
$commits = unserialize(file_get_contents('/path/to/data/nems-commits.ser'));

## Add repo
```
cd repos
git submodule add https://github.com/PATH_TO_REPOSITORY
```
Once added, also visit Settings->Webhooks in the repository on GitHub and add the #development Discord webhook.
