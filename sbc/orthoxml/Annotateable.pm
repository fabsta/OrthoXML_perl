#/**
# * Basic data structures for creating or parsing OrthoXML.
# */
package Annotateable;

use Data::Dumper;
use Tie::RefHash;
#import java.util.ArrayList;
#import java.util.HashMap;
#import java.util.HashSet;
#import java.util.List;
#import java.util.Map;
#import java.util.Set;

#/**
# * Allows to assign scores and properties to subclasses.
# * 
# * @author Thomas Schmitt
# */

sub new
{
    my $class = shift;
    my $self = {
        _scores => shift, # array of scores
        _scores_lookup => shift,  #lookup for scores
        _scores2scores => shift,  #lookup for scores
        
        _properties  => shift, # array of properties 
        _properties_lookup => shift, # lookup for properties
        _properties2scores => shift
    };
    
    #List of Object
    #Object ID -> array position
    #tie my %hash, 'Tie::RefHash';
    # Print all the values just for clarification.
    #print "species is $self->{_name}\n";
    #print "database is $self->{_description}\n";
    bless $self, $class;
    return $self;
}

sub getDefinedScores{
       my $self = shift;
       #print "\tno scores defined\n";
       if(!defined $self->{_scores} || !scalar(@{$self->{_scores}})){
           return ();    
           
       }
       return keys(%{$self->{_scores_lookup}});
}
#	public Set<AnnotationDefinition> getDefinedScores()
#	{
#		if(scores == null )
#			return new HashSet<AnnotationDefinition>();
#		
#		return scores.keySet();
#	}
	
#	/**
#	 * Adds a score with the given type. There can be multiple scores for the same type.
#	 * @param scoreDefinition the type of the score
#	 * @param score the value of the score
#	 */
sub addScore
{
        my ($self, $scoreDefinition,$score) = (@_);
        if(! exists $self->{_scores_lookup}{$scoreDefinition}){
                my $arrayIndex = (exists $self->{_scores})? scalar(@{$self->{_scores}}) : 0;
                $self->{_scores_lookup}{$scoreDefinition} = $arrayIndex;
                $self->{_scores}[$arrayIndex] = $scoreDefinition;
                push(@{$self->{_scores2scores}[$arrayIndex]}, $score);
        }
}
#	public void addScore(AnnotationDefinition scoreDefinition,Double score){
#		
#		if(scores == null)
#			scores = new HashMap<AnnotationDefinition,List<Double>>();
#		
#		if(!scores.containsKey(scoreDefinition))
#			scores.put(scoreDefinition, new ArrayList<Double>());
#		scores.get(scoreDefinition).add(score);
#	}
	
#	/**
#	 * Returns the scores for the given type. There can multiple scores for the same type.
#	 * @param scoreDefinition the type of the score
#	 * @return The scores for the given type. Empty list if none.
#	 */
sub getScores
{
        my ($self, $scoreDefinition) = (@_);
        if(!scalar(@{$self->{_scores}})  || ! exists $self->{_scores_lookup}{$scoreDefinition}){
                return ();
        }
        my $arrayIndex = $self->{_scores_lookup}{$scoreDefinition};
        return @{$self->{_scores2scores}[$arrayIndex]};
}

sub getScoreObject
{
        my ($self, $scoreDefinition) = (@_);
        if(!scalar(@{$self->{_scores}})  || ! exists $self->{_scores_lookup}{$scoreDefinition}){
                return ();
        }
        my $arrayIndex = $self->{_scores_lookup}{$scoreDefinition};
        return $self->{_scores}[$arrayIndex];
}
#	public List<Double> getScores(AnnotationDefinition scoreDefinition)
#	{
#
#		if(scores == null || !scores.containsKey(scoreDefinition))
#			return new ArrayList<Double>();
#		return scores.get(scoreDefinition);
#	}
	
#	/**
#	 * Removes all scores of the object.
#	 */
sub clearScores
{
     my ($self) = (@_);   
     if(scalar(@{$self->{_scores}}))
     {
             $self->{_scores} = ();
             $self->{_scores_lookup} = ();
             $self->{_scores2scores} = ();
     }
}
#	public void clearScores()
#	{
#		if(scores != null)
#			scores.clear();
#	}
	
#	/**
#	 * Return all scores that are defined for this object. 
#	 * @return The scores that are defined for this object. Empty set if nonen.
#	 */

sub getDefinedProperties
{
      my ($self) = (@_);  
      if(!exists $self->{_properties} || !scalar(@{$self->{_properties}}))
      {
              return ();
      } 
      #print "found property: \n";
      #print Dumper $self;
      #print "see?\n";
      return @{$self->{_properties}};
}


#	public Set<AnnotationDefinition> getDefinedProperties()
#	{
#		if(properties == null )
#			return new HashSet<AnnotationDefinition>();
#		
#		return properties.keySet();
#	}
	
