<!DOCTYPE html>
<%@page import="java.sql.*"%>
<%@page import="Zql.*"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.BufferedWriter"%>
<%@page import="java.io.DataInputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileNotFoundException"%>
<%@page import="java.io.FileWriter"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.RandomAccessFile"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.TreeMap"%>
<script src="http://d3js.org/d3.v2.js"></script>
<html>
<head>
<style>
.page{
	width:1000px;
}
.left{
	width: 400px;
	float: left;
}
.right{
	width: 400px;
	float: left;
}
</style>

<script type = "text/javascript">
	function SubmitQuery(){
			showResults();
			document.forms['submit_query_form'].action='testpg.jsp';
			document.forms['submit_query_form'].target ='origin_db_result';
			document.forms['submit_query_form'].submit();
		
			document.forms['submit_query_form'].action='testpg_sample.jsp';
			document.forms['submit_query_form'].target ='sample_db_result';
			document.forms['submit_query_form'].submit();
	}
	
	function showResults(){
		var results = document.getElementById('resultContainer');
		results.style.display="";
	}
	
	function hideResults(){
		var results = document.getElementById('resultContainer');
		results.style.display='none';
	}
	
</script>
</head>


<div id="container" style="width:900px">
<body onload='hideResults()'>

<!--  loading data -->
<%
		String tuple;
		Integer k = 0;
		Integer v = 0;
		//low	
		String filePathL = application.getRealPath("FreqLow");
		BufferedReader brL = new BufferedReader(new FileReader(filePathL));
		int[] frequenciesLow = new int[10000];
		
		//get the hashmap...
		while ((tuple = brL.readLine()) != null) {
			String[] tuples = tuple.split(" ");
			k = Integer.parseInt(tuples[0]);
			v = Integer.parseInt(tuples[1]);
			frequenciesLow[k] = v;
		}
		
		//mid
		String filePathM = application.getRealPath("FreqMid");
		BufferedReader brM = new BufferedReader(new FileReader(filePathM));
		int[] frequenciesMid = new int[10000];
		//get the hashmap...
		while ((tuple = brM.readLine()) != null) {
			String[] tuples = tuple.split(" ");
			k = Integer.parseInt(tuples[0]);
			v = Integer.parseInt(tuples[1]);
			frequenciesMid[k] = v;
		}
		//high
		String filePathH = application.getRealPath("FreqHigh");
		BufferedReader brH = new BufferedReader(new FileReader(filePathH));
		int[] frequenciesHigh = new int[10000];
		//get the hashmap...
		while ((tuple = brH.readLine()) != null) {
			String[] tuples = tuple.split(" ");
			k = Integer.parseInt(tuples[0]);
			v = Integer.parseInt(tuples[1]);
			frequenciesHigh[k] = v;
		}
		
		//original
		String filePathO = application.getRealPath("FreqO");
		BufferedReader brO = new BufferedReader(new FileReader(filePathO));
		int[] frequenciesOigh = new int[10000];
		//get the hashmap...
		while ((tuple = brO.readLine()) != null) {
			String[] tuples = tuple.split(" ");
			k = Integer.parseInt(tuples[0]);
			v = Integer.parseInt(tuples[1]);
			frequenciesOigh[k] = v;
		}
	%>

	<script type="text/javascript">
		
	<%-- assign JSP array to javascript array once for ever! --%>
	var squeezedFrequencyMapLow = new Array(100);
	<%-- Squeeze the matrix to 10 * 10 --%>
	<%int frequencyCount = 0;%>
	<%for (int i = 0; i < 10000; i++) {%>
	<%frequencyCount += frequenciesLow[i];%>
	<%if ( (i+1) % 100 == 0) {%>
	<%int s = i / 100;%>
		squeezedFrequencyMapLow[
	<%=s%>
		] = [
	<%=(int) s / 10%>
		,
	<%=(int) s % 10%>
		,
	<%=frequencyCount%>
		];
	<%frequencyCount = 0;%>
	<%}%>
	<%}%>

	var squeezedFrequencyMapMid = new Array(100);
	<%-- Squeeze the matrix to 10 * 10 --%>
	<%frequencyCount = 0;%>
	<%for (int i = 0; i < 10000; i++) {%>
	<%frequencyCount += frequenciesMid[i];%>
	<%if ( (i+1) % 100 == 0) {%>
	<%int s = i / 100;%>
		squeezedFrequencyMapMid[
	<%=s%>
		] = [
	<%=(int) s / 10%>
		,
	<%=(int) s % 10%>
		,
	<%=frequencyCount%>
		];
	<%frequencyCount = 0;%>
	<%}%>
	<%}%>
	
	var squeezedFrequencyMapHigh = new Array(100);
	<%-- Squeeze the matrix to 10 * 10 --%>
	<%frequencyCount = 0;%>
	<%for (int i = 0; i < 10000; i++) {%>
	<%frequencyCount += frequenciesHigh[i];%>
	<%if ( (i+1) % 100 == 0) {%>
	<%int s = i / 100;%>
		squeezedFrequencyMapHigh[
	<%=s%>
		] = [
	<%=(int) s / 10%>
		,
	<%=(int) s % 10%>
		,
	<%=frequencyCount%>
		];
	<%frequencyCount = 0;%>
	<%}%>
	<%}%>
	
	var squeezedFrequencyMapOigh = new Array(100);
	<%-- Squeeze the matrix to 10 * 10 --%>
	<%frequencyCount = 0;%>
	<%for (int i = 0; i < 10000; i++) {%>
	<%frequencyCount += frequenciesOigh[i];%>
	<%if ( (i+1) % 100 == 0) {%>
	<%int s = i / 100;%>
		squeezedFrequencyMapOigh[
	<%=s%>
		] = [
	<%=(int) s / 10%>
		,
	<%=(int) s % 10%>
		,
	<%=frequencyCount%>
		];
	<%frequencyCount = 0;%>
	<%}%>
	<%}%>
	</script>

