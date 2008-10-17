package Framework::Redmash::App;

use strict;
use warnings;

use Getopt::Chain;
use Class::Inspector;
use Path::Class;

my $ABORT = sub {
    print STDERR join "", '! ', @_, "\n";
    exit -1;
};
sub abort {
    $ABORT->(@_);
}

my $REPORT = sub {
    print STDOUT join "", '# ', @_, "\n";
};
sub report {
    $REPORT->(@_);
}

my $HOME = dir '.';
sub home() {
    return $HOME;
}

sub redmash_file {
    return home->file(".redmash");
}

sub package_filename {
    return Class::Inspector->resolved_filename(shift, '.');
}

sub run {
    my $self = shift;
    {
        my $given = {};
        $given = shift if ref $_[0] eq 'HASH';

        $ABORT = $given->{abort} if $given->{abort};
        $REPORT = $given->{report} if $given->{report};
        $HOME = dir $given->{home} if $given->{home};
    }

    Getopt::Chain->process(
    
        (@_ ? \@_ : ()),

        commands => {

            setup => sub {
                my $ctx = shift;
                my $package = shift;

                abort "Wasn't given a package to setup" unless $package;

                my $package_filename = package_filename $package or abort "Couldn't find file for package $package";

            
                report "package = $package";
                report "package filename = $package_filename";

                my $redmash_file = redmash_file;

                # TODO Need some sort of check here (or warning)
                # abort "File .redmash already exists" if -e $redmash_file;

                $redmash_file->openw->print("$package");

                eval "require $package;" or abort "Unable to load $package since: $@";
                my $redmash_meta = $package->redmash_meta;

                my $manifest = $redmash_meta->manifest;
                $manifest->each(sub {
                    my $file = shift;
                    my $home_file = home->file($file->path);
                    return if -e $home_file;
                    if ($file->content) {
                        $home_file->parent->mkpath unless -d $home_file->parent;
                        $home_file->openw->print($file->content);
                    }
                    else {
                        $home_file = dir $home_file;
                        $home_file->mkpath;
                    }
                });
            },
            
            about => sub {
                my $ctx = shift;

                my $redmash_file = redmash_file;

                abort "File .redmash desn't exist (did you init?)" unless -e $redmash_file;

                my $package = $redmash_file->slurp;
                chomp $package;

                abort "File .redmash does not contain a package name" unless $package; 

                report ".redmash = $redmash_file";
                report "package = $package";

                eval "require $package;" or abort "Unable to load $package since: $@";
                my $redmash_meta = $package->redmash_meta;

                report "base = ", $redmash_meta->base;

                report "manifest =";
                my $manifest = $redmash_meta->manifest;
                $manifest->each(sub {
                    my $file = shift;
                    report "\t", $file->path, (defined $file->comment ? (' # ', $file->comment) : ());
                });
            },
            
        },

    );
}

1;
