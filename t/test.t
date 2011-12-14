use Test::More tests => 12;

use_ok( 'sbc::orthoxml::Database' ); 
require_ok( 'sbc::orthoxml::Database' );

use_ok( 'sbc::orthoxml::Gene' ); 
require_ok( 'sbc::orthoxml::Gene' );

use_ok( 'sbc::orthoxml::Group' ); 
require_ok( 'sbc::orthoxml::Group' );

use_ok( 'sbc::orthoxml::Species' ); 
require_ok( 'sbc::orthoxml::Species' );

use_ok( 'sbc::orthoxml::io::OrthoXMLReader' ); 
require_ok( 'sbc::orthoxml::io::OrthoXMLReader' );

use_ok( 'sbc::orthoxml::io::OrthoXMLWriter' ); 
require_ok( 'sbc::orthoxml::io::OrthoXMLWriter' );


# Do some tests

my $xmlTestFile = "orthoxml_example_v0.4.xml";

my $reader      = OrthoXMLReader->new($xmlTestFile);

my $group = $reader->next();

ok( ( $group->getId() == 1 ),
	" correct group attribute." );

