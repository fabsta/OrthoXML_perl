package OrthoXMLReader;
use warnings;
use strict;
use Data::Dumper;
use XML::LibXML;
use XML::LibXML::Reader;
use sbc::orthoxml::Database;
use sbc::orthoxml::Gene;
use sbc::orthoxml::Group;
use sbc::orthoxml::Species;
use sbc::orthoxml::Membership;
use sbc::orthoxml::io::OrthoXMLNames;
use sbc::orthoxml::AnnotationDefinition;
#import java.util.ArrayList;
#import java.util.HashMap;
#import java.util.HashSet;
#import java.util.List;
#import java.util.Map;
#import java.util.Set;

#/**
# * The group class represents a group of orthologous or paralogous genes
# * depending on its type. Groups can be nested to represent trees. Multiple
# * scores can be assigned to the group and each gene in the group. Genes are
# * encapsulated into {@link sbc.orthoxml.Membership} objects that hold the gene and scores for the
# * gene.
# * 
# * @author Thomas Schmitt
# * 
# */

{
#sub new(){
#	my ( $self, @args ) = @_;
	#init(orthoXMLStream);
#}

# Reading from a file
sub new()
{
        #print Dumper @_;
        my ( $self, $file ) = @_;
        my $objref = {
                _streamReader => undef,
                _taxonomyFilter  => undef,
                _namespace       => undef,
                _groupsTag   => undef,
                _orthologGroupTag   => undef,
                _scoreDefinitions   => undef,
                _propertyDefinitions => undef,
                _geneList => undef,
                _speciesList   => undef,
                _origin   => undef,
                _version   => undef,
                _originVersion   => undef,
                _taxIdSet   => undef,
            };

            # Initialize reader
            if(-e $file && -s $file){
                    $objref->{'_streamReader'} = XML::LibXML::Reader->new(location => "$file") or die "cannot read xml file $file\n";
            }
            else{
                    die "cannot read xml file $file\n";
            }
            if ( !$objref->{'_streamReader'} ) {
                    $objref->throw("XML::LibXML::Reader not initialized");
            }
            bless $objref, $self;
            
            print "reading file descriptions\n";
			$objref->readFileDescription();
			print "reading global descriptions\n";

			$objref->readGlobalDefinitions();
			print "done\n";
	    return $objref;
}



#/**
# * Reads the file version origin and origin version. 
# * Sets version specific tag names and the picks the name space for the file.
# * 
# * @param createXMLStreamReader
# * @throws XMLStreamException 
# */

sub getOrigin
{
        my ( $self ) = shift;
        return $self->{_origin};
}

sub getVersion
{
        my ( $self ) = shift;
        return $self->{_version};
}

sub getOriginVersion
{
        my ( $self ) = shift;
        return $self->{_originVersion};
}

sub readFileDescription()
{
        my ( $self ) = shift;
	#print "read File description...\n";
	my $rootTag = $self->nextOrthoXMLTag('orthoXML');
        $self->{_version} = $rootTag->getAttribute(OrthoXMLNames::ORTHOXML_VERSION_ATTR);
	$self->{_origin} = $rootTag->getAttribute(OrthoXMLNames::ORTHOXML_ORIGIN_ATTR);
	$self->{_originVersion} = $rootTag->getAttribute(OrthoXMLNames::ORTHOXML_ORIGINVERSION_ATTR());
	#print Dumper $self;
}

sub readGlobalDefinitions{
        my ( $self ) = shift;
        my $elem = Element->new();
        my $speciesTag = OrthoXMLNames::SCORE_DEFS_TAG;
        my $counter = 0;
        while((defined($elem = $self->nextOrthoXMLTag())) &&  ($elem->getName() ne OrthoXMLNames::GROUPS_TAG))
        {
                        my $name = $elem->getName();
                        #print "\t--> non-groupTag for $name\n";
                        #die "enough" if $counter++ > 1;
                        if($elem->getType() == XML_READER_TYPE_ELEMENT)
		        {
		                if($name eq OrthoXMLNames::SPECIES_TAG)
		                {
		                        #print "reading species\n";
		                        $self->readSpecies($elem);
		                }
		                elsif($name eq OrthoXMLNames::SCORE_DEF_TAG)
		                {
		                        #print "reading ScoreDefinition\n";
		                        $self->readScoreDefinition($elem);
		                }
		                elsif($name eq OrthoXMLNames::PROPERTY_DEF_TAG && $self->{_version} > 0.3)
		                {
		                        #print "reading PropertyDefinition\n";
		                        $self->readPropertyDefinition($elem);
		                }
	                }
        }
        return 1;
}

sub nextOrthoXMLTag
{
        my ( $self, $type) = shift;
        #print Dumper @_;
	my $elem = Element->new;
	#my $type;
	#print "type is $type\n";
	my %parameterHash;
	my $reader = $self->{'_streamReader'};
	#print "\treading next OrthoXMLTag\n";
        while($reader->read) {
               #print "\t\t\tname: ".$reader->name." nodeType: ".$reader->nodeType." equals Start:".XML_READER_TYPE_ELEMENT." or End:".XML_READER_TYPE_END_ELEMENT."\n";
               if ( $reader->nodeType == XML_READER_TYPE_ELEMENT || $reader->nodeType == XML_READER_TYPE_END_ELEMENT) {
                       #print "\t\tright type ".$reader->name." eq $type\n";
                       if(!defined($type) || $reader->name eq $type)
                       {
                               # just read the header
                                      #print "\tdepth: ".$reader->depth."\n";
                                      #print "\tnodeType: ".$reader->nodeType."\n";
                                      #print "\tname: ".$reader->name."\n";
                                      #print "\tvalue: ".$reader->value;
                                      #print "\tisEmypy?: ".$reader->isEmptyElement."\n";
                                      #print "\tnamespaceURI: ".$reader->namespaceURI."\n";
                                      #print "\treadInnerXml: ".$reader->readInnerXml."\n";
                                      #print "\tattributeCount: ".$reader->attributeCount."\n";                ## skip notes elements
			    	if($reader->name eq  OrthoXMLNames::NOTE_TAG)
		    		{
			    		my $level = 1;
			    		#while($reader->read && $level > 0)
			    		#{
			    			#type = streamReader.next();
			    			
			    			## Everything is allowed in notes elements so multiple notes could be nested
			    			#if(qnameTag.getLocalPart().equals(orthoXMLNames.NOTE_TAG) && type == XMLStreamConstants.END_ELEMENT)
			    			#	level-=1;
			    			#else if(qnameTag.getLocalPart().equals(orthoXMLNames.NOTE_TAG) && type == XMLStreamConstants.START_ELEMENT)
			    			#	level+=1;
			    		#}
			    		#print "\t\tignoring notes \n";
		    			next;
		    		}
		    		else
		    		{
                                        $elem->setName($reader->name);
                                        $elem->setType($reader->nodeType);
                                        
                                        if ( $reader->nodeType == XML_READER_TYPE_ELEMENT)
                                        {
                                                while($reader->moveToNextAttribute){
                                                        #print $reader->name."\t";
                                                        #print $reader->value."\n";
                                                        $elem->addAttribute($reader->name,$reader->value); 
                                                }
                                        }
                                        return $elem;
                                }
                        }
               }
       }
       return undef;
}


sub readSpecies{
        my ($self,$elem) = (@_);
        my $species;
        my $database;
        my $taxID = $elem->getAttribute(OrthoXMLNames::TAX_ID_ATTR);
        
        if(!keys(%{$self->{'_taxonomyFilter'}}) || exists $self->{'_taxonomyFilter'}{$taxID})
        {
                $species = Species->new($taxID,$elem->getAttribute(OrthoXMLNames::SPECIES_NAME_ATTR));
                push(@{$self->{'_speciesList'}},$species);
        }
        my $child = Element->new();
        while(defined($child = $self->nextOrthoXMLTag()))
        {
                my $name = $child->getName;
                if($child->getType eq XML_READER_TYPE_ELEMENT && defined($species))
                {
                        if($name eq OrthoXMLNames::GENE_TAG)
                        {
                                 $self->readGene($child, $database, $species);
                        }
                        elsif($name eq OrthoXMLNames::DATABASE_TAG)
                        {
                                $database = $self->readDatabase($child);
                        }
                }
                        elsif($child->getType == XML_READER_TYPE_END_ELEMENT && $name eq $elem->getName())
                        {
                                last;
                        }
        }
}

sub readDatabase()
{
        my ($self,$elem) = (@_);
        my $database = Database->new($elem->getAttribute(OrthoXMLNames::DATABASE_NAME_ATTR),$elem->getAttribute(OrthoXMLNames::DATABASE_VERSION_ATTR) );
        $database->setGeneLink($elem->getAttribute(OrthoXMLNames::DATABASE_GENE_LINK_ATTR));
        $database->setTranscriptLink($elem->getAttribute(OrthoXMLNames::DATABASE_TRANSCRIPT_LINK_ATTR));
        $database->setProtLink($elem->getAttribute(OrthoXMLNames::DATABASE_PROTEIN_LINK_ATTR));
        #print Dumper $database;
        #exit;
        return $database;
}

#/**
# * Reads a gene.
# * 
# * @param elem
# * @param database
# * @param species
# */
sub readGene(){
        my ($self,$elem, $database, $species) = (@_);
        my $gene = Gene->new($species, $database);
        $gene->setProteinIdentifier($elem->getAttribute(OrthoXMLNames::GENE_PROT_ID_ATTR));
        $gene->setGeneIdentifier($elem->getAttribute(OrthoXMLNames::GENE_GENE_ID_ATTR));
        $gene->setTranscriptIdentifier($elem->getAttribute(OrthoXMLNames::GENE_TRANSCRIPT_ID_ATTR));
        my $geneId =  $elem->getAttribute('id');
        $self->{_geneList}{$geneId} = $gene;
}

sub readScoreDefinition()
{
        my ($self,$elem) = (@_);
        #print Dumper $elem;
        #exit;
	my $scoreId = $elem->getAttribute(OrthoXMLNames::SCORE_DEF_ID_ATTR);
	if(!defined($scoreId) || $scoreId eq '')
	{
	        die "Score name is missing.\n";
	} 
	if(exists $self->{'scoreDefinitions'}{$scoreId})
	{
	        die "Score name duplicated.\n";
	}
	my $annotationDefinition = AnnotationDefinition->new($scoreId, $elem->getAttribute(OrthoXMLNames::SCORE_DEF_DESCRIPTION_ATTR));
	$self->{_scoreDefinitions}{$scoreId} = $annotationDefinition;
        #print Dumper $annotationDefinition;
        #exit;
        #AnnotationDefinition annotationDefinition = new AnnotationDefinition(scoreId,elem.getAttribute(orthoXMLNames.getScoreDefDescriptionAttr()));
	#scoreDefinitions.put(scoreId, annotationDefinition);
        #exit;
}


sub init(){
	#XMLInputFactory f = XMLInputFactory.newInstance();
	#streamReader = f.createXMLStreamReader(new BufferedReader(orthoXMLStream));
        readFileDescription();
	readGlobalDefinitions();
}


#/**
# * Returns the next group top level ortholog group from the OrthoXML
# * file/stream. If the Reader was constructed with an NCBI taxonomy filter,
# * only groups that contain genes from at least two of this species are
# * returned. Empty groups are removed recursively from the tree.
# * 
# * 
# * @return the next top level group read or null if finished.
# * @throws XMLStreamException
# * @throws TransformerException 
# * @throws NumberFormatException 
# */

sub next()
{
        my ($self,$elem) = (@_);
        my $reader = $self->{'_streamReader'};
	#print "\treading next group\n";
        while($reader->read) {
                while(defined(my $elem = $self->nextOrthoXMLTag)){
                        #print "\tread element:\n";
                        #print Dumper $elem;
                        #exit;
                        #print "\tchecking what to read ".$elem->getType." == ".XML_READER_TYPE_ELEMENT." && ".$elem->getName()." eq ".OrthoXMLNames::ORTHOLOG_GROUP_TAG."\n"; 
                        if($elem->getType == XML_READER_TYPE_ELEMENT && $elem->getName() eq OrthoXMLNames::ORTHOLOG_GROUP_TAG)
                        {
                                #print "\tequals tag: ".OrthoXMLNames::ORTHOLOG_GROUP_TAG."\n";
                                #taxIdSet.clear();
				#Group group = readGroup(elem,taxIdSet);
                                @{$self->{'taxIdSet'}} = ();
                                #print "\t\t\treading group \n";
                                #print Dumper $elem;
                                my $group = $self->readGroup($elem,@{$self->{'taxIdSet'}});
                                #print "\t\t\tfinished reading group\n";
                                #print Dumper $group;
                                if(defined($group)){
                                        #print "\t\tgroup is defined\n";
                                        $group->setType(Group::ORTHOLOG);
                                        if(!keys(%{$self->{'_taxonomyFilter'}}) || keys(%{$self->{'_taxonomyFilter'}}) > 1 ){
                                                #print Dumper $group;
                                                #exit;
                                                #print "\treturning from next group\n";
                                                return $group;
                                        }
                                }
                                #print Dumper $group;
                                #exit;
                        }
                        #print "\tfinished looking at group\n";
                }
        }
        $self->{'_streamReader'}->close;
        return undef;
}


sub readGroup
{
        #print "\treading group\n";
        my ($self,$parent,@taxIdSet) = (@_); 
        #print Dumper $parent,@taxIdSet;
        my $group = Group->new();
       # print "\tparent is:\n";
        #print Dumper $parent;
        $group->setId($parent->getAttribute(OrthoXMLNames::GROUP_ID_ATTR));
        #print "$. set ID to ".$parent->getAttribute(OrthoXMLNames::GROUP_ID_ATTR)."\n";
        #print Dumper $group;
        #exit;
        my @children;
        my @geneMembers;
        my $child = Element->new();
        #print "\tcollecting children....\n";
        while(defined($child = $self->nextOrthoXMLTag()))
        {
               my $name = $child->getName();
               #print "\tcurrent Child is: \n";
               #print Dumper $child;
               #print "\t\tcheck outbreak: $name eq ".$parent->getName()."\n";
               if($child->getType() == XML_READER_TYPE_ELEMENT)
               {
                       # print "\t\t\ttype is equal ".XML_READER_TYPE_ELEMENT."\n";
                       if($name eq OrthoXMLNames::GENE_REF_TAG)
                       {
                              # print "\tname is gene-ref equal ".OrthoXMLNames::GENE_REF_TAG.": \n";
                               #print "\t\tcalling readGeneRef:\n";
                              # print Dumper $child,@taxIdSet;
                               my $membership = $self->readGeneRef($child,@taxIdSet);
                               #print "\tcurrent membership is: \n";
                              # print Dumper $membership;
                               if($membership)
                               {
                                       if(!scalar(@geneMembers))
                                       {
                                               @geneMembers = ();
                                       }
                                       push(@geneMembers,$membership);
                                       #print "\t\t\tadded geneMembers to ".join(",",@geneMembers)."";
                               }
                               
                       }
                       elsif($name eq OrthoXMLNames::ORTHOLOG_GROUP_TAG || $name eq OrthoXMLNames::PARALOG_GROUP_TAG)
                       {
                               #print "\tname is ortholog|paralog group -equal ".OrthoXMLNames::ORTHOLOG_GROUP_TAG.": \n";
                               #print "\t\t\treading subGroup\n";
                              # print Dumper $child,@taxIdSet;
                               my $subGroup = $self->readGroup($child,@taxIdSet);
                               if(defined($subGroup))
                               {
                                       if($name eq OrthoXMLNames::ORTHOLOG_GROUP_TAG)
                                       {
                                               $subGroup->setType(Group::ORTHOLOG);
                                       }
                                       else
                                       {
                                               $subGroup->setType(Group::PARALOG);
                                       }
                                       if(!scalar(@children))
                                       {
                                               @children = ();
                                       }
                                       push(@children,$subGroup);
                                       #print "children are:\n";
                                       #print Dumper @children."\n";
                                       #exit;
                               }
                       }
                       else
                       {
                               #print "\treading annotation\n";
                             $self->readAnnotation($child,$group);  
                       }
               }
               elsif($child->getType() == XML_READER_TYPE_END_ELEMENT && $name eq $parent->getName())
               {
                       #print "\t\t\tsetting the group: children: ".scalar(@children).", geneMembers:".scalar(@geneMembers)."\n";
                       if(!scalar(@children) && !scalar(@geneMembers))
                       {
                               #print "\t\t\tleaving read group without members/children\n";
                               return undef;
                       }
                                #print Dumper $group;
                               $group->setChildren(@children);
                               $group->setMembers(@geneMembers);
                               #print "group members/children set\n";
                               #print Dumper $group;
                               #exit;
                               return $group;
               }
       }
       return undef;
}

sub readAnnotation
{
     my ($self,$elem,$annotateable) = (@_);
     my $name = $elem->getName();
     #print "\t\t\tread annotation $name\n";
     if($name eq OrthoXMLNames::SCORE_TAG)
     {
                #print "\tits a score tag\n";
             my $scoreLabel = $elem->getAttribute(OrthoXMLNames::SCORE_REF_ATTR);
             if(exists $self->{'_scoreDefinitions'}{$scoreLabel})
             {
                     my $annotationDefinition = $self->{'_scoreDefinitions'}{$scoreLabel};
                     my $score = $elem->getAttribute(OrthoXMLNames::SCORE_VALUE_ATTR);
                     $annotateable->addScore($annotationDefinition,$score);
             }
             #print "\tadded annotabeable score\n";
             #print Dumper $annotateable;
             return 1;
     }
     elsif($name eq OrthoXMLNames::PROPERTY_TAG)
     {
             #print "\tis property tag\n";
             #print Dumper $annotateable;
             my $propertyLabel = $elem->getAttribute(OrthoXMLNames::PROPERTY_KEY_ATTR);
             if($self->{'_version'} < 0.4 && !exists $self->{'_propertyDefinitions'}{$propertyLabel})
             {
                     #print "\told version\n";
                     my $annotationDefinition = AnnotationDefinition->new($propertyLabel,"");
                     $self->{'_propertyDefinitions'}{$propertyLabel} = $annotationDefinition;
             }
             if(exists $self->{'_propertyDefinitions'}{$propertyLabel})
             {
                #print "property label exists\n";
                     my $annotationDefinition = AnnotationDefinition->new($propertyLabel);
                     #print Dumper $annotationDefinition;
                     #print "\tjust checking this annotation\n";
                     
                     
                     my $value = $elem->getAttribute(OrthoXMLNames::SCORE_VALUE_ATTR);
                     #print "\tadding value $value\n";
                     #print Dumper $elem;
                     #exit;
                     if(defined($value))
                     {
                             $annotateable->addProperty($annotationDefinition,$value);   
                     }
                     else
                     {
                             $annotateable->addProperty($annotationDefinition);   
                     }
             }else{
                     ;#print "looks like it did not exist\n";
             }
             #print Dumper $annotateable;
             return 1;
     }
     #print "\t\tended in error\n";
     return undef;
}

sub readGeneRef
{
      my ($self,$elem,@taxIdSet) = (@_);  
      my $membership;
      my $geneRefId = $elem->getAttribute(OrthoXMLNames::GENE_REF_ATTR);
      
      #print "getting gene $geneRefId\n";
      #print Dumper $self->{_geneList};
      #exit;
      my $gene = $self->{_geneList}{$geneRefId};
      #print "generefid is $geneRefId\nList of genes is:";
      #print Dumper $self->{_geneList};
      if(defined($gene))
      {
              $self->{_taxIdSet}{($gene->getSpecies())->getNcbiTaxId()} = 1;;
              $membership = Membership->new($gene);
      }
      #print "\tsetting child:\n";
      #print Dumper $membership;
      
      my $child;
      while(defined($child = $self->nextOrthoXMLTag))
      {
              #print "\tin readGeneRef:child is (type: ".$child->getType()." should be ".XML_READER_TYPE_ELEMENT."):\n";
              #print Dumper $child;
              #print "\twith membership: \n";
              #print Dumper $membership;
              if(defined($membership))
              {
                      #print "\tmembership defined\n";
                      if($child->getType() == XML_READER_TYPE_ELEMENT && defined($gene))
                      {
                              #print "\ttrying to read annotation\n";
                          $self->readAnnotation($child,$membership);    
                      }
              }
              #print "child.type: ".$child->getType()."\t ".$child->getName()." eq ".$elem->getName."\n";
              if($child->getType() == XML_READER_TYPE_END_ELEMENT && $child->getName() eq $elem->getName)
              {
                      #print "equals end.element and names match. return membership\n";
                      return $membership;
              }
      }
      return undef;
}


sub readPropertyDefinition
{
      my ($self,$elem) = (@_);    
      #print Dumper $elem;
      #exit;
      my $propertyId = $elem->getAttribute(OrthoXMLNames::PROPERTY_DEF_ID_ATTR);
      if(!defined($propertyId) || $propertyId eq '')
      {
              die "Property name is missing\n";
      }
      if(exists $self->{_propertyDefinitions}{$propertyId})
      {
              die "Property name duplicated\n";
      }
      my $annotationDefinition = AnnotationDefinition->new($propertyId,$elem->getAttribute(OrthoXMLNames::PROPERTY_DEF_DESCRIPTION_ATTR));
      $self->{_propertyDefinitions}{$propertyId} = $annotationDefinition;
      #print Dumper $annotationDefinition;
      #print Dumper $self->{_propertyDefinitions};
      #exit;
}


package Element;
{
        #print Dumper @_;
        sub new(){
                my ( $class, $file ) = @_;
                my $objref = {
                        _name => undef,
                        _type  => undef,
                        _attributes => undef,
                };
	        my $name;
	        my $type;
	        my %attributes; # = new HashMap<String,String>();
	        bless $objref, $class;
                #print Dumper $objref;
       	        return $objref;
        }
	#public void addAttribute(String name,String value)
	#{
	#	attributes.put(name,value);
	#}
        sub addAttribute {
           my ( $self, $attribute, $value ) = @_;
           $self->{_attributes}{$attribute} = $value if defined($attribute);
           return $self->{_name};
       }
	#public String getAttribute(String name)
	#{
	#	return attributes.get(name);
	#}
	sub getAttribute {
                my ( $self, $attribute) = @_;  
                #print "attribute is: $attribute\n";
                return $self->{_attributes}{$attribute};
        }
	#/**
	# * @param name the name to set
	# */
	#public void setName(String name) {
	#	this.name = name;
	#}
        sub setName {
           my ( $self, $name ) = @_;
           $self->{_name} = $name if defined($name);
           return $self->{_name};
       }


	#/**
	# * @return the name
	# */
	#public String getName() {
	#	return name;
	#}
	sub getName {
              my ( $self) = @_;       
            return $self->{_name};
        }

	#/**
	# * @param type the type to set
	# */
	#public void setType(int type) {
	#	this.type = type;
	#}
        sub setType {
           my ( $self, $type ) = @_;
           $self->{_type} = $type if defined($type);
           return $self->{_type};
       }
	#/**
	# * @return the type
	# */
	#public int getType() {
	#	return type;
	#}
        sub getType {
              my ( $self) = @_;       
            return $self->{_type};
        }
}


}
1;