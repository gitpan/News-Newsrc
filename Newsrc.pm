# Copyright (c) 1996 Steven McDougall. All rights reserved.
# This module is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

# $Id: Newsrc.pm,v 1.3 1996/02/22 20:08:26 swm Exp swm $

# $Log: Newsrc.pm,v $
# Revision 1.3  1996/02/22  20:08:26  swm
# made Newsrc an Exporter
# documentation fixes
#

package News::Newsrc;

use strict;
use integer;
use vars qw(@ISA $VERSION);
use Set::IntSpan 1.01;

require 5.002;
require Exporter;

@ISA = qw(Exporter);
$VERSION = 1.02;
$Set::IntSpan::Empty_String = '';


sub new
{
    my $class = shift;
    bless { }, $class
}


sub load
{
    my($newsrc, $file) = @_;
    
    $file or $file = "$ENV{HOME}/.newsrc";
    $newsrc->{file} = $file;
    $newsrc->{group} = { };
    
    open(NEWSRC, $file) or return '';

    while (<NEWSRC>)
    {
	/^\s*$/ and next;
	s/\s//g;

	/^ ([^!:]+) ([!:]) (.*) $/x or 
	    die "Bad newsrc line: $file, line $.: $_\n";

	my($group, $sub, $articles) = ($1, $2, $3);
	
	$newsrc->{group}{$group}{subscribed} = $sub eq ':';
	
	eval 
	{ 
	    $newsrc->{group}{$group}{articles} = new Set::IntSpan $articles;
	};
	$@ and die "Bad article list: $file, line $.: $_\n";
    }
    
    close(NEWSRC);
    1
}


sub _scan    # Initializes a Newsrc object from a string.  Used for testing.
{
    my($newsrc, $scan) = @_;
    
    $newsrc->{group} = { };

    for (split(/\n/, $scan))
    {
	/^\s*$/ and next;
	s/\s//g;

	/^ ([^!:]+) ([!:]) (.*) $/x or die "Bad newsrc line: $_";
	my($group, $sub, $articles) = ($1, $2, $3);
	
	$newsrc->{group}{$group}{subscribed} = $sub eq ':';
	$newsrc->{group}{$group}{articles} = new Set::IntSpan $articles;
    }
}


sub save
{
    my $newsrc = shift;
    
    $newsrc->{file} or $newsrc->{file} = "$ENV{HOME}/.newsrc";
    $newsrc->save_as($newsrc->{file});
}


sub save_as
{
    my($newsrc, $file) = @_;
    
    -e $file and (rename($file, "$file.bak") or die "Can't backup $file\n");
    open(NEWSRC, "> $file") or die "Can't open $file\n";
    $newsrc->{file} = $file;
    
    my $group;
    for $group (sort keys %{$newsrc->{group}})
    {
	my $sub = $newsrc->{group}{$group}{subscribed} ? ':' : '!';
	my $articles = $newsrc->{group}{$group}{articles}->run_list();
	print NEWSRC "$group$sub $articles\n" or die "Can't write $file\n";
    }

    close NEWSRC;	
}


sub _dump	# Formats a Newsrc object to a string.  Used for testing
{
    my $newsrc = shift;
    my($group, $dump);

    $dump = '';
    for $group (sort keys %{$newsrc->{group}})
    {
	my $sub = $newsrc->{group}{$group}{subscribed} ? ':' : '!';
	my $articles = $newsrc->{group}{$group}{articles}->run_list();
	$dump .= "$group$sub $articles\n";
    }

    $dump;
}


sub add_group
{
    my($newsrc, $group) = @_;
    
    $newsrc->{group}{$group}{subscribed} = 1;
    $newsrc->{group}{$group}{articles  } = new Set::IntSpan;
}


sub del_group
{
    my($newsrc, $group) = @_;
    
    delete $newsrc->{group}{$group};
}


sub subscribe
{
    my($newsrc, $group) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    $newsrc->{group}{$group}{subscribed} = 1;
}


sub unsubscribe
{
    my($newsrc, $group) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    $newsrc->{group}{$group}{subscribed} = 0;
}


sub mark
{
    my($newsrc, $group, $article) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    insert { $newsrc->{group}{$group}{articles} } $article;
}


sub mark_list
{
    my($newsrc, $group, $list) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my $articles = union { $newsrc->{group}{$group}{articles} } $list;
    $newsrc->{group}{$group}{articles} = $articles;
}


sub mark_range
{
    my($newsrc, $group, $from, $to) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my $range = new Set::IntSpan "$from-$to";
    my $articles = union { $newsrc->{group}{$group}{articles} } $range;
    $newsrc->{group}{$group}{articles} = $articles;
}


