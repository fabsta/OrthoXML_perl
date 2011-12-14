package OrthoXMLWriter;
use Data::Dumper;
use warnings;
use strict;
use File::Temp;
use IO;
use XML::LibXML;
use XML::LibXML::Reader;
use XML::Writer;
use sbc::orthoxml::Database;
use sbc::orthoxml::Gene;
use sbc::orthoxml::Group;
use sbc::orthoxml::Species;
use sbc::orthoxml::Membership;
use sbc::orthoxml::io::OrthoXMLNames;
use sbc::orthoxml::AnnotationDefinition;
use sbc::orthoxml::Annotateable;
our @ISA = qw ( Annotateable );

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
#public class Group extends Scoreable {

#	/**
#	 *  The type of a group i.e. ortholog or paralog.
#	 *
#	 */
#	public enum Type { ORTHOLOG,PARALOG }
use constant ORTHOLOG => 1;
use constant PARALOG => 2;
sub new()
{
        #print Dumper @_;
        #exit;
        my ( $self,$outputWriter,$origin,$originVersion) = (@_);
        my $objref = {
                        _XSI_NAMESPACE => ["xsi","http://www.w3.org/2001/XMLSchema-instance"],
                        _SCHEMALOCATION_ATTR => "schemaLocation",
                        _ORTHOXML_VERSION => 0.4,
                        _geneDefinitions => undef,  # # array of # Map<Species,Map<Database,Map<Gene,Integer>>>
                        _species2object => undef, # objectname to array index
                                # Problem is that perl does not allow objects as keys ->  
                        _scoreDefinitions => undef, # Map<String,AnnotationDefinition>
                        _database2object => undef,
                        _propertyDefinitions => undef,  # Map<String,AnnotationDefinition>
                        _propertyDefinitions2object => undef,
                        _gene2object => undef,  # Map<String,AnnotationDefinition>
                        _xmlWriter => undef, #XMLStreamWriter
                        _geneCount => 0,
                        _outputWriter => undef, # Writer
                        _tempFile => undef,
                        _origin => undef,
                        _originVersion => undef,
                        _orthoXMLNames => undef, #OrthoXMLNames
                        _indentionLevel => 1,
                        _indent => "  ",
                        _tempWriter => undef,  #BufferedWriter
        };

	#//create temporary file for the groups
	my $curr_dir = `pwd`;
	chomp($curr_dir);
        $objref->{_tempFile} = File::Temp->new( UNLINK => 1, DIR => $curr_dir,SUFFIX => '.xml' );
        #print "\twriting to temp file ".$objref->{_tempFile}."\n";
        $objref->{_xmlWriter} = XML::Writer->new(
                                        OUTPUT      => $objref->{_tempFile},
                                        DATA_MODE   => 1,
                                        DATA_INDENT => 1,
                                );
        $objref->{_origin} = $origin;
        $objref->{_outputWriter} = $outputWriter;
        $objref->{_originVersion} = $originVersion;
        #orthoXMLNames = new OrthoXMLNames(ORTHOXML_VERSION);
	
        #tempFile = File.createTempFile("orthoxml", ".xml");
	#tempFile.deleteOnExit();

	#XMLOutputFactory outputFactory = XMLOutputFactory.newInstance();
	#
	#tempWriter = new BufferedWriter(new FileWriter(tempFile));
	#xmlWriter = outputFactory.createXMLStreamWriter(tempWriter);
	#this.startElement(orthoXMLNames.getGroupsTag());
	$objref->{_xmlWriter}->startTag(OrthoXMLNames::GROUPS_TAG);
        #print "\tsaving OrthoXML in $outputWriter \n\ttmp file is ".$objref->{_tempFile}->filename."\n";
        
        bless $objref, $self;
        return $objref;
}
sub write()
{
        my ( $self,$group) = (@_);
        if($group->getType() ne ORTHOLOG)
        {
                die "Write requires toplevel ortholog group\n";
        }
        $self->writeGroup($group);
}
sub writeGroup()
{
        #exit;
        my ( $self,$group) = (@_);
        print "\twriting Group\n";
        #print Dumper $group;
        my $groupID;
        my $writer = $self->{_xmlWriter};
        if(defined($group->getId()))
        {
                $groupID = $group->getId();
                if($group->getType() eq ORTHOLOG)
                {
                        #print "\twriting ".OrthoXMLNames::ORTHOLOG_GROUP_TAG." - ".OrthoXMLNames::GROUP_ID_ATTR." => $groupID\n";
                        $writer->startTag(OrthoXMLNames::ORTHOLOG_GROUP_TAG, OrthoXMLNames::GROUP_ID_ATTR => $groupID);
                }
                if($group->getType() eq PARALOG)
                {
                        #print "\twriting ".OrthoXMLNames::PARALOG_GROUP_TAG." - ".OrthoXMLNames::GROUP_ID_ATTR." => $groupID\n";
                        $writer->startTag(OrthoXMLNames::PARALOG_GROUP_TAG, OrthoXMLNames::GROUP_ID_ATTR =>  $groupID);
                }
        }
        else
        {       
                if($group->getType() eq ORTHOLOG)
                {
                        $writer->startTag(OrthoXMLNames::ORTHOLOG_GROUP_TAG);
                }
                if($group->getType() eq PARALOG)
                {
                        $writer->startTag(OrthoXMLNames::PARALOG_GROUP_TAG);
                }
        }
        #print "\twriting scores\n";
        #print Dumper $group;
        #exit;
        $self->writeScores($group);
        #print "\twriting properties\n";
        $self->writeProperties($group);
        #print "\twriting gene refs\n";
        $self->writeGeneRefs($group->getMembers());
        
        #print "\thas sub groups?\n";
        foreach my $subGroup($group->getChildren())
        {
                $self->writeGroup($subGroup);
        }
        #print "\twriting end tag"
        #$writer->endTag(OrthoXMLNames::ORTHOLOG_GROUP_TAG);
        $self->endElement();
}

