use lib "./lib";
use Data::Dumper;
use hin;
use ilparser;
use MIME::Base64;
use Mojolicious::Lite;
use strict;
use warnings;

any '/parse' => sub {
    my $c = shift;
    my $lang = $c->param('lang');
    my %args = %{$c->req->params->to_hash};
    my $parser = ilparser::get_parser($lang);
    my $final_result = $parser->parse(%args);
    $c->render(json => $final_result);
};

ilparser::initialize_langs();

app->start;
