package AnnotationDefinition;
use Data::Dumper;
#/**
# * Represent the definition of an annotation (score or property). An annotation is defined by an identifier and
# * a description. Scores and properties can can assigned to groups or to genes in context of the membership
# * to a certain group.
# * 
# * @author Thomas Schmitt
# * 
# */

sub new
{
    my $class = shift;
    my $self = {
        _name => shift,
        _description  => shift,
    };
    # Print all the values just for clarification.
    #print "species is $self->{_name}\n";
    #print "database is $self->{_description}\n";
   
    bless $self, $class;
    return $self;
}

sub getName {
      my ( $self) = (@_);       
      #print Dumper $self;
    return $self->{_name};
}

sub getDescription {
      my ( $self) = (@_);       
    return $self->{_description};
}

sub hashCode
{
        my ( $self) = (@_); 
        if(!defined($self->{'_name'})){
                return 31;
        }
        else
        {
                die "ask thomas about name.hashCode\n";
        }
        
}

	#@Override
	#/**
	# * Two AnnotationDefinitions are equal if they have the same name. 
	# * @return true if the objects are equal.
	# */
sub equals() {
        my ( $self, $obj) = (@_); 
        if(refaddr($self) == refaddr($obj) ){ return 1;}
        if(!defined($obj)){ return 0;}
        
        
	#	if (this == obj)
	#		return true;
	#	if (obj == null)
	#		return false;
	#	if (getClass() != obj.getClass())
	#		return false;
	#	AnnotationDefinition other = (AnnotationDefinition) obj;
	#	if (name == null) {
	#		if (other.name != null)
	#			return false;
	#	} else if (!name.equals(other.name))
	#		return false;
	#	return true;
	#}
        	return 1;

}
1;