sub endElement
{
        my ( $self) = (@_);
        my $writer = $self->{_xmlWriter};
        $writer->endTag();
}

sub writeScores
{
     my ( $self,$annotateable) = (@_);   
     my $writer = $self->{_xmlWriter};
     #print Dumper $annotateable;
     #print "\t\tcurrent loop annotation definition\n";
     foreach my $annotationDefinition ($annotateable->getDefinedScores)
     {
             #print "\t\tcurrent loop annotation definition\n";
             #print Dumper $annotationDefinition;
             my $annotationDefinition_obj = $annotateable->getScoreObject($annotationDefinition);
             #my $annotationScore = $annotationDefinition->getScore($annotationDefinition);
             #print Dumper $annotationDefinition_obj;
             my $annotationDefinition_objRef = $annotationDefinition_obj->getName;
             if(! exists $self->{_scoreDefinitions}{$annotationDefinition})
             {
                     $self->{_scoreDefinitions}{$annotationDefinition} = $annotationDefinition_obj;
             }
            # print "\tscore for annotationDefinition \n";
            # print Dumper $annotateable->getScores($annotationDefinition);
            # exit;
             foreach my $value ($annotateable->getScores($annotationDefinition))
             {
                        #print Dumper $value;
                        #exit;
                     #my $value_desc = $value->{_description};
                     $writer->emptyTag(OrthoXMLNames::SCORE_TAG, 
                                OrthoXMLNames::SCORE_REF_ATTR =>  $annotationDefinition_objRef,
                                OrthoXMLNames::SCORE_VALUE_ATTR => $value
                                );
             }
             #exit;
     }
}



