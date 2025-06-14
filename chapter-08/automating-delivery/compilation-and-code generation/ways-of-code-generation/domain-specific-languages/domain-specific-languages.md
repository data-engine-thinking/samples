# Domain-Specific Languages

## A DSL example
This can be demonstrated with a sample template script that uses the Biml DSL. Consider the code below, a mixture of C# and the template using Biml (XML) syntax.

```XML
<Biml xmlns="http://schemas.varigence.com/biml.xsd">
var mappingList = new List<DataObjectMappings>();
var allFiles = Directory.GetFiles(@"<directory containing JSON files>");
foreach (var fileName in allFiles)
{
   // Fetch the content of the Json files
   string jsonInput = File.ReadAllText(fileName);
   var deserialisedMappings = JsonConvert.DeserializeObject<DataObjectMappings>(jsonInput);
   mappingList.Add(deserialisedMappings);
    }
    #>
   <Packages>
      <#
      foreach (var dataObjectMappings in mappingList)
      {
         int counter = 1;
         foreach (var dataObjectMapping in dataObjectMappings.dataObjectMappings.ToList())
         {
         #>
   <Package Name="<#=dataObjectMapping.name#><#=counter#>">
     <Tasks>
       <Dataflow Name="DF - <#=dataObjectMapping.name#><#=counter#> - 1">
       </Dataflow>
       <Dataflow Name="DF - <#=dataObjectMapping.name#><#=counter#> - 2">
		    <PrecedenceConstraints>
				<Inputs>
              <Input OutputPathName="DF - <#=dataObjectMapping.name#><#=counter#> - 1.Output" />
				</Inputs>
			</PrecedenceConstraints>
        </Dataflow>
       </Tasks>
      </Package>
          <#
          counter++;
         }
      }
      #>
   </Packages>
</Biml>
```