use sbc::orthoxml::Database;
use sbc::orthoxml::Gene;
use sbc::orthoxml::Group;
use sbc::orthoxml::Species;
use sbc::orthoxml::Membership;
use sbc::orthoxml::io::OrthoXMLReader;
use sbc::orthoxml::io::OrthoXMLWriter;
use warnings;
use strict;
use Data::Dumper;

#create Database class instance
my $db = new Database( 'OMA', '1.4' );
my $gene = new Gene( 'Homo_sapiens', 'OMA' );
my $species = new Species( '3716', 'Homo_sapiens' );

my $xmlTestFile = "orthoxml_example_v0.4.xml";
my $reader      = OrthoXMLReader->new($xmlTestFile);



READING:

#print Dumper $reader;
#exit;
# read the group iteratively
#Group group;
my $writer = OrthoXMLWriter->new( "myDatabase_Mar_2011.xml", $reader->getOrigin(), $reader->getOriginVersion() );

while ( ( defined( my $group = $reader->next() ) ) )
{
    print "found a group?\n";
    if ( !defined($group) )
    {
        print "\tempty group\n";
    }
    #print Dumper $group;
    print "#" . $group->getId() . "\n";
    print "\t\tnow collecting genes\n";
    foreach my $gene ( $group->getNestedGenes() )
    {
        print "\t" . $gene->getProteinIdentifier . "\n";
    }
    #print Dumper $group;

    #exit;
    $writer->write($group);
}
$writer->close;


print "\tfinished orthoxml groups\n";
exit;

Writing:

#//open a new file for writing
	$writer =
  OrthoXMLWriter->new( "myDatabase_Mar_2011.xml", $reader->getOrigin(),
    $reader->getOriginVersion() );

#//create a ortholog group
my $group = Group->new();
$group->setId("42");

#//create species
my $human = Species->new( 9606, "Homo sapiens" );
my $mouse = Species->new( 9606, "Mus musculus" );

#//create a database
my $ensemblDB = Database->new( "Ensembl", "56" );

#//create genes
my $humanGene = Gene->new( $human, $ensemblDB );
$humanGene->setGeneIdentifier("ENSG00000197102");
my $mouseGene = Gene->new( $mouse, $ensemblDB );
$mouseGene->setGeneIdentifier("ENSMUSG00000018707");

#//add genes to the ortholog group
$group->setGenes( ( $humanGene, $mouseGene ) );

#//write the ortholog group
$writer->write($group);

#//complete the writing
#//NEVER forget to do this!
$writer->close();