sub writeProperties
{
     my ( $self,$annotateable) = (@_); 
     my $writer = $self->{_xmlWriter};  
     #print "checking annotateable \n";
     #print Dumper $annotateable;
     #exit;
     if(!defined($annotateable)){
             die "object annotateable not defined\n";
     }
     foreach my $propertyDefinition ($annotateable->getDefinedProperties)
     {
             #print "\tprinting variable \$propertyDefinition\n";
             #print Dumper $propertyDefinition;
             #$propertyDefinition = $propertyDefinition[0];
             #exit;
             my $propertyDefinition_obj = $annotateable->getPropertyObject($propertyDefinition);
             #print "\tgetting name from \$propertyDefinition->getName() \n";
             my $propertyDefinitionRef = $propertyDefinition->getName();
             if(! exists $self->{_propertyDefinitions}{$propertyDefinition})
             {
                     #print "nu är vi här!\n";
                     $self->{_propertyDefinitions}{$propertyDefinition} = $propertyDefinition_obj;
                     #print Dumper $propertyDefinition_obj;
                     #exit;
                     
             }
             
             foreach my $value ($annotateable->getProperties($propertyDefinition))
             {
                     #print "\tgot value: \n";
                     #print Dumper $value;
                     my $value_desc = $value->{_description};
                     #print Dumper $value_desc;
                     #exit;
                     if(defined($value_desc) && $value_desc ne ''){
                             $writer->emptyTag(OrthoXMLNames::PROPERTY_TAG, 
                                        OrthoXMLNames::PROPERTY_KEY_ATTR =>  $propertyDefinitionRef,
                                        OrthoXMLNames::PROPERTY_VALUE_ATTR => $value_desc
                                        );
                     }
                     else{
                             $writer->emptyTag(OrthoXMLNames::PROPERTY_TAG, 
                                        OrthoXMLNames::PROPERTY_KEY_ATTR =>  $propertyDefinitionRef,
                                        );
                     }
             }
     }
}

sub writeGeneRefs
{
     my ( $self,@geneMembers) = (@_);
     my $writer = $self->{_xmlWriter};
     foreach my $member(@geneMembers)
     {
             my $gene = $member->getGene();
             my $geneRef = $self->addGene($gene);
             die "no member. problem with writeGeneRefs\n" if !defined($member) || $member eq '';
             if(!defined($member->getDefinedScores()) || $member->getDefinedScores() eq '' 
             && !defined($member->getDefinedProperties()) || $member->getDefinedProperties() eq '')
             {
                     $writer->emptyTag(OrthoXMLNames::GENE_REF_TAG, 
                                     OrthoXMLNames::GENE_REF_ATTR =>  $geneRef,
                                     );   
             }
             else
             {
                  $writer->startTag(OrthoXMLNames::GENE_REF_TAG, OrthoXMLNames::GENE_REF_ATTR =>  $geneRef);
                  $self->writeScores($member);   
                  $self->writeProperties($member);   
                  $self->endElement();
             }
             
     }
}

sub addGene
{
     my ( $self,$gene) = (@_);

     my $species = $gene->getSpecies();
     my $database = $gene->getDatabase();
     if(! exists $self->{_geneDefinitions}{$species})
     {
             $self->{_geneDefinitions}{$species} = ();
             $self->{_geneDefinitions2object}{$species} = ();
     }
     if(! exists $self->{_geneDefinitions}{$species})
     {
             $self->{_geneDefinitions}{$species} = ();
     }
     if(! exists $self->{_geneDefinitions}{$species}{$database}{$gene})
     {
        $self->{_geneCount}++;
        $self->{_geneDefinitions}{$species}{$database}{$gene} = $self->{_geneCount};
        $self->{_species2object}{$species} = $species; # trick so save species object -> objects will be stringified when used as hash keys
        $self->{_database2object}{$database} = $database; # trick so save species object -> objects will be stringified when used as hash keys
        $self->{_gene2object}{$gene} = $gene; # trick so save species object -> objects will be stringified when used as hash keys
        return $self->{_geneCount};
     }
     else
     {
         return $self->{_geneDefinitions}{$species}{$database}{$gene};
     }
     

}


sub close
{
       my ( $self) = (@_); 
       # complete temporary file
       #print "\twriting end-tag (groups)\n";
       $self->endElement();
       my $writer = $self->{_xmlWriter};
       $writer->end();
       my $tmpFile = $self->{_tempFile};
       $tmpFile->close();
       
       #die "a little earlier (check $tmpFile)\n";
       #write global definitions
       my $outputFile = $self->{_outputWriter};
       my $xmlOutputDocument = new IO::File(">$outputFile");
       $self->{_xmlWriter} = XML::Writer->new(
                                       OUTPUT      => $xmlOutputDocument,
                                       DATA_MODE   => 1,
                                       DATA_INDENT => 1,
                                       UNSAFE => 1,
                                       #FORCED_NS_DECLS => 1,
                               );
                               $self->{_xmlWriter}->xmlDecl("UTF-8");
                               $self->startDocument();                
       $self->writeGeneDefintions();
       $self->writeScoreDefinitions();
       $self->writePropertyDefinitions();
       my $cat_cmd = "cat ".$self->{_tempFile};
       my $second_part = `$cat_cmd`;
       #print "\tfirst part: ".substr($second_part, 0, 9)."\n";
       $second_part = "\n".$second_part;
       $second_part =~ s/\n/\n /g;
       chomp($second_part);
       $self->{_xmlWriter}->raw($second_part);
       $self->endElement();
       #$writer->end();
       $xmlOutputDocument->close();
       # append 
}