<h1 style="text-align:center"> <a href="http://www.cs.brown.edu"><img src="brown-university.jpg" border = "0" width="170" height="80" align="left"/> </a>
<br/> SqueezeDB </h1>
<hr />
<p>SqueezeDB System is a data sampling system basing on the theory of 
<a href=http://arxiv.org/pdf/1101.5805.pdf>VC-Dimension</a>. <br/> This webpage provides an interface for user or researchers to test the performance of SqueezeDB.</p>
<ul>
<b>The main features SqueezeDB system provides include:</b>
	<li id="Accuracy">
		Super fast with high accuracy.
	</li>
	<li id="Quick">
		Sample once offline, being reused many times.
	</li>
	<li id="User Specification">
		Allow users to specify the expected accuracy upon their queries.
	</li>
	<li id = "Not relevant">
		Sample regardless of the size of the original database, but the max complexity of user's queries.
	</li>
	<li id = "D3">
		Use <a href=http://d3js.org/>D3</a> to visualize sample database information and query results.
	</li>
</ul>

<!--something-->
We have sampled the original "big" table which has 1,000,000 rows to three scales using the algorithm of VC-Dimension.</br>
The three sample tables has different sizes, in principle, table with bigger size will have more accurate estimation.
</br>Here are some visualized metadata about the sample datasets.</br>

<svg width="900" height="900">
	<svg id="solar" width="600" height="500" x="0" y="0">
	</svg>
	<svg id="oighFrequencyVis" width="300" height="350" x="600" y="150">
	</svg>
	<svg id="lowFrequencyVis" width="300" height="350" x="0" y="500">
	</svg>
	<svg id="midFrequencyVis" width="300" height="350" x="300" y="500">
	</svg>
	<svg id="highFrequencyVis" width="300" height="350" x="600" y="500">
	</svg>
