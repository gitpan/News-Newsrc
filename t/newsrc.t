# -*- perl -*-
# $Id: newsrc.t,v 1.1 1996/08/15 03:42:33 swm Exp swm $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN {print "1..60\n";}
END {print "not ok 1\n" unless $loaded;}
use News::Newsrc;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

#GLOBALS
my $Verbose;
my @Test_files = qw(newsrc .newsrc newsrc.bak .newsrc.bak);
my $N = 2;

my $TestRC = <<RC;
a: 1-5
b! 3-8,15,20
c: 20-21,33,38
d: 1,3,7
f!
RC


$ENV{HOME} = '.';

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

unlink @Test_files;


sub test_load
{
    print "#load\n";

    my @test = ([".newsrc", "a: 1,3\n\n", ""          , 1 , "a: 1,3\n" ],
		["newsrc" , "b! 1-10\n ", "newsrc"    , 1 , "b! 1-10\n"],
		[""       , ""          , "newsrc.bak", "", ""         ]);

    my $t;
    my $rc = new News::Newsrc;

    unlink @Test_files;
    for $t (@test)
    {
	my($write_file, $contents, $load_file, $e_return, $e_dump) = @$t;
	write_file($write_file, $contents);
	my $return = $rc->load($load_file);
	my $dump = $rc->_dump();
	printf("#%-12s %s -> %s: %s\n", 
	       "load($load_file)", $contents, $return, $dump);
	print "not " unless $return eq $e_return and $dump eq $e_dump;
	print "ok ", $N++, "\n";
    }
}


sub test_load_errs
{
    print "#load errors\n";

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
	printf("#%-12s %-10s -> %s", "load", $contents, $@);
	print "not " if $return or  $@ !~ /$error/;
	print "ok ", $N++, "\n";
    }
}


sub test_save
{
    print "#save\n";

    unlink @Test_files;
    my $rc = new News::Newsrc;
    my $scan ="a: 1,3\n";
    $rc->_scan($scan);
    $rc->save();
    my $read = read_file('.newsrc');
    printf("#%-12s %-20s -> %s", "save", $scan, $read);
    print "not " unless $scan eq $read;
    print "ok ", $N++, "\n";
}


sub test_save_bak
{
    print "#save_bak\n";
    unlink @Test_files;
    my $rc = new News::Newsrc;

    $rc->save();
    my $result = -e '.newsrc.bak';
    printf("#%-12s %-20s -> %d\n", "save", "", $result);
    print "not " if $result;
    print "ok ", $N++, "\n";

    $rc->save();
    my $result = -e '.newsrc.bak';
    printf("#%-12s %-20s -> %d\n", "save", "", $result);
    print "not " unless $result;
    print "ok ", $N++, "\n";
}


sub test_save_load
{
    print "#save_load\n";
    my $rc = new News::Newsrc;

    write_file('newsrc', '');
    $rc->load('newsrc');
    unlink @Test_files;
    $rc->save();

    my $result = -e 'newsrc';
    printf("#%-12s %-20s -> %d\n", "save", "", $result);
    print "not " unless $result;
    print "ok ", $N++, "\n";
}


sub test_save_as
{
    print "#save_as\n";
    my $rc = new News::Newsrc;

    unlink @Test_files;
    $rc->save_as('newsrc');
    my $result = -e 'newsrc';
    printf("#%-12s %-20s -> %d\n", "save", "", $result);
    print "not " unless $result;
    print "ok ", $N++, "\n";

    unlink @Test_files;
    $rc->save();
    my $result = -e 'newsrc';
    printf("#%-12s %-20s -> %d\n", "save", "", $result);
    print "not " unless $result;
    print "ok ", $N++, "\n";
}


sub test_groups
{
    print "#groups\n";

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
	print "#$op($operand)\n$result";
	print "not " unless $result eq $expected;
	print "ok ", $N++, "\n";
    }
}


sub test_marks
{
    print "#marks\n";

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
	print "#$op\n$result";
	print "not " unless $result eq $expected;
	print "ok ", $N++, "\n";
    }
}


sub test_predicates
{
    print "#predicates\n";

    my @test = 
	(["exists",     ['a'    ], 1],
	 ["exists",     ['b'    ], 1],
	 ["exists",     ['e'    ], 0],
	 ["subscribed", ['a'    ], 1],
	 ["subscribed", ['b'    ], 0],
	 ["subscribed", ['e'    ], 0],
	 ["marked",     ['a', 1 ], 1],
	 ["marked",     ['a', 6 ], 0],
	 ["marked",     ['b', 4 ], 1],
	 ["marked",     ['c', 25], 0],
	 ["marked",     ['e', 1 ], 0],
	 ["exists",     ['e'    ], 0]);

    my $rc = new News::Newsrc;
    $rc->_scan($TestRC);

    my $t;
    for $t (@test)
    {
	my($op, $args, $expected) = @$t;
	my $result = $rc->$op(@$args);
	print "#$op(@$args) -> $result\n";
	print "not " if $result xor $expected;
	print "ok ", $N++, "\n";
    }
}


sub test_lists
{
    print "#lists\n";

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
	print "#$op -> $result\n";
	print "not " unless $result eq $expected;
	print "ok ", $N++, "\n";
    }

    $rc->_scan($TestRC);

    for $t (@test)
    {
	my($op, $expected) = @$t;
	my $result = eval "\$rc->$op";
	my $result = join(' ', @$result);
	print "#$op -> $result\n";
	print "not " unless $result eq $expected;
	print "ok ", $N++, "\n";
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

