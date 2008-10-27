package Framework::Redmash::Base::Standard;

use Moose;

sub initialize {
    my $self = shift;
    my $configure = shift;
    my $redmash_meta = shift;
    my $given = shift;

    my $name = $configure->name;

    $configure->setup_manifest->include(<<_END_);
run
run/root
run/tmp
assets
assets/root
assets/root/static
assets/root/static/css
assets/root/static/js
assets/tt
_END_

    $configure->setup_manifest->include(
        "assets/root/static/css/$name.css" => {
            content => <<_END_
body, table {
    font-family: Verdana, Arial, sans-serif;
    background-color: #fff;
}

a, a:hover, a:active, a:visited {
    text-decoration: none;
    font-weight: bold;
    color: #436b95;
}

a:hover {
    text-decoration: underline;
}

table.bare td {
    border: none;
}

ul.bare {
    margin: 0;
    padding: 0;
}

ul.bare li {
    margin: 0;
    padding: 0;
    list-style: none;
}

div.clear {
    clear: both;
}
_END_
        },

        "assets/tt/frame.tt.html" => {
            content => <<_END_,
[% INCLUDE assets %]
    
[% DEFAULT title = template.title %]
[% DEFAULT default_title = "$name" %]
[% DEFAULT title = default_title %]

[% CLEAR -%]
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>[% title %]</title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
[% yui.html %]
[% assets.export("css") %]

</head>
<body>
 
<div id="doc2">

<h1>$name</h1>

[% content %]
    
</div>
    
[% assets.export("js") %]

</body>
</html> 
_END_

        },

    );

    my $render_manifest = $given->{render_manifest};

    $configure->build(sub {
        my $kit = shift;
        my $configure = shift;

        if ($render_manifest) {
            $kit->render_manifest->include($render_manifest);
        }
        $configure->render_target(match => qr/.*/, content => 'render:TT');

    });
}

1;