#public void close() throws XMLStreamException, IOException, TransformerException
#{
#	//complete temporary file
#	endElement();
#	xmlWriter.close();
#	
#	//write global definitions
#	XMLOutputFactory outputFactory = XMLOutputFactory.newInstance();
#	xmlWriter = outputFactory.createXMLStreamWriter( outputWriter );
#	
#	indentionLevel =0;
#	startDocument();
#	writeGeneDefintions();
#	writeScoreDefinitions();
#	writePropertyDefinitions();
#	xmlWriter.flush();
#	
#	//append groups from temporary file
#	appendTmpFile(outputWriter);
#	outputWriter.flush();
#	xmlWriter.close();
#	tempFile.delete();
#	
#}

sub writeGeneDefintions
{
       my ( $self) = (@_); 
       my $writer = $self->{_xmlWriter};
       # get all species objects
       foreach my $species(sort keys(%{$self->{_geneDefinitions}}))
       {
              my $species_obj = $self->{_species2object}{$species}; # getting the actual object
              $self->writeSpecies($species_obj);
              print "\tlooking at species ".$species_obj->getName()."\n";
              foreach my $database(sort keys(%{$self->{_geneDefinitions}{$species}}))
              {
                       my $database_obj = $self->{_database2object}{$database}; # getting the actual object
                       $self->writeDatabase($database_obj);
                       $writer->startTag(OrthoXMLNames::GENES_TAG);
                       foreach my $gene(sort keys(%{$self->{_geneDefinitions}{$species}{$database}}))
                       {
                       			
                               my $gene_obj = $self->{_gene2object}{$gene}; # getting the actual object
                               print "\twriting ".$gene_obj->getProteinIdentifier."\n";
                               print Dumper $gene_obj;
                               print "write gene \$self->{_geneDefinitions}{$species}{$database}{$gene} ".$self->{_geneDefinitions}{$species}{$database}{$gene}."\n";
                               $self->writeGene($gene_obj,  $self->{_geneDefinitions}{$species}{$database}{$gene});
                       }
                       $self->endElement();
                       $self->endElement();
               }
               $self->endElement();
       } 
}



#private void writeGeneDefintions() throws XMLStreamException, TransformerException {
#	
#	for(Species species : geneDefinitions.keySet())
#	{
#		writeSpecies(species);
#		for(Database database : geneDefinitions.get(species).keySet())
#		{
#			writeDatabase(database);
#			startElement(orthoXMLNames.getGenesTag());
#			for(Gene gene : geneDefinitions.get(species).get(database).keySet())
#			{
#				writeGene(gene,geneDefinitions.get(species).get(database).get(gene));
#			}
#			endElement();
#			endElement();
#		}
#		endElement();
#	}
#}

sub writeScoreDefinitions
{
       my ( $self) = (@_); 
       my $writer = $self->{_xmlWriter};
       #print "\twriting score definitions\n";
       if(keys(%{$self->{_scoreDefinitions}})> 0)
       {
               
               $writer->startTag(OrthoXMLNames::SCORE_DEFS_TAG);
               foreach my $scoreDefinition(values(%{$self->{_scoreDefinitions}}))
               {
                       #print Dumper $scoreDefinition;
                       #exit;
                       $writer->emptyTag(OrthoXMLNames::SCORE_DEFS_TAG, 
                               OrthoXMLNames::SCORE_DEF_ID_ATTR =>  $scoreDefinition->getName(),
                               OrthoXMLNames::SCORE_DEF_DESCRIPTION_ATTR => $scoreDefinition->getDescription());
               }
               $self->endElement();
       }
       #exit;
}

