use inc::Module::Install;

name 'Framework-Redmash';
all_from 'lib/Framework/Redmash.pm';

resources repository => 'http://github.com/robertkrimen/framework-redmash/tree/master';

{
    require ExtUtils::MakeMaker;
    use strict;
    no strict 'refs';

    my $libscan = \&{"ExtUtils::MM_Any::libscan"};
    *{"ExtUtils::MM_Any::libscan"} = sub {
        return '' unless $libscan->(@_);
        return '' if $_[1] =~ /\.sw[p-z]$/;
        return $_[1];
    };
}

{
    map { my ($pk, $vr) = split m/\s/; build_requires $pk => $vr || 0 } grep { ! /^\s*#/ } split m/\n/, <<_END_;
Test::Most
_END_

    map { my ($pk, $vr) = split m/\s/; requires $pk => $vr || 0 } grep { ! /^\s*#/ } split m/\n/, <<_END_;
Moose 0.58
MooseX::Scaffold 0.02
Carp::Clan::Share
Class::Inspector
Class::MOP
Config::JFDI
File::Copy
File::Find
File::Spec::Link
Getopt::Chain
MooseX::ClassAttribute
MooseX::Types
MooseX::Types::Moose
MooseX::Types::Path::Class
Path::Class
Scalar::Util
Template
URI::PathAbstract
_END_
}

if (-e 'inc/.author') {
    my $all_from = join '/', 'lib', split m/-/, name . '.pm';
    `perldoc -tF $all_from > README` if ! -e 'README' || (stat $all_from)[9] > (stat 'README')[9];
}

auto_install;

WriteAll;

