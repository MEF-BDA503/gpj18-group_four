***
### Group Members
[Büşra Koç](https://mef-bda503.github.io/pj18-busraakoc/) 	&	 [Emre Kemerci](https://mef-bda503.github.io/pj18-EmreKemerci/)		&	 [Muharrem Çakır](https://mef-bda503.github.io/pj18-muharremcakir81/)	&	[Ömer Bayır](https://mef-bda503.github.io/pj18-omerbayir/) 	&	[Salih Uçar](https://mef-bda503.github.io/pj18-ucarsal/)

***
### Project Proposal
We will export trade data of Turkey from [trademap.org](https://www.trademap.org/) website which provides trade statistics for international business development.


Our aim is to analyze Turkey's trade characteristics by product groups against 10 selected countries (G7 countries and Russia, India, China) and to summarize the Turkey's overall trade statistics in this frame.


We will start with exporting total annual value of export and import of Turkey and quantities by product group against the target selected countries in the website. These data will include 5 years period from 2013 to 2017.
Secondly, since the exported data are consist of 40 excel files (10 countries(trade against 10 countries) * 2 trade type (export and import) * 2 metric (trade value and trade quantity)), we will combine these files.
Then, we will clean the data if needed and finally, we will analyze the data.


Through the analysis and visualization of the data, our object is to use explanatory analysis and visualization skills with data manipulation functions of like dplyr, reshape etc and visualition tools like ggplot, shiny and any other packages we will explore.

***
### A Summary of the Data and Explanations       
Following the extraction from source (Trademap.org), our raw data consist of 10 countries' trade data against Turkey. This data splits to 2 with trade direction as "Export" and "Import". The other dimension is stat for trade, one is "Quantity" of Export/Import, the other is "Value" in billion USD of Export/Import. Therefore we have four main table for each country.


<table>
<thead>
<tr class="header">
<th align="left">Data Frame</th>
<th align="left">DF Definition</th>
</tr>
</thead>

<tbody>
<tr class="odd">
<td align="left">ExportValues</td>
<td align="left">Export from Turkey to target countries and their values in billion USD</td>
</tr>
<tr class="odd">
<td align="left">ExportQuantity</td>
<td align="left">Export from Turkey to target countries and their quantities in units(tons,gallons etc)</td>
</tr>
<tr class="odd">
<td align="left">ImportValues</td>
<td align="left">Import to Turkey from target counties and their values in billion USD</td>
</tr>
<tr class="odd">
<td align="left">ImportQuantity</td>
<td align="left">Import to Turkey from target counties and their quantities in units(tons,gallons etc)</td>
</tr>
  
</tbody>
</table> 


Table structures for "Quantity" and "Value" files are as follows:


<table>
<thead>
<tr class="header">
<th align="left">Country</th>
<th align="left">Product code</th>
<th align="left">Product label</th>
<th align="left">Quantity in 2013</th>
<th align="left">Unit</th>
<th align="left">Quantity in 2014</th>
<th align="left">Unit</th>
<th align="left">Quantity in 2015</th>
<th align="left">Unit</th>
<th align="left">Quantity in 2016</th>
<th align="left">Unit</th>
<th align="left">Quantity in 2017</th>
<th align="left">Unit</th>
</tr>
</thead>

<tbody>
<tr class="odd">
<td align="left">France</td>
<td align="left">'0306</td>
<td align="left">Crustaceans, whether in shell or not, live, fresh, chilled, frozen, dried, salted or in brine, ...</td>
<td align="left">121</td>
<td align="left">Tons</td>
<td align="left">139</td>
<td align="left">Tons</td>
<td align="left">22</td>
<td align="left">Tons</td>
<td align="left">24</td>
<td align="left">Tons</td>

</tr>
</tbody>
</table>
			 	 		 	 
Table 1: Quantity excel table structure

<table>
<thead>
<tr class="header">
<th align="left">Country</th>
<th align="left">Product code</th>
<th align="left">Product label</th>
<th align="left">Value in 2013</th>
<th align="left">Value in 2014</th>
<th align="left">Value in 2015</th>
<th align="left">Value in 2016</th>
<th align="left">Value in 2017</th>
</tr>
</thead>

<tbody>
<tr class="odd">
<td align="left">France</td>
<td align="left">'0306</td>
<td align="left">Crustaceans, whether in shell or not, live, fresh, chilled, frozen, dried, salted or in brine, ...</td>
<td align="left">0</td>
<td align="left">1155</td>
<td align="left">1182</td>
<td align="left">270</td>
<td align="left">0</td>
</tr>
</tbody>
</table>

Table 2: Values excel table structure

In addition to main raw data, we also have look-up table for product codes; This lookup table registers product labels in 2 digit code that is less categorized than main data.

<table>
<thead>
<tr class="header">
<th align="left">Product code</th>
<th align="left">Product label</th>
</tr>
</thead>

<tbody>
<tr class="odd">
<td align="left">'01</td>
<td align="left">Live animals</td>
</tr>
<tr class="odd">
<td align="left">'02</td>
<td align="left">Meat and edible meat offal</td>
</tr>
<tr class="odd">
<td align="left">'03</td>
<td align="left">Fish and crustaceans, molluscs and other aquatic invertebrates</td>
</tr>
<tr class="odd">
<td align="left">'04</td>
<td align="left">Dairy produce; birds' eggs; natural honey; edible products of animal origin, not elsewhere ...</td>
</tr>
  
</tbody>
</table>

Table 3: Product look-up excel table


Regarding the variables included in these tables; definitions are as follows:  

<table>
<thead>
<tr class="header">
<th align="center" colspan="2">ExportQuantity & ImportQuantity</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Country</td>
<td align="left">Trade Partner of Turkey</td>
</tr>
<tr class="odd">
<td align="left">Product_Code</td>
<td align="left">Traded Product Code in 4 digit</td>
</tr>
<tr class="odd">
<td align="left">Product_Label</td>
<td align="left">Product Definition</td>
</tr>  
<tr class="odd">
<td align="left">Unit</td>
<td align="left">Metric of Quantity</td>
</tr>
<tr class="odd">
<td align="left">Quantity_2013</td>
<td align="left">Export or Import quantity in 2013</td>
</tr>
<tr class="odd">
<td align="left">Quantity_2014</td>
<td align="left">Export or Import quantity in 2014</td>
</tr>
<tr class="odd">
<td align="left">Quantity_2015</td>
<td align="left">Export or Import quantity in 2015</td>
</tr>
<tr class="odd">
<td align="left">Quantity_2016</td>
<td align="left">Export or Import quantity in 2016</td>
</tr>
<tr class="odd">
<td align="left">Quantity_2017</td>
<td align="left">Export or Import quantity in 2017</td>
</tr>  
</tbody>
</table>



<table>
<thead>
<tr class="header">
<th align="center" colspan="2">ExportValues & ImportValues</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Country</td>
<td align="left">Trade Partner of Turkey</td>
</tr>
<tr class="odd">
<td align="left">Product_Code</td>
<td align="left">Traded Product Code in 4 digit</td>
</tr>
<tr class="odd">
<td align="left">Product_Label</td>
<td align="left">Product Definition</td>
</tr>  
<tr class="odd">
<td align="left">Value_2013</td>
<td align="left">Export or Import value in 2013</td>
</tr>
<tr class="odd">
<td align="left">Value_2014</td>
<td align="left">Export or Import value in 2014</td>
</tr>
<tr class="odd">
<td align="left">Value_2015</td>
<td align="left">Export or Import value in 2015</td>
</tr>
<tr class="odd">
<td align="left">Value_2016</td>
<td align="left">Export or Import value in 2016</td>
</tr>
<tr class="odd">
<td align="left">Value_2017</td>
<td align="left">Export or Import value in 2017</td>
</tr>
</tbody>
</table>


Quantity and Value data tables have relation with each other via two fields: Country and ProductCode


After joining these data tables, and cleaning unnecessary columns; finally we have Export data of Turkey as quantity and value and Import data of Turkey as quantity and value in same structure. 


<table>
<thead>
<tr class="header">
<th align="left">Country</th>
<th align="left">Product code</th>
<th align="left">Unit</th>
<th align="left">Product label</th>
<th align="left">Quantity_2013</th>
<th align="left">Quantity_2014</th>
<th align="left">Quantity_2015</th>
<th align="left">Quantity_2016</th>
<th align="left">Quantity_2017</th>
<th align="left">Product_Label</th>
<th align="left">Value_2013</th>
<th align="left">Value_2014</th>
<th align="left">Value_2015</th>
<th align="left">Value_2016</th>
<th align="left">Value_2017</th>
<th align="left">PcodeTwo</th>
<th align="left">X__2</th>
</tr>
</thead>
</table>



Both of the export table and import table have 16 variables and 12,220 observations.


Country, Product_Code, Unit, Product_Label, PcodeTwo and X__2 variables are string while remaining variables are numeric.
PcodeTwo is two digit product and X__2 is a summary label for product definition.