#private void writeScoreDefinitions() throws XMLStreamException {
#	if(scoreDefinitions.size() > 0)
#	{
#		startElement(orthoXMLNames.getScoreDefsTag());
#		for(AnnotationDefinition scoreDefinition : scoreDefinitions.values())
#		{
#			emptyElement(orthoXMLNames.getScoreDefTag());
#			xmlWriter.writeAttribute(orthoXMLNames.getScoreDefIdAttr(),scoreDefinition.getName());
#			xmlWriter.writeAttribute(orthoXMLNames.getScoreDefDescriptionAttr(),scoreDefinition.getDescription());
#		}
#		endElement();
#	}
#}

sub writePropertyDefinitions
{
        my ( $self) = (@_); 
        my $writer = $self->{_xmlWriter};
        my %duplicate_definitions;
        
        if(keys(%{$self->{_propertyDefinitions}})> 0)
        {
                $writer->startTag(OrthoXMLNames::PROPERTY_DEFS_TAG);
                foreach my $propertyDefinition(sort keys(%{$self->{_propertyDefinitions}}))
                       {
                               my $propertyDefinition_obj = $self->{_propertyDefinitions}{$propertyDefinition};
                               #print Dumper $propertyDefinition_obj;
                               #print Dumper $self->{_propertyDefinitions2object};
                               #exit;
                               #my $propertyDefinition_obj  = $self->{_propertyDefinitions2object}{$propertyDefinition};
                               next if exists $duplicate_definitions{$propertyDefinition_obj->getName()};
                               $writer->emptyTag(OrthoXMLNames::PROPERTY_DEF_TAG, 
                                       OrthoXMLNames::PROPERTY_DEF_ID_ATTR =>  $propertyDefinition_obj->getName(),
                                       OrthoXMLNames::PROPERTY_DEF_DESCRIPTION_ATTR => $propertyDefinition_obj->getDescription());
                                       $duplicate_definitions{$propertyDefinition_obj->getName()} = $propertyDefinition_obj->getDescription();
                       }
                       $self->endElement();
        }
}



#private void writePropertyDefinitions() throws XMLStreamException {
#	if(propertyDefinitions.size() > 0)
#	{
#		startElement(orthoXMLNames.getPropertiesTag());
#		for(AnnotationDefinition propertyDefinition : propertyDefinitions.values())
#		{
#			emptyElement(orthoXMLNames.getPropertyDefTag());
#			xmlWriter.writeAttribute(orthoXMLNames.getPropertyDefIdAttr(),propertyDefinition.getName());
#			xmlWriter.writeAttribute(orthoXMLNames.getPropertyDefDescriptionAttr(),propertyDefinition.getDescription());
#		}
#		endElement();
#	}
#}

sub writeSpecies
{
      my ( $self,$species) = (@_); 
      #print Dumper $species;
      my $writer = $self->{_xmlWriter};
      
      $writer->startTag(OrthoXMLNames::SPECIES_TAG,
              OrthoXMLNames::SPECIES_NAME_ATTR =>  $species->getName(),
              OrthoXMLNames::TAX_ID_ATTR => $species->getNcbiTaxId()
              );
}

#private void writeSpecies(Species species) throws XMLStreamException {
#	
#	startElement(orthoXMLNames.getSpeciesTag());
#	xmlWriter.writeAttribute(orthoXMLNames.getSpeciesNameAttr(), species.getName());
#	xmlWriter.writeAttribute(orthoXMLNames.getTaxIdAttr(), species.getNcbiTaxId().toString());
#}