</svg>
	<script>
	var center = 250;
	var planets = new Array(4);
	planets[0] = [ 100, 0, 0];
	planets[1] = [ 36, 120, 3e-2];
	planets[2] = [ 10,  170,  2e-2];
	planets[3] = [ 5,  185,  1e-2];
	var start = Date.now();
	var svg = d3.select("#solar");
	
	group = svg.append("svg:g").attr("transform", "translate(" + center + "," + 250 + ")scale(.8)")
				.attr("fill","hsl(207, 70%, 81%)");
	dataSizeToShow = group.append("svg:text").text("Dataset Size: NULL").attr("y", 300).attr("font-family", "Verdana")
	.attr("text-anchor", "middle")
	.attr("font-size",30).attr("fill","Red");
	
	planetsGroup = group.selectAll("circle").data(planets).enter()
	.append("circle").attr("cx", function(d) {
		return d[1];
	}).attr("cy", function(d) {
		return d[1];
	}).attr("fill", function(d) {
		if(d[0] == 100){
			return "hsl(0, 53%, 58%)";
		}
		else if(d[0] == 36){
			return "hsl(305, 70%, 45%)";
		}
		else if(d[0] == 10){
			return "hsl(57, 70%, 45%)";
		}
		else if(d[0] == 5){
			return "hsl(207, 70%, 52%)";
		}
	}).attr("r", function(d){
		return d[0];
	}).attr("stroke", "Orange").attr("stroke-width", function(d){
		return d[0] / 10;
	}).on("mouseover", function(d){
		this.parentNode.appendChild(this);
		d3.select(this).transition().delay(0).duration(300).attr("r",function(){
			return d[0] * 1.5;
		}).each("end", function(){
				d3.select(this).transition().delay(0).duration(500).
					attr("r",function(){
						return d[0];
					}).each("end", function(){
					d3.select(this).style("stroke", null);
				});	
			});
			dataSizeToShow.text(function(){
				if(d[0] == 100){
					return "Dataset Size: 1000000";
				}
				else if(d[0] == 36){
					return "Dataset Size: 18647";
				}
				else if(d[0] == 10){
					return "Dataset Size: 2984";
				}
				else if(d[0] == 5){
					return "Dataset Size: 1166";
				}
			}).attr("fill", function() {
				if(d[0] == 100){
					return "hsl(0, 53%, 58%)";
				}
				else if(d[0] == 36){
					return "hsl(305, 70%, 45%)";
				}
				else if(d[0] == 10){
					return "hsl(57, 70%, 45%)";
				}
				else if(d[0] == 5){
					return "hsl(207, 70%, 52%)";
				}
			});
			
			
	}).each(planetEnter);
	
	
	d3.timer(function() {
		  var elapsed = Date.now() - start;
		  var rotate = function(d) { 
			  return "rotate(" + d[2] * elapsed + ")"; };
		  planetsGroup.attr("transform", rotate);
	});
	
	
	function planetEnter(d,i){
		var n = Math.floor(2 * Math.PI * d[0] / Math.SQRT1_2),
	    k = 360 / n;
		d3.select(this).selectAll("g")
			.data(d3.range(n).map(function() { return d; }))
			.attr("transform", function(_, i) { return "rotate(" + i * k + ")translate(" + d[0] + ")"; })
			;
	}
	
	//bubble chart
	var svg = d3.select("#oighFrequencyVis");
		
				group = svg.append("svg:g");
				title = group.append("svg:text").text("DATASET").attr("x", 140).attr("y", 30).attr("font-family", "Verdana").attr("text-anchor", "middle")
					.attr("font-size",20).attr("fill","Orange");
				metadataRangeO = group.append("svg:text").text("Value Range: NULL").attr("x", 140).attr("y", 270).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				//metadata.text("wow");
				metadataFrequencyO = group.append("svg:text").text("Frequency: NULL").attr("x", 140).attr("y", 300).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				frequencyCircles = group.selectAll(".frequencyNode").data(squeezedFrequencyMapOigh).enter()
				.append("circle").attr("cx", function(d) {
					return d[1] * 20 + 50;
				}).attr("cy", function(d) {
					return d[0] * 20 + 50;
				}).attr("fill", function(d) {
					//var l =  (100 - (d[2] / 2.5));
					return "hsl(100, 10%, 50%)";
					//return "hsl(200, 10%, 0%)";
				}).attr("r", 10)
				.on("mouseover", function(d){
					//show the metadata
					metadataRangeO.text(function(){
						return "Value Range: [ " + 100 * (d[0]*10+d[1]) + " , " + 100 * (d[0]*10+d[1] + 1) + " ] ";
					});
					metadataFrequencyO.text(function(){
						return "Frequency: " + d[2];
					});
					this.parentNode.appendChild(this);
					d3.select(this).style("stroke", "Orange").style("fill", function(d){
								return "hsl(100, 10%, 50%)";
								});
					d3.select(this).transition().delay(0).duration(100).attr("r",20)
						.each("end", function(){
							d3.select(this).transition().delay(0).duration(300).
								attr("r",10).each("end", function(){
								d3.select(this).style("stroke", null);
							});	
						});
				})			
				.on("mouseout", function(){
					if(d3.select(this).attr("r") != 10){
						d3.select(this).transition().delay(0).duration(300).attr("r",10)
						.each("end",function(){
							d3.select(this).style("stroke", null).style("fill", function(d){
								return "hsl(100, 10%, 50%)";
								});
						});						
					}
					else{
						d3.select(this).style("fill", function(d){
							return "hsl(100, 10%, 50%)";
							});
					}
				})
				.on("mousedown", function(){
						
				});				
	
	var svg = d3.select("#highFrequencyVis");
		
				group = svg.append("svg:g");
				title = group.append("svg:text").text("HIGH ACCURACY").attr("x", 140).attr("y", 30).attr("font-family", "Verdana").attr("text-anchor", "middle")
					.attr("font-size",20).attr("fill","Orange");
				metadataRangeH = group.append("svg:text").text("Value Range: NULL").attr("x", 140).attr("y", 270).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				//metadata.text("wow");
				metadataFrequencyH = group.append("svg:text").text("Frequency: NULL").attr("x", 140).attr("y", 300).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				frequencyCircles = group.selectAll(".frequencyNode").data(squeezedFrequencyMapHigh).enter()
				.append("circle").attr("cx", function(d) {
					return d[1] * 20 + 50;
				}).attr("cy", function(d) {
					return d[0] * 20 + 50;
				}).attr("fill", function(d) {
					//return "hsl(200, " +  d[2] * 2  + "% ,50%)";
					var l =  (100 - (d[2] / 2.5));
					return "hsl(0, 10%, " + l + "%)";
					//return "hsl(200, 10%, 0%)";
				}).attr("r", 10)
				.on("mouseover", function(d){
					//show the metadata
					metadataRangeH.text(function(){
						return "Value Range: [ " + 100 * (d[0]*10+d[1]) + " , " + 100 * (d[0]*10+d[1] + 1) + " ] ";
					});
					metadataFrequencyH.text(function(){
						return "Frequency: " + d[2];
					});
					this.parentNode.appendChild(this);
					d3.select(this).style("stroke", "Orange").style("fill", function(d){
								var l = (100 - (d[2] / 2.5));
								return "hsl(0, 10%, " + l + "%)";
								});
					d3.select(this).transition().delay(0).duration(100).attr("r",20)
						.each("end", function(){
							d3.select(this).transition().delay(0).duration(300).
								attr("r",10).each("end", function(){
								d3.select(this).style("stroke", null);
							});	
						});
				})			
				.on("mouseout", function(){
					if(d3.select(this).attr("r") != 10){
						d3.select(this).transition().delay(0).duration(300).attr("r",10)
						.each("end",function(){
							d3.select(this).style("stroke", null).style("fill", function(d){
								var l = (100 - (d[2] / 2.5));
								return "hsl(0, 10%, " + l + "%)";
								});
						});						
					}
					else{
						d3.select(this).style("fill", function(d){
							var l = (100 - (d[2] / 1.5));
							return "hsl(0, 10%, " + l + "%)";
							});
					}
				})
				.on("mousedown", function(){
						
				});		
				
				
	
	
	var svg = d3.select("#midFrequencyVis");

				group = svg.append("svg:g");
				title = group.append("svg:text").text("MID ACCURACY").attr("x", 140).attr("y", 30).attr("font-family", "Verdana").attr("text-anchor", "middle")
					.attr("font-size",20).attr("fill","Orange");
				metadataRangeM = group.append("svg:text").text("Value Range: NULL").attr("x", 140).attr("y", 270).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				//metadata.text("wow");
				metadataFrequencyM = group.append("svg:text").text("Frequency: NULL").attr("x", 140).attr("y", 300).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				frequencyCircles = group.selectAll(".frequencyNode").data(squeezedFrequencyMapMid).enter()
				.append("circle").attr("cx", function(d) {
					return d[1] * 20 + 50;
				}).attr("cy", function(d) {
					return d[0] * 20 + 50;
				}).attr("fill", function(d) {
					//return "hsl(200, " +  d[2] * 2  + "% ,50%)";
					var l =  (100 - (d[2] / 1.5));
					return "hsl(0, 10%, " + l + "%)";
					//return "hsl(200, 10%, 0%)";
				}).attr("r", 10)
				.on("mouseover", function(d){
					//show the metadata
					metadataRangeM.text(function(){
						return "Value Range: [ " + 100 * (d[0]*10+d[1]) + " , " + 100 * (d[0]*10+d[1] + 1) + " ] ";
					});
					metadataFrequencyM.text(function(){
						return "Frequency: " + d[2];
					});
					this.parentNode.appendChild(this);
					d3.select(this).style("stroke", "Orange").style("fill", function(d){
								var l = (100 - (d[2] / 1.5));
								return "hsl(0, 10%, " + l + "%)";
								});
					d3.select(this).transition().delay(0).duration(100).attr("r",20)
						.each("end", function(){
							d3.select(this).transition().delay(0).duration(300).
								attr("r",10).each("end", function(){
								d3.select(this).style("stroke", null);
							});	
						});
				})			
				.on("mouseout", function(){
					if(d3.select(this).attr("r") != 10){
						d3.select(this).transition().delay(0).duration(300).attr("r",10)
						.each("end",function(){
							d3.select(this).style("stroke", null).style("fill", function(d){
								var l = (100 - (d[2] / 1.5));
								return "hsl(0, 10%, " + l + "%)";
								});
						});						
					}
					else{
						d3.select(this).style("fill", function(d){
							var l = (100 - (d[2] / 1.5));
							return "hsl(0, 10%, " + l + "%)";
							});
					}
				})
				.on("mousedown", function(){
						
				});		
	
	
	svg = d3.select("#lowFrequencyVis");
				
	group = svg.append("svg:g");
				title = group.append("svg:text").text("LOW ACCURACY").attr("x", 140).attr("y", 30).attr("font-family", "Verdana").attr("text-anchor", "middle")
					.attr("font-size",20).attr("fill","Orange");
				metadataRangeL = group.append("svg:text").text("Value Range: NULL").attr("x", 140).attr("y", 270).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				//metadata.text("wow");
				metadataFrequencyL = group.append("svg:text").text("Frequency: NULL").attr("x", 140).attr("y", 300).attr("font-family", "Verdana").attr("text-anchor", "middle")
				.attr("font-size",15).attr("fill","Red");
				frequencyCircles = group.selectAll(".frequencyNode").data(squeezedFrequencyMapLow).enter()
				.append("circle").attr("cx", function(d) {
					return d[1] * 20 + 50;
				}).attr("cy", function(d) {
					return d[0] * 20 + 50;
				}).attr("fill", function(d) {
					//return "hsl(200, " +  d[2] * 2  + "% ,50%)";
					var l =  (100 - (d[2] / 1.5));
					return "hsl(0, 10%, " + l + "%)";
					//return "hsl(200, 10%, 0%)";
				}).attr("r", 10)
				.on("mouseover", function(d){
					//show the metadata
					metadataRangeL.text(function(){
						return "Value Range: [ " + 100 * (d[0]*10+d[1]) + " , " + 100 * (d[0]*10+d[1] + 1) + " ] ";
					});
					metadataFrequencyL.text(function(){
						return "Frequency: " + d[2];
					});
					this.parentNode.appendChild(this);
					d3.select(this).style("stroke", "Orange").style("fill", function(d){
								var l = (100 - (d[2] / 1.5));
								return "hsl(0, 10%, " + l + "%)";
								});
					d3.select(this).transition().delay(0).duration(100).attr("r",20)
						.each("end", function(){
							d3.select(this).transition().delay(0).duration(300).
								attr("r",10).each("end", function(){
								d3.select(this).style("stroke", null);
							});	
						});
				})			
				.on("mouseout", function(){
					if(d3.select(this).attr("r") != 10){
						d3.select(this).transition().delay(0).duration(300).attr("r",10)
						.each("end",function(){
							d3.select(this).style("stroke", null).style("fill", function(d){
								var l = (100 - (d[2] / 1.5));
								return "hsl(0, 10%, " + l + "%)";
								});
						});						
					}
					else{
						d3.select(this).style("fill", function(d){
							var l = (100 - (d[2] / 1.5));
							return "hsl(0, 10%, " + l + "%)";
							});
					}
				});				
				
				
	
