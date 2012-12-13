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



<%@page import="Offline.DatabaseSampler"%>
<%@page import="Offline.OfflineDriver"%>
<%@page import="Offline.OfflineDriverMultiTables"%>
<%@page import="Online.AggregatorPair"%>
<%@page import="Online.ResultToShow"%>
<%@page import="java.util.Properties"%>
<%@page import="ilog.concert.IloException"%>
<%@page import="ilog.concert.IloNumExpr"%>
<%@page import="ilog.concert.IloNumVar"%>
<%@page import="ilog.cplex.IloCplex"%>
<%@page import="Online.*" language="java" pageEncoding="utf-8"%>

<script src="http://d3js.org/d3.v2.js"></script>
<html>
<head>
<script>
	function showResultsCompare(titleString, results){
		var maxHeight = 240;
		var ceiling = 250;
		var heightRatio = results[3] / 210;
		var svg = d3.select("body").append("svg").attr("width", 300)
			.attr("height", 350);
		group = svg.append("svg:g");
		var title = group.append("svg:text").text(titleString).attr("x", 140).attr("y", 30).attr("font-family", "Verdana").attr("text-anchor", "middle")
		.attr("font-size",20).attr("fill","Orange");
		var resultTypeText = group.append("svg:text").text("Result Type: NULL").attr("x", 140).attr("y", 270).attr("font-family", "Verdana").attr("text-anchor", "middle")
		.attr("font-size",15).attr("fill","Red");
		var resultValueText = group.append("svg:text").text("Result Value: NULL").attr("x", 140).attr("y", 300).attr("font-family", "Verdana").attr("text-anchor", "middle")
		.attr("font-size",15).attr("fill","Red");
		
		resultBars = group.selectAll("rect").data(results).enter()
					.append("rect")
					.attr("x", function(d,i){
						return i * 40 + 60;
					})
					.attr("y", function(d){
						return ceiling - d / heightRatio;
					})
					.attr("rx", 5)
					.attr("ry", 5)
					.attr("width", 35)
					.attr("height", function(d){
						return d / heightRatio;
					})
					.attr("fill", function(d,i){
						return "hsl(210, 100%, " + (i * 10 + 20) + "%)";
					})
					.on("mouseover", function(d,i){
						resultTypeText.text(function(){
							if(i == 0 )
								return "Result Type: ACTUAL";
							else if(i == 1)
								return "Result Type: ESTIMATE";
							else if(i == 2)
								return "Result Type: LOW BOUND";
							else if(i == 3)
								return "Result type: HIGH BOUND";
						});
						
						resultValueText.text(function(){
							return "Result Value: " + d;
						})
						
						d3.select(this).transition().delay(0).duration(500)
							.attr("fill", "red");
					})
					.on("mouseout", function(d,i){
						d3.select(this).transition().delay(0).duration(500)
						.attr("fill", function(){
							return "hsl(210, 100%, " + (i * 10 + 20) + "%)";
						})
					})
					;
	}
</script>
</head>
<body>
<script type="text/javascript">
	<%
		Vector<String> v = (Vector<String>) application.getAttribute("result_dataset");
		ResultSetMetaData rsmd;
		rsmd = (ResultSetMetaData) application.getAttribute("data_test");
		EstimatedResult er;
		er = (EstimatedResult) application.getAttribute("sample_data_test");
		int cols = rsmd.getColumnCount();
		
		//regenerate the data structure
		Vector<ResultToShow> toShows = ResultToShow.getResultsToShow(v, er);
		Iterator<ResultToShow> it = toShows.iterator();
	%>	
	<%
		while(it.hasNext()){
			ResultToShow show = it.next(); 
			String s = show.aggregatorName;%>
			var results = new Array(4);
			results[0] = <%=show.actualValue%>
			results[1] = <%=show.estimatedValue%>
			results[2] = <%=show.lowerBound%>
			results[3] = <%=show.upperBound%>
			<% if(s.equals("AVG")){ %>
				showResultsCompare("AVG",results);
			<%}%>
			<% if(s.equals("SUM")){ %>
				showResultsCompare("SUM",results);
			<%}%>
			<% if(s.equals("VAR")){ %>
				showResultsCompare("VAR",results);
			<%}%>
			<% if(s.equals("COUNT")){ %>
				showResultsCompare("COUNT",results);
			<%}%>
	<%
	}
	%>
	

	

</script>
</body>
</html>