sub writeDatabase
{
    my ( $self,$database) = (@_);
    my $writer = $self->{_xmlWriter};     
    #$writer->startTag(OrthoXMLNames::DATABASE_TAG,
    #              OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
    #              OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion()
    #              );
    my $geneLink = $database->getGeneLink();
    my $protLink = $database->getProtLink();
    my $transLink = $database->getTranscriptLink();
                 if($geneLink && $protLink && $transLink)
                 {
                         $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                           OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                           OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                           OrthoXMLNames::DATABASE_GENE_LINK_ATTR => $geneLink,
                                           OrthoXMLNames::DATABASE_PROTEIN_LINK_ATTR => $protLink,
                                           OrthoXMLNames::DATABASE_TRANSCRIPT_LINK_ATTR => $transLink
                                           ); 
                 } 
                 if($geneLink && $protLink && !defined($transLink))
                  {
                          $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                            OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                            OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                            OrthoXMLNames::DATABASE_GENE_LINK_ATTR => $geneLink,
                                            OrthoXMLNames::DATABASE_PROTEIN_LINK_ATTR => $protLink,
                                            ); 
                  }
                  if($geneLink && !defined($protLink) && !defined($transLink))
                    {
                            $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                              OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                              OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                              OrthoXMLNames::DATABASE_GENE_LINK_ATTR => $geneLink,
                                              ); 
                    }
                    if(!defined($geneLink) && !defined($protLink) && !defined($transLink))
                      {
                              $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                                OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                                OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                                ); 
                      }
                      if(!defined($geneLink) && !defined($protLink) && $transLink)
                      {
                              $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                                OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                                OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                                OrthoXMLNames::DATABASE_TRANSCRIPT_LINK_ATTR => $transLink,
                                                ); 
                      }
                      if(!defined($geneLink) && $protLink && !defined($transLink))
                      {
                              $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                                OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                                OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                                OrthoXMLNames::DATABASE_PROTEIN_LINK_ATTR => $protLink,
                                                ); 
                      }
                      if(!defined($geneLink) && $protLink && $transLink)
                      {
                              $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                                OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                                OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                                OrthoXMLNames::DATABASE_PROTEIN_LINK_ATTR => $protLink,
                                                OrthoXMLNames::DATABASE_TRANSCRIPT_LINK_ATTR => $transLink
                                                ); 
                      }
                      if($geneLink && !defined($protLink) && $transLink)
                      {
                              $writer->startTag(OrthoXMLNames::DATABASE_TAG,
                                                OrthoXMLNames::DATABASE_NAME_ATTR =>  $database->getName(),
                                                OrthoXMLNames::DATABASE_VERSION_ATTR => $database->getVersion(),
                                                OrthoXMLNames::DATABASE_GENE_LINK_ATTR => $geneLink,
                                                OrthoXMLNames::DATABASE_TRANSCRIPT_LINK_ATTR => $transLink
                                                ); 
                      }
}

#private void writeDatabase(Database database) throws XMLStreamException {
#	startElement(orthoXMLNames.getDatabaseTag());
#	xmlWriter.writeAttribute(orthoXMLNames.getDatabaseNameAttr(),database.getName());		
#	xmlWriter.writeAttribute(orthoXMLNames.getDatabaseVersionAttr(),database.getVersion());
	
#	if(database.getGeneLink() != null)
#		xmlWriter.writeAttribute(orthoXMLNames.getDatabaseGeneLinkAttr(),database.getGeneLink());
#	if(database.getProtLink() != null)
#		xmlWriter.writeAttribute(orthoXMLNames.getDatabaseProteinLinkAttr(),database.getProtLink());
#	if(database.getTranscriptLink() != null)
#		xmlWriter.writeAttribute(orthoXMLNames.getDatabaseTranscriptLinkAttr(),database.getTranscriptLink());
#}