sub unmark
{
    my($newsrc, $group, $article) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    remove { $newsrc->{group}{$group}{articles} } $article;
}


sub unmark_list
{
    my($newsrc, $group, $list) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my $articles = diff { $newsrc->{group}{$group}{articles} } $list;
    $newsrc->{group}{$group}{articles} = $articles;
}


sub unmark_range
{
    my($newsrc, $group, $from, $to) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my $range = new Set::IntSpan "$from-$to";
    my $articles = diff { $newsrc->{group}{$group}{articles} } $range;
    $newsrc->{group}{$group}{articles} = $articles;
}


sub exists
{
    my($newsrc, $group) = @_;
    $newsrc->{group}{$group} ? 1 : ''
}


sub subscribed
{
    my($newsrc, $group) = @_;
    $newsrc->exists($group) and $newsrc->{group}{$group}{subscribed}
}


sub marked
{
    my($newsrc, $group, $article) = @_;

    $newsrc->exists($group) and 
	member {  $newsrc->{group}{$group}{articles} } $article
}


sub groups
{
    my $newsrc = shift;
    my @groups = sort keys %{$newsrc->{group}};
    wantarray ? @groups : \@groups
}


sub sub_groups
{
    my $newsrc = shift;
    my @groups = keys %{$newsrc->{group}};
    my @sub_groups = sort grep { $newsrc->{group}{$_}{'subscribed'} } @groups;
    wantarray ? @sub_groups : \@sub_groups
}


sub unsub_groups
{
    my $newsrc = shift;
    my @groups = keys %{$newsrc->{group}};
    my @unsub_groups = sort 
	grep { not $newsrc->{group}{$_}{'subscribed'} } @groups;
    wantarray ? @unsub_groups : \@unsub_groups
}


sub marked_articles
{
    my($newsrc, $group) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my @marked = elements { $newsrc->{group}{$group}{articles} };
    wantarray ? @marked : \@marked
}


sub unmarked_articles
{
    my($newsrc, $group, $from, $to) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my $range = new Set::IntSpan "$from-$to";
    my $unmarked = diff $range $newsrc->{group}{$group}{articles};
    my @unmarked = elements $unmarked;
    wantarray ? @unmarked : \@unmarked
}


1

__END__


=head1 NAME

News::Newsrc - manage newsrc files

=head1 SYNOPSIS

    use News::Newsrc;

    $newsrc = new News::Newsrc;
    
    $newsrc->load();
    $newsrc->load($file);
    
    $newsrc->save();
    $newsrc->save_as($file);

    $newsrc->add_group($group);
    $newsrc->del_group($group);
	
    $newsrc->subscribe  ($group);
    $newsrc->unsubscribe($group);

    $newsrc->mark        ($group,  $article);
    $newsrc->mark_list   ($group, \@articles);
    $newsrc->mark_range  ($group, $from, $to);
    
    $newsrc->unmark      ($group,  $article);
    $newsrc->unmark_list ($group, \@articles);
    $newsrc->unmark_range($group, $from, $to);
    
    ... if $newsrc->exists    ($group);
    ... if $newsrc->subscribed($group);
    ... if $newsrc->marked    ($group, $article);
    
    @groups   = $newsrc->groups();
    @groups   = $newsrc->sub_groups();
    @groups   = $newsrc->unsub_groups();
    @articles = $newsrc->marked_articles($group);
    @articles = $newsrc->unmarked_articles($group, $from, $to);

=head1 REQUIRES

Perl 5.002, Exporter, Set::IntSpan 1.01

=head1 EXPORTS

None

=head1 DESCRIPTION

News::Newsrc manages newsrc files, of the style

    alt.foo: 1-21,28,31-34
    alt.bar! 3,5,9-2900,2902

Methods are provided for

=over 4

=item *

reading and writing newsrc files

=item *

adding and removing newsgroups

=item *

subscribing and unsubscribing from newsgroups

=item *

testing whether groups exist and are subscribed

=item *

marking and unmarking articles

=item *

testing whether articles are marked

=item *

returning lists of newsgroups

=item *

returning lists of articles

=back

=head1 NEWSRC FILES

A newsrc file is an ASCII file that lists newsgroups and article numbers.
Each line of a newsrc file describes a single newsgroup.
Each line is divided into three fields: 
a I<group>, a I<subscription mark> and an I<article list>.

Lines containing only whitespace are ignored.
Whitespace within a line is ignored.

=over 4

=item Group

The I<group> is the name of the newsgroup.
A group name may not contain colons (:) or exclamation points (!).
Group names must be unique within a newsrc file.
The group name is required.

=item Subscription mark

The I<subscription mark> is either a colon (:), for subscribed groups,
or an exclamation point (!), for unsubscribed groups.
The subscription mark is required.

