# Copyright (c) 1996 Steven McDougall. All rights reserved.
# This module is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

# $Id: Newsrc.pm,v 1.3 1996/02/22 20:08:26 swm Exp $

# $Log: Newsrc.pm,v $
# Revision 1.3  1996/02/22  20:08:26  swm
# made Newsrc an Exporter
# documentation fixes
#

require 5.001;
package News::Newsrc;
$News::Newsrc::VERSION = 1.01;

require Exporter;
@ISA = qw(Exporter);

use strict;
use integer;
use Set::IntSpan 1.01;

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
    
    @groups = $newsrc->groups();
    $groups = $newsrc->groups();

    @groups = $newsrc->sub_groups();
    $groups = $newsrc->sub_groups();

    @groups = $newsrc->unsub_groups();
    $groups = $newsrc->unsub_groups();
	
    @articles = $newsrc->marked_articles($group);
    $articles = $newsrc->marked_articles($group);

    @articles = $newsrc->unmarked_articles($group, $from, $to);
    $articles = $newsrc->unmarked_articles($group, $from, $to);

=head1 REQUIRES

Perl 5.001

Set::IntSpan 1.01

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
Returns non-zero on success.

If $file can't be opened,
load() discards existing data from the newsrc object 
and returns the undefined value.

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

load() returns the undefined value if it can't open the newsrc file.

load will die() if the newsrc file contains invalid lines.

save() and save_as() will die() if they can't backup or write the
newsrc file.

=head1 TESTING

To test News::Newsrc, run it as a stand-alone Perl program:

    %perl Newsrc.pm
    OK
    %

Normal output is "OK"; anything else indicates a problem.

Add B<-v> flags for verbose output; the more flags, the more output.

The test routines create temporary files named ".newsrc", "newsrc", 
".newsrc.bak" and "newsrc.bak" in the current working directory; 
these files must not already exist.

=head1 AUTHOR

Steven McDougall <swm@cric.com>

=head1 COPYRIGHT

Copyright (c) 1996 Steven McDougall. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut


$Set::IntSpan::Empty_String = '';


sub new
{
    my $class = shift;
    bless { }, $class;
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
    1;
}