sub writeGene
{
        my ( $self,$gene, $internalGeneId) = (@_); 
        #print Dumper $gene;
        my $writer = $self->{_xmlWriter}; 
        my $geneId = $gene->getGeneIdentifier();
        my $geneProt = $gene->getProteinIdentifier();
        my $geneTrans = $gene->getTranscriptIdentifier();
        if($geneId && $geneProt && $geneTrans)
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               OrthoXMLNames::GENE_GENE_ID_ATTR => $gene->getGeneIdentifier(),
                               OrthoXMLNames::GENE_PROT_ID_ATTR => $gene->getProteinIdentifier(),
                               OrthoXMLNames::GENE_TRANSCRIPT_ID_ATTR => $gene->getTranscriptIdentifier(),
                               );
                
        }
        if($geneId && $geneProt && !defined($geneTrans))
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               OrthoXMLNames::GENE_GENE_ID_ATTR => $gene->getGeneIdentifier(),
                               OrthoXMLNames::GENE_PROT_ID_ATTR => $gene->getProteinIdentifier(),
                               );
                
        }
        if($geneId && !defined($geneProt) && !defined($geneTrans))
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               OrthoXMLNames::GENE_GENE_ID_ATTR => $gene->getGeneIdentifier(),
                               );
                
        }        
        if($geneId && !defined($geneProt) && $geneTrans)
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               OrthoXMLNames::GENE_GENE_ID_ATTR => $gene->getGeneIdentifier(),
                               OrthoXMLNames::GENE_TRANSCRIPT_ID_ATTR => $gene->getTranscriptIdentifier(),
                               );
                
        }        
        if(!defined($geneId) && $geneProt && $geneTrans)
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               OrthoXMLNames::GENE_PROT_ID_ATTR => $gene->getProteinIdentifier(),
                               OrthoXMLNames::GENE_TRANSCRIPT_ID_ATTR => $gene->getTranscriptIdentifier(),
                               );
                
        }        
        if(!defined($geneId) && $geneProt && !defined($geneTrans))
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               OrthoXMLNames::GENE_PROT_ID_ATTR => $gene->getProteinIdentifier(),
                               );
                
        }        
        if(!defined($geneId) && !defined($geneProt) && $geneTrans)
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               OrthoXMLNames::GENE_TRANSCRIPT_ID_ATTR => $gene->getTranscriptIdentifier()
                               );
                
        }
        if(!defined($geneId) && !defined($geneProt) && !defined($geneTrans))
        {
                $writer->emptyTag(OrthoXMLNames::GENE_TAG, 
                               OrthoXMLNames::GENE_INTERNAL_ID_ATTR =>  $internalGeneId,
                               );
        }        
}

#private void writeGene(Gene gene, Integer internalGeneId) throws XMLStreamException {
#	emptyElement(orthoXMLNames.getGeneTag());
#	xmlWriter.writeAttribute(orthoXMLNames.getGeneInternalIdAttr(),internalGeneId.toString());
#	
#	if(gene.getGeneIdentifier() != null)
#		xmlWriter.writeAttribute(orthoXMLNames.getGeneGeneIdAttr(),gene.getGeneIdentifier());
#	if(gene.getProteinIdentifier() != null)
#		xmlWriter.writeAttribute(orthoXMLNames.getGeneProtIdAttr(),gene.getProteinIdentifier());
#	if(gene.getTranscriptIdentifier() != null)
#		xmlWriter.writeAttribute(orthoXMLNames.getGeneTranscriptIdAttr(),gene.getTranscriptIdentifier());
#}

sub startDocument
{
         my ( $self) = (@_); 
         my $writer = $self->{_xmlWriter};
         $writer->startTag(OrthoXMLNames::ORTHOXML_TAG,
                 OrthoXMLNames::ORTHOXML_ORIGIN_ATTR =>  $self->{_origin},
                 OrthoXMLNames::ORTHOXML_ORIGINVERSION_ATTR =>  $self->{_originVersion},
                 OrthoXMLNames::ORTHOXML_VERSION_ATTR =>  $self->{_ORTHOXML_VERSION},
                 
                 
                 #OrthoXMLNames::ORTHOXML_NAMESPACE_2011 
                 );
         
         
}
#private void startDocument() throws XMLStreamException {
#	
#	xmlWriter.writeStartDocument();
#	startElement(orthoXMLNames.getOrthoxmlTag());
#	xmlWriter.writeAttribute(orthoXMLNames.getOrthoxmlOriginAttr(), origin);
#	xmlWriter.writeAttribute(orthoXMLNames.getOrthoxmlOriginVersionAttr(),originVersion);
#	xmlWriter.writeAttribute(orthoXMLNames.getOrthoxmlVersionAttr(), ORTHOXML_VERSION.toString());
#	xmlWriter.writeDefaultNamespace(orthoXMLNames.getNamespace());
#	xmlWriter.writeNamespace(XSI_NAMESPACE[0],XSI_NAMESPACE[1]);
#	xmlWriter.writeAttribute(XSI_NAMESPACE[1],
#			SCHEMALOCATION_ATTR,
#			orthoXMLNames.getNamespace() + " " + orthoXMLNames.getOrthoxmlSchemalocation());
#}


1;