=item Article list

The I<article list> is a comma-separated list of positive integers.
The integers must be listed in increasing order.
Runs of consecutive integers may be abbreviated a-b, 
where a is the first integer in the run and b is the last.
The article list may be empty.

=back

=head1 METHODS

=over 4

=item new News::Newsrc

Creates and returns a News::Newsrc object.
The object contains no newsgroups.

=item load()

=item load($file)

Loads the newsgroups in $file into a newsrc object.
If $file is omitted, reads $ENV{HOME}/.newsrc.
Any existing data in the object is discarded.
Returns non-null on success.

If $file can't be opened,
load() discards existing data from the newsrc object and returns null.

If $file contains invalid lines, load() will die().
When this happens, the state of the newsrc object is undefined.

=item save()

Writes the contents of a newsrc object back to the file 
from which it was load()ed.
If load() has not been called, writes to $ENV{HOME}/.newsrc.
In either case, if the destination I<file> exists, 
it is renamed to I<file>.bak

=item save_as($file)

Writes the contents of a newsrc object to $file.
If $file exists, it is renamed to $file.bak.
Subsequent calls to save() will write to $file.

=item add_group($group)

Adds $group to the list of newsgroups in a newsrc object.
$group is initially subscribed.
The article list for $group is initially empty.

=item del_group($group)

Removes $group from the list of groups in a newsrc object.
The article list for $group is lost.

=item subscribe($group)

Subscribes to $group.  
$group will be created if it does not exist.

=item unsubscribe($group)

Unsubscribes from $group.  
$group will be created if it does not exist.

=item mark($group, $article)

Adds $article to the article list for $group.
$group will be created if it does not exist.

=item mark_list($group, \@articles)

Adds @articles to the article list for $group.
$group will be created if it does not exist.

=item mark_range($group, $from, $to)

Adds all the articles from $from to $to, inclusive, 
to the article list for $group.
$group will be created if it does not exist.

=item unmark($group, $article)

Removes $article from the article list for $group.
$group will be created if it does not exist.

=item unmark_list($group, \@articles)

Removes @articles from the article list for $group.
$group will be created if it does not exist.

=item unmark_range($group, $from, $to)

Removes all the articles from $from to $to, inclusive, 
from the article list for $group.
$group will be created if it does not exist.

=item exists($group)

Returns true if $group exists in the newsrc object.

=item subscribed($group)

Returns true if $group exists and is subscribed.

=item marked($group, $article)

Returns true if $group exists and its article list contains $article.

=item groups()

Returns the list of groups in a newsrc object.
In scalar context, returns an array reference.

=item sub_groups()

Returns the list of subscribed groups in a newsrc object.
In scalar context, returns an array reference.

=item unsub_groups()

Returns the list of unsubscribed groups in a newsrc object.
In scalar context, returns an array reference.

=item marked_articles($group)

Returns the list of articles in the article list for $group.
In scalar context, returns an array reference.

=item unmarked_articles($group, $from, $to)

Returns the list of articles from $from to $to, inclusive,
that do I<not> appear in the article list for $group.
In scalar context, returns an array reference.

=back

=head1 DIAGNOSTICS

load() returns null if it can't open the newsrc file.

load() will die() if the newsrc file contains invalid lines.

save() and save_as() will die() if they can't backup or write the
newsrc file.

=head1 ERROR HANDLING

"Don't test for errors that you can't handle."

load() returns null if it can't open the newsrc file, 
and dies if the newsrc file contains invalid data.
This isn't as schizophrenic as it seems.

There are several ways a program could handle an open failure on the newsrc file.
It could prompt the user to reenter the file name.
It could assume that the user doesn't have a newsrc file yet.
If it doesn't want to handle the error, it could go ahead and die.

On the other hand, 
it is very difficult for a program to do anything sensible 
if the newsrc file opens successfully 
and then turns out to contain invalid data.
Was there a disk error?  
Is the file corrupt?
Did the user accidentally specify his kill file instead of his newsrc file?
And what are you going to do about it?

Rather than try to handle an error like this,
it's probably better to die and let the user sort things out.
By the same rational,
save() and save_as() die on failure.

Programs that must retain control can use eval{...} 
to protect calls that may die.
For example, Perl/Tk runs all callbacks inside an eval{...}.
If a callback dies,
Perl/Tk regains control and displays $@ in a dialog box.
The user can then decide whether to continue or quit from the program.

=head1 AUTHOR

Steven McDougall, swm@cric.com

=head1 SEE ALSO

perl(1), Set::IntSpan

=head1 COPYRIGHT

Copyright (c) 1996 Steven McDougall. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
