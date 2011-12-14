=head1 NAME

Sbc::orthoxml::Species - Container of taxon objects

=head1 SYNOPSIS

 use sbc::orthoxml::Species;
 my $fac = Species->new();

        my $reader = OrthoXMLReader->(myFile);
 	my $group = $reader->next();
 
 	my %scoreDefinitions = $reader->getScoreDefinitions();
 
 	for (Membership member : group.getMembers()) {
 		//accessing the gene
 		Gene gene = member.getGene();
 		//accessing the scores that are assigned to gene
 		List&lt;Double&gt; scores = member.getScore(scoreDefinitions
 				.get(&quot;myGeneScore&quot;));
 	}

 
=head1 DESCRIPTION

The membership class represents a group membership of gene. The same gene object can be in multiple groups. The membership encapsulation allows to
 assign different scores to same gene depending on the group.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=cut
package Membership;
use sbc::orthoxml::Annotateable;
use strict;
our @ISA = qw ( Annotateable );   # inherits from Person
#/**
# * The membership class represents a group membership of gene. The same gene
# * object can be in multiple groups. The membership encapsulation allows to
# * assign different scores to same gene depending on the group.
# * 
# * <pre>
# * {
# * 	&#064;code
# * 	OrthoXMLReader reader = new OrthoXMLReader(myFile);
# * 	Group group = reader.next();
# * 
# * 	Map&lt;String, ScoreDefinition&gt; scoreDefinitions = reader
# * 			.getScoreDefinitions();
# * 
# * 	for (Membership member : group.getMembers()) {
# * 		//accessing the gene
# * 		Gene gene = member.getGene();
# * 		//accessing the scores that are assigned to gene
# * 		List&lt;Double&gt; scores = member.getScore(scoreDefinitions
# * 				.get(&quot;myGeneScore&quot;));
# * 	}
# * }
# * </pre>
# * 
# * @author Thomas Schmitt
# * 
# */

{

=over

=item new()

Membership constructor.

 Type    : Constructor
 Title   : new
 Usage   : my $taxa = SBC::Orthoxml::Membership->new;
 Function: Instantiates a SBC::Orthoxml::Membership object.
 Returns : A SBC::Orthoxml::Membership object.
 Args    : gene the gene to be nested in the Membership

=cut
      sub new {
            my $class = shift;
            my $self = {
                  _gene => shift,
            };
            # Print all the values just for clarification.
            #print "gene is $self->{_gene}\n";
            bless $self, $class;
            return $self;
      }
=over

=item getGene()

Membership constructor.

 Type    : Constructor
 Usage   : my $membership->getGene;
 Function: Returns the gene nested in the membership.
 Returns : A SBC::Orthoxml::Gene object.

=cut
      sub getGene {
            my ( $self) = (@_);       
            return $self->{_gene};
      }

}
1;