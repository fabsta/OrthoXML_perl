package Database;
use strict;
#/**
# * The Database class represent the source database for genes, proteins or transcripts. 
# * 
# * @author Thomas Schmitt
# */
#public class Database {

#	private String name;
#	private String version;
#	private String protLink;
#	private String geneLink;
#	private String transcriptLink;

#	/**
#	 * Creates a database object.
#	 * 
#	 * @param name The database name i.e. Ensembl 
#	 * @param version The database version i.e. '53' or 'March 2011'
#	 */

	sub new
      {
          my $class = shift;
          my $self = {
              _name => shift,
              _version  => shift,
          };
          # Print all the values just for clarification.
          #print "name is $self->{_name}\n";
          #print "version is $self->{_version}\n";
          bless $self, $class;
          return $self;
      }
	

#	/**
#	 * The name of the database
#	 * @return the name of the database
#	 */
# 	public String getName() {
      sub getName {
            my ( $self) = @_;       
          return $self->{_name};
      }
#	/**
#	 * Returns the link to the protein in the database how this link is create is source specific.
#	 * @return the protein link
#	 */
       sub getProtLink {
             my ( $self) = (@_);       
           return $self->{_protLink};
       }

#	/**
#	 * Allows to link to the protein in the database how this link is create is source specific.
#	 * @param protLink the protein link to set
#	 */
       sub setProtLink {
           my ( $self, $protLink ) = (@_);
           $self->{_protLink} = $protLink if defined($protLink);
           return $self->{_protLink};
       }

#	/**
#	 * Returns the link to the gene in the database how this link is create is source specific.
#	 * @return the gene link
#	 */

       sub getGeneLink {
             my ( $self) = (@_);       
           return $self->{_geneLink};
       }
#	/**
#	 * Allows to link to the gene in the database how this link is create is source specific.
#	 * @param geneLink the gene link to set
#	 */
	 sub setGeneLink {
           my ( $self, $geneLink ) = (@_);
           $self->{_geneLink} = $geneLink if defined($geneLink);
           return $self->{_geneLink};
       }
#	/**
#	 * Returns the link to the transcript in the database how this link is create is source specific.
#	 * @return the transcriptLink
#	 */
       sub getTranscriptLink {
             my ( $self) = (@_);       
           return $self->{_transcriptLink};
       }

#	/**
#	 * Allows to link to the transcript in the database how this link is create is source specific.
#	 * @param transcriptLink the transcriptLink to set
#	 */
 	sub setTranscriptLink{
           my ( $self, $transcriptLink ) = (@_);
           $self->{_transcriptLink} = $transcriptLink if defined($transcriptLink);
           return $self->{_transcriptLink};
	}

#	/**
#	 * Returns the version the database;
#	 * @return the database version
#	 */
	 sub getVersion {
             my ( $self) = (@_);       
           return $self->{_version};
       }

#	@Override
#	public int hashCode() {
#		final int prime = 31;
#		int result = 1;
#		result = prime * result
#				+ ((geneLink == null) ? 0 : geneLink.hashCode());
#		result = prime * result + ((name == null) ? 0 : name.hashCode());
#		result = prime * result
#				+ ((protLink == null) ? 0 : protLink.hashCode());
#		result = prime * result
#				+ ((transcriptLink == null) ? 0 : transcriptLink.hashCode());
#		result = prime * result + ((version == null) ? 0 : version.hashCode());
#		return result;
#	}
#
#	@Override
#	public boolean equals(Object obj) {
#		if (this == obj)
#			return true;
#		if (obj == null)
#			return false;
#		if (getClass() != obj.getClass())
#			return false;
#		Database other = (Database) obj;
#		if (geneLink == null) {
#			if (other.geneLink != null)
#				return false;
#		} else if (!geneLink.equals(other.geneLink))
#			return false;
#		if (name == null) {
#			if (other.name != null)
#				return false;
#		} else if (!name.equals(other.name))
#			return false;
#		if (protLink == null) {
#			if (other.protLink != null)
#				return false;
#		} else if (!protLink.equals(other.protLink))
#			return false;
#		if (transcriptLink == null) {
#			if (other.transcriptLink != null)
#				return false;
#		} else if (!transcriptLink.equals(other.transcriptLink))
#			return false;
#		if (version == null) {
#			if (other.version != null)
#				return false;
#		} else if (!version.equals(other.version))
#			return false;
#		return true;
#	}

	
#}
1;