sub _scan    # Initializes a Newsrc object from a string.  Used for testing.
{
    my($newsrc, $scan) = @_;
    
    $newsrc->{group} = { };

    for (split(/\n/, $scan))
    {
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
    $newsrc->{group}{$group} ? 1 : '';
}


sub subscribed
{
    my($newsrc, $group) = @_;
    $newsrc->{group}{$group} and $newsrc->{group}{$group}{subscribed};
}


sub marked
{
    my($newsrc, $group, $article) = @_;
    $newsrc->{group}{$group} and 
	member {  $newsrc->{group}{$group}{articles} } $article;
}


sub groups
{
    my $newsrc = shift;
    my @groups = sort keys %{$newsrc->{group}};
    wantarray ? @groups : \@groups;
}


sub sub_groups
{
    my $newsrc = shift;
    my @groups = keys %{$newsrc->{group}};
    my @sub_groups = sort grep { $newsrc->{group}{$_}{subscribed} } @groups;
    wantarray ? @sub_groups : \@sub_groups;
}


sub unsub_groups
{
    my $newsrc = shift;
    my @groups = keys %{$newsrc->{group}};
    my @unsub_groups = sort 
	grep { not $newsrc->{group}{$_}{subscribed} } @groups;
    wantarray ? @unsub_groups : \@unsub_groups;
}


sub marked_articles
{
    my($newsrc, $group) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my @marked = elements { $newsrc->{group}{$group}{articles} };
    wantarray ? @marked : \@marked;
}


sub unmarked_articles
{
    my($newsrc, $group, $from, $to) = @_;
    $newsrc->{group}{$group} or $newsrc->add_group($group);
    my $range = new Set::IntSpan "$from-$to";
    my $unmarked = diff $range $newsrc->{group}{$group}{articles};
    my @unmarked = elements $unmarked;
    wantarray ? @unmarked : \@unmarked;
}

eval join('',<main::DATA>) or die $@ unless caller();

1;
__END__

package main;

#GLOBALS
my $Verbose;
my @Test_files = qw(newsrc .newsrc newsrc.bak .newsrc.bak);

my $TestRC = 
'a: 1-5
b! 3-8,15,20
c: 20-21,33,38
d: 1,3,7
f!
';


eval "no integer; $Set::IntSpan::VERSION > 1.00" or # don't ask...
    die "Requires Set::Intspan 1.01 or greater\n";
for (@ARGV) { /-v/ and $Verbose++ }
e_files(@Test_files);
$ENV{HOME} = '.';
eval { test() };
unlink @Test_files;
$@ and die $@;
print "OK\n";


sub e_files
{
    my @files = @_;
    my $f;

    for $f (@files)
    {
	-e $f and die "Can't test because ./$f exists\n";
    }
}


sub write_file
{
    my($name, $contents) = @_;
    $name or return;
    open(FILE, "> $name") or die "Can't open $name\n";
    print FILE $contents;
    close FILE;
}


sub read_file
{
    my($name) = @_;
    open(FILE, $name) or die "Can't open $name\n";
    my $contents = join('', <FILE>);
    close FILE;
    $contents;
}


sub test
{
    test_load      ();
    test_load_errs ();
    test_save      ();
    test_save_bak  ();
    test_save_load ();
    test_save_as   ();
    test_groups    ();
    test_marks     ();
    test_predicates();
    test_lists     ();
}


sub test_load
{
    print "load\n" if $Verbose;

    my @test = ([".newsrc"   , "a: 1,3\n" , ""          , 1 ],
		["newsrc"    , "b! 1-10\n", "newsrc"    , 1 ],
		[""          , ""         , "newsrc.bak", '']);

    my $t;
    my $rc = new News::Newsrc;

    unlink @Test_files;
    for $t (@test)
    {
	my($write_file, $contents, $load_file, $expected) = @$t;
	write_file($write_file, $contents);
	my $return = $rc->load($load_file);
	my $dump = $rc->_dump();
	my $message = sprintf("%-12s %s -> %d: %s\n", 
			      "load($load_file)", $contents, $return, $dump);
	die $message unless $return eq $expected and $dump eq $contents;
	print $message if $Verbose > 1;
    }
}


sub test_load_errs
{
    print "load errors\n" if $Verbose;

    my @test = ([ '.newsrc', 'a'      , 'newsrc' ],
		[ '.newsrc', 'a: 10-1', 'article']);

    my $t;
    my $rc = new News::Newsrc;

    unlink @Test_files;
    for $t (@test)
    {
	my($file, $contents, $error) = @$t;
	write_file($file, $contents);
	my $return = eval { $rc->load() };
	my $message = sprintf("%-12s %-10s -> %s", "load", $contents, $@);
	die $message if $return or  $@ !~ /$error/;
	print $message if $Verbose > 1;
    }
}


sub test_save
{
    print "save\n" if $Verbose;

    unlink @Test_files;
    my $rc = new News::Newsrc;
    my $scan ="a: 1,3\n";
    $rc->_scan($scan);
    $rc->save();
    my $read = read_file('.newsrc');
    my $message = sprintf("%-12s %-20s -> %s", "save", $scan, $read);
    die $message unless $scan eq $read;
    print $message if $Verbose > 1;
}


sub test_save_bak
{
    print "save_bak\n" if $Verbose;
    unlink @Test_files;
    my $rc = new News::Newsrc;

    $rc->save();
    my $result = -e '.newsrc.bak';
    my $message = sprintf("%-12s %-20s -> %d\n", "save", "", $result);
    die $message if $result;
    print $message if $Verbose > 1;

    $rc->save();
    my $result = -e '.newsrc.bak';
    my $message = sprintf("%-12s %-20s -> %d\n", "save", "", $result);
    die $message unless $result;
    print $message if $Verbose > 1;
}


sub test_save_load
{
    print "save_load\n" if $Verbose;
    my $rc = new News::Newsrc;

    write_file('newsrc', '');
    $rc->load('newsrc');
    unlink @Test_files;
    $rc->save();

    my $result = -e 'newsrc';
    my $message = sprintf("%-12s %-20s -> %d\n", "save", "", $result);
    die $message unless $result;
    print $message if $Verbose > 1;
}


sub test_save_as
{
    print "save_as\n" if $Verbose;
    my $rc = new News::Newsrc;

    unlink @Test_files;
    $rc->save_as('newsrc');
    my $result = -e 'newsrc';
    my $message = sprintf("%-12s %-20s -> %d\n", "save", "", $result);
    die $message unless $result;
    print $message if $Verbose > 1;

    unlink @Test_files;
    $rc->save();
    my $result = -e 'newsrc';
    my $message = sprintf("%-12s %-20s -> %d\n", "save", "", $result);
    die $message unless $result;
    print $message if $Verbose > 1;
}


sub test_groups
{
    print "groups\n" if $Verbose;

    my @test = 
	(["add_group"  , "a", "a: \n"               ],
	 ["add_group"  , "b", "a: \nb: \n"          ],
	 ["add_group"  , "c", "a: \nb: \nc: \n"     ],
	 ["del_group"  , "b", "a: \nc: \n"          ],
	 ["unsubscribe", "a", "a! \nc: \n"          ],
	 ["subscribe"  , "a", "a: \nc: \n"          ],
	 ["subscribe"  , "d", "a: \nc: \nd: \n"     ],
	 ["unsubscribe", "e", "a: \nc: \nd: \ne! \n"]);
	 
    my $rc = new News::Newsrc;
    my $t;
    for $t (@test)
    {
	my($op, $operand, $expected) = @$t;
	$rc->$op($operand);
	my $result = $rc->_dump();
	my $message = "$op($operand)\n$result";
	die $message unless $result eq $expected;
	print $message if $Verbose > 1;
    }
}


sub test_marks
{
    print "marks\n" if $Verbose;

    my @test1 = 
	(["mark        ('a', 1      )", "a: 1\nb: \nc: \n"                 ],
	 ["mark        ('b', 4      )", "a: 1\nb: 4\nc: \n"                ],
	 ["mark_list   ('c', [1,3,5])", "a: 1\nb: 4\nc: 1,3,5\n"           ],
	 ["mark_list   ('b', [1..10])", "a: 1\nb: 1-10\nc: 1,3,5\n"        ],
	 ["mark_range  ('a', 3, 5   )", "a: 1,3-5\nb: 1-10\nc: 1,3,5\n"    ],
	 ["unmark      ('a', 3      )", "a: 1,4-5\nb: 1-10\nc: 1,3,5\n"    ],
	 ["unmark_list ('b', [3..5] )", "a: 1,4-5\nb: 1-2,6-10\nc: 1,3,5\n"],
	 ["unmark_range('c', 5, 10  )", "a: 1,4-5\nb: 1-2,6-10\nc: 1,3\n"  ]);

    my $r1 = $test1[-1]->[1];

    my @test2 = 
	(["mark        ('d', 1    )",  $r1 . "d: 1\n"],
	 ["mark_list   ('e', [1,2])",  $r1 . "d: 1\ne: 1-2\n"],
	 ["mark_range  ('f', 3, 5 )",  $r1 . "d: 1\ne: 1-2\nf: 3-5\n"]);

    my $r2 = $test2[-1]->[1];

    my @test3 = 
	(["unmark      ('g', 1    )",  $r2 . "g: \n"],
	 ["unmark_list ('h', [1,2])",  $r2 . "g: \nh: \n"],
	 ["unmark_range('i', 3, 5 )",  $r2 . "g: \nh: \ni: \n"]);

    my $rc = new News::Newsrc;
    $rc->add_group('a');
    $rc->add_group('b');
    $rc->add_group('c');

    my $t;
    for $t (@test1, @test2, @test3)
    {
	my($op, $expected) = @$t;
	eval "\$rc->$op";
	my $result = $rc->_dump();
	my $message = "$op\n$result";
	die $message unless $result eq $expected;
	print $message if $Verbose > 1;
    }
}


sub test_predicates
{
    print "predicates\n" if $Verbose;

    my @test = 
	(["exists    ('a')    ", 1],
	 ["exists    ('b')    ", 1],
	 ["exists    ('e')    ", 0],
	 ["subscribed('a')    ", 1],
	 ["subscribed('b')    ", 0],
	 ["subscribed('e')    ", 0],
	 ["marked    ('a', 1 )", 1],
	 ["marked    ('a', 6 )", 0],
	 ["marked    ('b', 4 )", 1],
	 ["marked    ('c', 25)", 0],
	 ["marked    ('e', 1 )", 0],
	 ["exists    ('e')    ", 0]);

    my $rc = new News::Newsrc;
    $rc->_scan($TestRC);

    my $t;
    for $t (@test)
    {
	my($op, $expected) = @$t;
	my $result = eval "\$rc->$op";
	my $message = "$op -> $result\n";
	die $message if $result xor $expected;
	print $message if $Verbose > 1;
    }
}


sub test_lists
{
    print "lists\n" if $Verbose;

    my @test = 
	(["groups                      ", "a b c d f"],
	 ["sub_groups                  ", "a c d"    ],
	 ["unsub_groups                ", "b f"      ],
	 ["marked_articles  ('a')      ", "1 2 3 4 5"],
	 ["marked_articles  ('x')      ", ""         ],
	 ["unmarked_articles('a', 1, 9)", "6 7 8 9"  ],
	 ["unmarked_articles('y', 3, 5)", "3 4 5"    ]);

    my $rc = new News::Newsrc;
    $rc->_scan($TestRC);

    my $t;
    for $t (@test)
    {
	my($op, $expected) = @$t;
	my @result = eval "\$rc->$op";
	my $result = join(' ', @result);
	my $message = "$op -> $result\n";
	die $message unless $result eq $expected;
	print $message if $Verbose > 1;
    }

    $rc->_scan($TestRC);

    for $t (@test)
    {
	my($op, $expected) = @$t;
	my $result = eval "\$rc->$op";
	my $result = join(' ', @$result);
	my $message = "$op -> $result\n";
	die $message unless $result eq $expected;
	print $message if $Verbose > 1;
    }
}
