package OrthoXMLNames;
use strict;
use warnings;

use base 'Exporter';

use constant;

use constant ORTHOXML_VERSION_ATTR => "version";
use constant NOTE_TAG =>"notes";

use constant ORTHOXML_NAMESPACE_02 => "http://orthoXML.org/0.2/";
use constant ORTHOXML_NAMESPACE_2011 => "http://orthoXML.org/2011/";
use constant ORTHOXML_SCHEMALOCATION => "http://www.orthoxml.org/%1.1f/orthoxml.xsd";

use constant ORTHOXML_TAG => "orthoXML";
use constant SPECIES_TAG => "species";
use constant DATABASE_TAG => "database";
use constant GENES_TAG => "genes";
use constant GENE_TAG => "gene";
use constant GROUPS_TAG => "groups";
use constant ORTHOLOG_GROUP_TAG => "orthologGroup";
use constant PARALOG_GROUP_TAG => "paralogGroup";
use constant GROUPS_TAG_01 => "clusters";
use constant ORTHOLOG_GROUP_TAG_01 => "cluster";
use constant GENE_REF_TAG => "geneRef";
use constant SCORE_DEFS_TAG_2011 =>"scores";
use constant SCORE_DEFS_TAG => "scoreDefs";
use constant SCORE_DEF_TAG => "scoreDef";
use constant SCORE_TAG => "score";
use constant PROPERTY_DEFS_TAG => "propertyDefs";
use constant PROPERTY_DEF_TAG => "propertyDef";
use constant PROPERTY_TAG => "property";


use constant ORTHOXML_ORIGIN_ATTR => "origin";
use constant ORTHOXML_ORIGINVERSION_ATTR => "originVersion";
use constant GENE_INTERNAL_ID_ATTR => "id";
use constant GENE_PROT_ID_ATTR => "protId";
use constant GENE_GENE_ID_ATTR => "geneId";
use constant GENE_REF_ATTR => "id";
use constant GENE_TRANSCRIPT_ID_ATTR => "transcriptId";
use constant TAX_ID_ATTR => "NCBITaxId";
use constant SPECIES_NAME_ATTR => "name";
use constant SCORE_REF_ATTR_2011 => "id";
use constant SCORE_REF_ATTR => "name";
use constant SCORE_VALUE_ATTR => "value";
use constant DATABASE_VERSION_ATTR => "version";
use constant DATABASE_NAME_ATTR => "name";
use constant DATABASE_GENE_LINK_ATTR => "geneLink";
use constant DATABASE_TRANSCRIPT_LINK_ATTR => "transcriptLink";
use constant DATABASE_PROTEIN_LINK_ATTR => "protLink";
use constant SCORE_DEF_ID_ATTR_2011 => "id";
use constant SCORE_DEF_ID_ATTR => "name";
use constant SCORE_DEF_DESCRIPTION_ATTR => "desc";
use constant GROUP_ID_ATTR => "id";
use constant PROPERTY_KEY_ATTR => "name";
use constant PROPERTY_VALUE_ATTR => "value";
use constant PROPERTY_DEF_ID_ATTR => "name";
use constant PROPERTY_DEF_DESCRIPTION_ATTR => "desc";

#our @EXPORT_OK = ('CONST');

1;

