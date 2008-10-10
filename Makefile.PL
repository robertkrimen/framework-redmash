use inc::Module::Install;

name 'Framework-Redmash';
all_from 'lib/Framework/Redmash.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

