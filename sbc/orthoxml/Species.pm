package Species;
=head1 NAME

Sbc::orthoxml::Species - Container of taxon objects

=head1 SYNOPSIS

 use sbc::orthoxml::Species;
 my $fac = Species->new();

 
=head1 DESCRIPTION

Represents a species in the context of orthology assignment.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=cut

{


=item new()

 Species constructor.

  Type    : Constructor
  Title   : new
  Usage   : my $taxa = SBC::Orthoxml::Species->new;
  Function: Instantiates a SBC::Orthoxml::Species object.
  Returns : A SBC::Orthoxml::Species object.
  Args    : taxId the <a href="http://www.ncbi.nlm.nih.gov/Taxonomy">NCBI taxonomy</a> identifier of the species
            name the (scientific) name of the species.

=cut

sub new {
            my $class = shift;
            my $self = {
                  _ncbiTaxId => shift,
                  _name  => shift,
            };
            # Print all the values just for clarification.
            #print "taxID is $self->{_taxId}\n";
            #print "name is $self->{_name}\n";
            bless $self, $class;
            return $self;
}

=item getName()

Returns the name of the species.

 Title   : getName
 Usage   : $species->getName();
 Returns : the name of the species.

=cut

sub getName
{
        my ( $self) = (@_);       
        return $self->{_name};
}

=item getNcbiTaxId()

Returns the NCBI taxonomy ID of the species.

 Title   : getNcbiTaxId
 Usage   : $species->getNcbiTaxId();
 Returns : the NCBI taxonomy identifier.

=cut

sub getNcbiTaxId 
{
        my ( $self) = (@_);       
        return $self->{_ncbiTaxId};
}

sub hashCode
{
        my ( $self) = (@_);       
        my $prime = 31;
        my $result = 1;
        $result = $prime * (!defined($self->{_name})? 0 : $self->hashCode());
        $result = $prime * (!defined($self->{_ncbiTaxId})? 0 : $self->hashCode());
}
#	@Override
#	public int hashCode() {
#		final int prime = 31;
#		int result = 1;
#		result = prime * result + ((name == null) ? 0 : name.hashCode());
#		result = prime * result + ((ncbiTaxId == null) ? 0 : ncbiTaxId.hashCode());
#		return result;
#	}


#	@Override
#	public boolean equals(Object obj) {
#		if (this == obj)
#			return true;
#		if (obj == null)
#			return false;
#		if (getClass() != obj.getClass())
#			return false;
#		Species other = (Species) obj;
#		if (name == null) {
#			if (other.name != null)
#				return false;
#		} else if (!name.equals(other.name))
#			return false;
#		if (ncbiTaxId == null) {
#			if (other.ncbiTaxId != null)
#				return false;
#		} else if (!ncbiTaxId.equals(other.ncbiTaxId))
#			return false;
#		return true;
#	}
	
	
}
1;