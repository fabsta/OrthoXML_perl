package Group;
=head1 NAME

Sbc::orthoxml::Group - Container of taxon objects

=head1 SYNOPSIS

 use sbc::orthoxml::Species;
 my $group = Group->new();

 
=head1 DESCRIPTION

The group class represents a group of orthologous or paralogous genes
depending on its type. Groups can be nested to represent trees. Multiple
scores can be assigned to the group and each gene in the group. Genes are
encapsulated into {@link sbc.orthoxml.Membership} objects that hold the gene and scores for the
gene.

=head1 METHODS

=head2 CONSTRUCTOR


=cut

use sbc::orthoxml::Annotateable;
use constant ORTHOLOG => 1;
use constant PARALOG => 2;

@EXPORT_OK = qw(ORTHOLOG PARALOG);
@ISA = qw ( Annotateable );

=over 4

=item new()

Group constructor.

 Type    : Constructor
 Title   : new
 Usage   : my $taxa = SBC::Orthoxml::Group->new;
 Function: Instantiates a SBC::Orthoxml::Group object.
 Returns : A SBC::Orthoxml::Membership object.
 Args    : gene the gene to be nested in the Membership


=back

=back

=cut
sub new
 {
     my $class = shift;
     my $self = {
         _id => undef,
         _type  => 1, # Hack 1 = Ortholog, 2 = Paralog
         _members => undef,
         _children => undef,
         _parent => undef,
     };
     bless $self, $class;
     return $self;
 } 

=over

=item getNestedGenes()

Membership constructor.

 Type    : Constructor
 Usage   : my $group->getNestedGenes;
 Function: Returns the gene nested in the membership.
 Returns : A SBC::Orthoxml::Gene object.

=back

=cut
sub getNestedGenes {
             my ( $self) = (@_);       
             my @genes;
             #print "\tgetting nested genes for ".$self->{_id}."\n";
             my @memberships = $self->getNestedMembers();
                     #print "\tfound ".scalar(@memberships)." memberships\n";
             foreach my $group ($self->getNestedMembers()){
                     #print "\titerate over membership: \n";
                     push(@genes,$group->getGene());
                     #print "\tlist genes!\n";
                     #print Dumper @genes;

             }
             return @genes;
  }

=over

=item getNestedMembers()

Membership constructor.

 Type    : Method
 Usage   : my $group->getNestedMembers;
 Function: Convenience method to get all memberships of the group and of groups that are nested into the group.
 Returns : memberships of the group of nested groups.

=back

=cut
sub getNestedMembers
{
        my ( $self, $membersref) = (@_); 
        my @nestedMembers;
        #print "\tgetting nested Members\n";

        if(scalar(@_) < 2){
              #print "\tnot defined, array address is ".\@nestedMembers."\n";
              
              $self->getNestedMembers(\@nestedMembers);  
              #print "got Members, now has ".scalar(@nestedMembers)." elements\n";
              #print "\tnow returning everything\n";
              #print Dumper @nestedMembers;
              return @nestedMembers;
        }
        
        if(scalar(@{$self->{_members}}))
        {
                #print "\twell, has members, adding to address $membersref\n";
                #return @{$self->{_members}};
                foreach(@{$self->{_members}})
                {
                        #print "\tadding $_\n";
                        push(@{$membersref},$_);
                }
                #print "\tdone adding, array has ".scalar(@{$membersref})." elements\n"
        }
        if(scalar(@{$self->{_children}}))
        {
                #print "\t\thas children, adding to address $membersref \n";
                #return @{$self->{_children}};
                foreach my $child(@{$self->{_children}}){
                        #print "\t\t\tcalling children's members, array has address $membersref\n";
                        $child->getNestedMembers($membersref);
                }
        }
        #print "\tnow returning \n";
        #print Dumper $membersref;
}

=over

=item getParent()

Membership constructor.

 Type    : Method
 Usage   : my $group->getParent;
 Function: Returns the parent of group e.g. the group this group is nested in.
 Returns : the parent or null if none.

=back

=cut
sub getParent
{
        my ( $self) = (@_); 
        return $self->{'_parent'};
}

=over

=item setChildren()

Membership constructor.

 Type    : Method
 Usage   : my $group->setChildren;
 Function: Sets the children (nested groups) of the group.
 Args    : the children to set.

=back

=cut
sub setChildren
{
        my ( $self, @children) = (@_);
        @{$self->{_children}} = @children;
        #print "checking setting children\n";
        #print Dumper $self->{_children};
        if(!scalar(@children)){
                ;#print "\t no children\n";
        }
        #exit;
        if(scalar(@children)){
                foreach my $child(@children){
                        #print "setting parent of child to self\n";
                        $child->setParent($self);
                }
        }
}

