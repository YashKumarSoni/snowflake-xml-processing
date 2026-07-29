XML Data Exchange Solution 

1) The snowflake-xml-processing solution converts the relational data or tabular data to XML nested format following XSD schema in a particular format.
2) The current snowflake data download mechanism does not allow us to directly convert relational data into xml.
3) The solution is a 4-step process 
    a.) XML File generation 
    b.) File Validation based tag structure  
    c.) For each correct set of records Valid & Invalid file creation. 
    d.) Finally the valid file to be placed in an internal AWS S3 stage.
4) This solution fills the gap.

