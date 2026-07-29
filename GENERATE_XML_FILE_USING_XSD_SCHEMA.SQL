CREATE OR REPLACE PROCEDURE GENERATE_XML_FILE_USING_XSD_SCHEMA()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main'
EXECUTE AS OWNER
AS '

import snowflake.snowpark as snowpark 
import xml.etree.ElementTree as ET 
from xml.dom import minidom
from snowflake.snowpark.files import SnowflakeFile
from collections import defaultdict
import random
import string
import time
from datetime import date

def main(session: snowpark.Session): 
    # Your code goes here, inside the "main" handler.
    schema_name= "SCHEMA_NAME"
    table_name = "TABLE_OR_VIEW_NAME"
    df = session.table(f"{schema_name}.{table_name}")

    xml_file = generate_xml(session,df) 
   
    #scoped url for the xml file
    return xml_file

def generate_xml(session,df):

    tmp_file_name = "/tmp/TEST.xml" # str(os.getpid())  unique file name using process ID
    root = ET.Element("ROOT_ELEMENT") # The parent tag or root tag

    #xml schema
    schema = ET.SubElement(root, "xs:schema", attrib={
        "xmlns:acf" : "http://www.acf.hhs.gov",
        "xmlns:xs" : "http://www.w3.org/2001/XMLSchema",
        "xmlns:vc" : "http://www.w3.org/2007/XMLSchema-versioning",
        "vc:minVersion":"1.1"
    })

        
    data_element = ET.SubElement(schema,"data")
    
    first_row = None
    
    # STREAM rows instead of collect()
    grouped = defaultdict(list)
    
    for row in df.to_local_iterator():
        if first_row is None:
            first_row = row
        grouped[row["USER_ID"]].append(row)
	
    ET.SubElement(data_element, "FIELD_1").text = str(first_row["FIELD_1"])
    ET.SubElement(data_element, "FIELD_2").text = str(first_row["FIELD_2"])

    
	
    	
		
    if not first_row:
        return "No data found"
	
    records = ET.SubElement(data_element,"records")

    for child_id, child_rows in grouped.items():
        first = child_rows[0]
        record  = ET.SubElement(records, "record")

        ET.SubElement(record, "FIELD_3").text = str(first["USER_ID"])
        ET.SubElement(record, "FIELD_4").text = str(first["FIELD_4"])

        # The subsequent fields goes here 

         """    
                .
                .
                . 
                
                """
        
        

    xml_string = ET.tostring(root,encoding="utf-8").decode("utf-8")
    pretty_xml_string = minidom.parseString(xml_string).toprettyxml(indent="   ")
       
    xml_file = SnowflakeFile.open_new_result("w") # Open a new result file
    xml_file.write(pretty_xml_string)
    
    lines  = pretty_xml_string.splitlines()

    data = [(line,) for line in lines]

    xml_df  = session.create_dataframe(data, schema=["XML_DATA"])


    

    # keep only latest run data in the target table
    session.sql(f"TRUNCATE TABLE < TARGET TABLE NAME GOES HERE> ").collect()
    
    xml_df.write.mode("overwrite").save_as_table("SCHEMA_NAME.TARGET_TABLE_NAME")
    
    return xml_file
';
