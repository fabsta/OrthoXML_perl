package Gene;

#/**
# * Represent a gene or better molecule in the context of orthology assignments.
# * Can be identified by a gene, protein and transcript identifier.
# * 
# * @author Thomas Schmitt
# * 
# */
#public class Gene {

#	private Database database;
#	private Species species;
#	private String geneIdentifier;
#	private String proteinIdentifier;
#	private String transcriptIdentifier;
	
	
#	/**
#	 * Creates a Gene object from the given database and species
#	 * 
#	 * @param species the species from which the gene stems
#	 * @param database the database the gene stems from
#	 */
sub new
{
    my $class = shift;
    my $self = {
        _species => shift,
        _database  => shift,
        _geneIdentifier => undef,
        _proteinIdentifier => undef,
        _transcriptIdentifier => undef,
    };
    # Print all the values just for clarification.
    #print "species is $self->{_species}\n";
    #print "database is $self->{_database}\n";
    bless $self, $class;
    return $self;
}

	
#	/**
#	 * Returns the gene identifier
#	 * @return the gene identifier
#	 */
	 sub getGeneIdentifier {
             my ( $self) = (@_);       
           return $self->{_geneIdentifier};
       }
#	/**
#	 * Sets the gene identifier
#	 * @param geneIdentifier the gene identifier to set
#	 */
	 sub setGeneIdentifier {
           my ( $self, $geneIdentifier ) = (@_);
           $self->{_geneIdentifier} = $geneIdentifier if defined($geneIdentifier);
           return $self->{_geneIdentifier};
       }
#	/**
#	 * Returns the protein identifier
#	 * @return the protein identifier
#	 */
	 sub getProteinIdentifier {
              my ( $self) = (@_);       
            return $self->{_proteinIdentifier};
        }
#	/**
#	 * Sets the protein identifier
#	 * @param proteinIdentifier identifier the protein identifier to set
#	 */
	 sub setProteinIdentifier {
           my ( $self, $proteinIdentifier ) = (@_);
           $self->{_proteinIdentifier} = $proteinIdentifier if defined($proteinIdentifier);
           return $self->{_proteinIdentifier};
       }
#	/**
#	 * Returns the transcript identifier
#	 * @return the transcriptIdentifier
#	 */
	 sub getTranscriptIdentifier {
              my ( $self) = (@_);       
            return $self->{_transcriptIdentifier};
        }
#	/**
#	 * Sets the transcript identifier
#	 * @param transcriptIdentifier the transcriptIdentifier to set
#	 */
=over

=item setTranscriptIdentifier()


 Type    : Method
 Usage   : my $gene->setTranscriptIdentifier;
 Function: Sets the transcript identifier.
 Returns : the database.

=back

=cut
sub setTranscriptIdentifier {
           my ( $self, $transcriptIdentifier ) = (@_);
           $self->{_transcriptIdentifier} = $transcriptIdentifier if defined($transcriptIdentifier);
           return $self->{_transcriptIdentifier};
}

=over

=item getDatabase()


 Type    : Method
 Usage   : my $gene->setDagetDatabasetabase;
 Function: Returns the database the gene stems from.
 Returns : the database.

=back

=cut
sub getDatabase {
              my ( $self) = (@_);       
            return $self->{_database};
}


=over

=item setDatabase()


 Type    : Method
 Usage   : my $gene->setDatabase;
 Function: Sets the database the gene stems from.
 Args : database the database to set.

=back

=cut
sub setDatabase {
           my ( $self, $database ) = (@_);
           $self->{_database} = $database if defined($database);
           return $self->{_database};
}

=over

=item getSpecies()


 Type    : Method
 Usage   : my $gene->getSpecies;
 Function: Returns the species the gene stems from.
 Returns : the species.

=back

=cut
sub getSpecies {
              my ( $self) = (@_);       
            return $self->{_species};
}

=over

=item setSpecies()


 Type    : Method
 Usage   : my $gene->getSpecies;
 Function: Sets the species the gene stems from.
 Args : species the species to set.

=back

=cut
sub setSpecies {
           my ( $self, $species ) = (@_);
           $self->{_species} = $species if defined($species);
           return $self->{_species};
       }
	
#	@Override
#	public int hashCode() {
#		final int prime = 31;
#		int result = 1;
#		result = prime * result
#				+ ((geneIdentifier == null) ? 0 : geneIdentifier.hashCode());
#		result = prime
#				* result
#				+ ((proteinIdentifier == null) ? 0 : proteinIdentifier
#						.hashCode());
#		result = prime
#				* result
#				+ ((transcriptIdentifier == null) ? 0 : transcriptIdentifier
#						.hashCode());
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
#		Gene other = (Gene) obj;
#		if (geneIdentifier == null) {
#			if (other.geneIdentifier != null)
#				return false;
#		} else if (!geneIdentifier.equals(other.geneIdentifier))
#			return false;
#		if (proteinIdentifier == null) {
#			if (other.proteinIdentifier != null)
#				return false;
#		} else if (!proteinIdentifier.equals(other.proteinIdentifier))
#			return false;
#		if (transcriptIdentifier == null) {
#			if (other.transcriptIdentifier != null)
#				return false;
#		} else if (!transcriptIdentifier.equals(other.transcriptIdentifier))
#			return false;
#		return true;
#	}
	
#}
1;