#	/**
#	 * Adds a non-value property with the given type. There can be multiple properties for the same type.
#	 * @param propertyDefinition the type of the property
#	 */
sub addProperty
{
    my ($self,$propertyDefinition,$value) = (@_);  
    #print "\taddproperty\n";
    #print Dumper $propertyDefinition,$value;
    #print "\t to\n";
    #print Dumper $self;
    #exit;
    #if(!keys(%{$self->{_properties}}))
    #{
    #        #$self->{_properties} = ();
    #        tie  %{$self->{_scores}}, 'Tie::RefHash';
    #}
    #print "\tchecking if ".$propertyDefinition." exists\n";
    if(!exists $self->{_properties_lookup}{$propertyDefinition}){
            #$self->{_properties}{$propertyDefinition} = ();
            my $arrayIndex;
            if(!exists $self->{_properties} || !scalar(@{$self->{_properties}}))
            {
                    $arrayIndex = 0;
            }
            else
            {
                    $arrayIndex = scalar(@{$self->{_properties}});
            }

            #print "\tsetting property lookup to $arrayIndex\n";
            $self->{_properties_lookup}{$propertyDefinition} = $arrayIndex;
            #push(@{$self->{_properties}[$arrayIndex]},$propertyDefinition);
            $propertyDefinition->{_description} = $value;
            push(@{$self->{_properties}},$propertyDefinition);
            #print "\tchecking properties object array\n";
            #print Dumper $self->{_properties};
            #exit;
            if(defined($value) && $value ne '')
            {
                    push(@{$self->{_properties2scores}{$arrayIndex}}, $value);
                    #push(@{$self->{_properties2scores}[$arrayIndex]},$score);
                    
            }
            else
            {
                    push(@{$self->{_properties2scores}{$arrayIndex}}, undef);
                    #push(@{$self->{_properties2scores}[$arrayIndex]},undef);
            }
            #print Dumper $self;
            #exit;
    }
}



#	public void addProperty(AnnotationDefinition propertyDefinition)
#	{
#		addProperty(propertyDefinition,null);
#	}
#	/**
#	 * Adds a value property with the given type. There can be multiple properties for the same type.
#	 * @param scoreDefinition the type of the score
#	 * @param score the value of the score
#	 */
#	public void addProperty(AnnotationDefinition propertyDefinition,String value){
#		
#		if(properties == null)
#			properties = new HashMap<AnnotationDefinition,List<String>>();
#		
#		if(!properties.containsKey(propertyDefinition))
#			properties.put(propertyDefinition, new ArrayList<String>());
#		
#		if(value != null && !value.isEmpty())
#			properties.get(propertyDefinition).add(value);
#		else
#			properties.get(propertyDefinition).add(null);
#	}
	
#	/**
#	 * Checks if the object has the property.
#	 * @param scoreDefinition the type of the score
#	 * @return True if the object has the property
#	 */
sub hasProperty
{
     my ($self,$propertyDefinition) = (@_);     
     if(exists $self->{_properties_lookup}{$propertyDefinition})
     {
             return 1;
     }
     else{
             return 0;
     }
}
#	public boolean hasProperty(AnnotationDefinition propertyDefinition)
#	{
#		return properties.containsKey(propertyDefinition);
#	}
	
#	/**
#	 * Returns the properties for the given type. There can be multiple properties for the same type.
#	 * @param propertyDefinition the type of the property
#	 * @return The properties for the given type. Empty list if none. Null for non-value properties.
#	 */
sub getProperties
{
        my ($self,$propertyDefinition) = (@_);     
        if(!scalar(@{$self->{_properties}}) || !exists $self->{_properties_lookup}{$propertyDefinition})
        {
                return ();
        }
        my $arrayIndex = $self->{_properties_lookup}{$propertyDefinition};
        #print "\tgetting object at position $arrayIndex\n";
        #print Dumper $self->{_properties}[$arrayIndex];
        #print Dumper $self->{_properties_lookup};
        return $self->{_properties}[$arrayIndex];
}

sub getPropertyObject
{
        my ($self, $propertyDefinition) = (@_);
        if(!scalar(@{$self->{_properties}})  || ! exists $self->{_properties_lookup}{$propertyDefinition}){
                return ();
        }
        my $arrayIndex = $self->{_properties_lookup}{$propertyDefinition};
        #print "\tgetting object at position $arrayIndex\n";
        return $self->{_properties}[$arrayIndex];
}

#	public List<String> getProperties(AnnotationDefinition propertyDefinition)
#	{
#
#		if(properties == null || !properties.containsKey(propertyDefinition))
#			return new ArrayList<String>();
#		return properties.get(propertyDefinition);
#	}
	
#	/**
#	 * Removes all properties of the object.
#	 */
sub clearProperties
{
        if(scalar(@{$self->{_properties}}))
        {
                $self->{_properties} = ();
                $self->{_properties_lookup} = ();
                $self->{_properties2scores} = ();
        }
}
#	public void clearProperties()
#	{
#		if(properties != null)
#			properties.clear();
#	}
	
	
#}

1;