=over

=item getChildren()

Membership constructor.

 Type    : Method
 Usage   : my $group->getChildren;
 Function: Returns the children (nested groups) of the group.
 Args    : the children.

=cut
sub getChildren
{
        my ( $self) = shift;
        if(!defined($self->{_children}) || !scalar(@{$self->{_children}})){
                return ();
        }
        return @{$self->{_children}};
}

=over

=item setGenes()

Membership constructor.

 Type    : Method
 Usage   : my $group->setMembers;
 Function: Sets the genes that are members of group as {@link Membership} objects.
 Args    : members the members of the group.

=cut
sub setMembers
{
        my ( $self, @members) = (@_);
        foreach(@members){
                push(@{$self->{_members}},$_);
        }
}

=over

=item setGenes()

Membership constructor.

 Type    : Constructor
 Usage   : my $group->setGenes;
 Function: Convenience method to set gene members without a score.
 Args    : genes the gene members of the group.

=cut
sub setGenes
{
        my ( $self, @genes) = (@_);
        foreach my $gene(@genes){
                push(@{$self->{_members}},Membership->new($gene));
        }
} 

=over

=item getGenes()

Membership constructor.

 Type    : Constructor
 Usage   : my $group->getGenes;
 Function: Convenience method to get all genes that are a member of the group 
 		   without the membership nesting. Use @{link #getNestedGenes()} to get all
		   gene in the group and in the children of the group.
 Returns : the gene members of the group.

=cut
sub getGenes
{
        my ( $self) = shift;
        
        if(!scalar(@{$self->{_members}}))
        {
                return ();
        }
        my @genes;
        foreach my $member(@{$self->{_members}})
        {
              push(@{$self->{_members}}, $member->getGene()); 
        }
        return @genes;
}

=over

=item getMembers()

Membership constructor.

 Type    : Constructor
 Usage   : my $group->getMembers;
 Function: Returns the genes that a member of the group nested into
 	 		* {@link sbc.orthoxml.Membership} objects. Use @{link #getNestedMembers()} to get all
 	 		* members in the group and in the children of the group.
 Returns : the memberships of the group.

=back

=cut
sub getMembers
{
        my ( $self) = shift;
        
        if(!scalar(@{$self->{_members}}))
        {
                return ();
        }
        return @{$self->{_members}};
}

=over

=item setType()

Membership constructor.

 Type    : Method
 Usage   : my $group->setType;
 Function: Sets the type of the group.
 Returns : the type to set.

=back

=cut
sub setType
{
        my ( $self, $type) = (@_);
        $self->{'_type'} = $type;
}

=over

=item getType()

Membership constructor.

 Type    : Method
 Usage   : my $group->getType;
 Function: Returns the type of the group.
 Returns : the type of the group.

=back

=cut
sub getType(){
        my ( $self) = (@_);
        return $self->{'_type'};
}

=over

=item setParent()

Membership constructor.

 Type    : Method
 Usage   : my $group->setParent;
 Function: Sets the parent of the group.
 Args    : The parent to set.

=back

=cut
sub setParent{
        my ( $self, $parent) = (@_);
        $self->{'_parent'} = $parent;
}

=over

=item setId()

Membership constructor.

 Type    : Method
 Usage   : my $group->setId;
 Function: Sets the id of the group.
 Args    : id the id to set
 
=back

=cut
sub setId(){
        my ( $self, $id) = (@_);
        $self->{'_id'} = $id;
}

=over

=item getGene()

Membership constructor.

 Type    : Method
 Usage   : my $group->getId;
 Function: Returns the id of the group.
 Returns : the ID

=back

=cut
sub getId
{
        my ( $self) = (@_);
        return $self->{'_id'};
}

=over

=item clearAllScores()

Membership constructor.

 Type    : Method
 Usage   : my $group->clearAllScores;
 Function: Removes the scores of the group, of all nested groups and of the members the group and nested groups.
 Returns : 

=back

=cut
sub clearAllScores{
      my ( $self) = (@_);
      foreach my $member(@{$self->{_members}})
      {
              $member->clearScores();
      }   
      foreach my $child(@{$self->{_children}})
      {
              $child->clearAllScores();
      }   
      
}

=over

=item getGene()

Membership constructor.

 Type    : Method
 Usage   : my $group->clearAllProperties;
 Function: Removes the properties of the group, of all nested groups and of the members the group and nested groups..
 Returns : 

=back

=cut
sub clearAllProperties{
       my ( $self) = (@_);
       foreach my $member(@{$self->{_members}})
             {
                     $member->clearProperties();
             }   
             foreach my $child(@{$self->{_children}})
             {
                     $child->clearAllProperties();
             } 
}

1;