</script>	


<form id="submit_query_form" method ="POST">
<br>
<div id="sqlInput_div" style="height:200px;width:500px;float:left;">
<script type="text/javascript"> 

function ShowInfo() { 
var oDiv = document.getElementById("Text1"); 

if (oDiv.value == "") { 
oDiv.value = "Please input your SQL query."; 
} 
else { 
oDiv.style.borderColor = "black"; 
} 
} 
</script> 

<textarea id="Text1" rows="10" cols="30" name="sqlInput" onfocus="this.value='';" onblur="ShowInfo();">
Please input your SQL query
</textarea>
</div>
<div id="accuracyInput_div" style="height:200px;width:400px;float:left;relative: absolute; left: 100px; top: 100px;">
Please select your expected query accuracy. <br>
<input type="radio" name ="accuracy" value ="highAccuracy" input checked="checked"> High Accuracy <br>
<input type="radio" name ="accuracy" value ="middleAccuracy"> Middle Accuracy <br>
<input type="radio" name ="accuracy" value ="lowAccuracy"> Low Accuracy <br>
</div>
</br>
<input type= "button" value="Submit" name="Submit" onclick='javascript:return SubmitQuery()' 
/>

<br>

</form>

	<!-- iframe for showing -->
	<div id="resultContainer">
	<div class="left">
		 <iframe name="origin_db_result" src="testpg.jsp"  scrolling="yes" height="300px" width="400px"></iframe>
	</div>
	<div class="right">
		 <iframe name="sample_db_result" src="testpg_sample.jsp"  scrolling="yes" height="300px" width="400px" ></iframe>
	</div>
	</div>

</body>
</div>
</html>