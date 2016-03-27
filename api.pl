#!/usr/bin/env perl
use Dir::Self;
use lib __DIR__ . "/lib";
use Data::Dumper;
use hin;
use common::parser qw(get_parser initialize_langs);
use MIME::Base64;
use Mojolicious::Lite;
use strict;
use warnings;

any '/parse' => sub {
    my $c = shift;
    my $lang = $c->param('lang');
    my %args = %{$c->req->params->to_hash};
    my $parser = get_parser($lang);
    my $final_result = $parser->parse(%args);
    if (exists $args{"pretty"}) {
        my $final_string = join "\n", map { "$_:\n$final_result->{$_}\n" } keys %$final_result;
        $c->render(template => 'pretty', result => $final_string);
    } else {
        $c->render(json => $final_result);
    }
};

initialize_langs();

app->start;
__DATA__

@@ pretty.html.ep
<pre><%= $result %></pre>
