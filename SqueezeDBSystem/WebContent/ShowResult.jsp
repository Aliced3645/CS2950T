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
<%@page import="java.util.Properties"%>
<%@page import="ilog.concert.IloException"%>
<%@page import="ilog.concert.IloNumExpr"%>
<%@page import="ilog.concert.IloNumVar"%>
<%@page import="ilog.cplex.IloCplex"%>
<%@page import="Online.*" language="java" pageEncoding="utf-8"%>

<script src="http://d3js.org/d3.v2.js"></script>
<html>
<head>
</head>
<body>
<h1>success</h1>

<% 


	String str1,str2, huihui;
	
	str1 = (String)session.getAttribute("s1");
	str2 = (String)session.getAttribute("s2");	
	
	//application.removeAttribute("s1");
	//application.removeAttribute("s2");
	
	//ResultSet rs;
	//rs = (ResultSet)application.getAttribute("result_set");
	Vector<String> v =  (Vector<String>) application.getAttribute("result_dataset");
//	if(v != null){
		int size = v.size();
		String test = "";
		for(int i = 0; i<v.size() ;i++)
			test = test + v.get(i);
//	}
	    ResultSetMetaData rsmd;
		rsmd = (ResultSetMetaData)application.getAttribute("data_test");
			
		EstimatedResult er;
		er = (EstimatedResult)application.getAttribute("sample_data_test");
		
		huihui = str1 + " " + str2;
		
		int cols = rsmd.getColumnCount();
	
%>

<h2><%=test %></h2>

	<div>
	<table border='6' style="margin-bottom: 20px; margin-top: 20px; float:left ; margin-left: 50px; margin-right: 50px">
	
		<tr>
			<%for(int i = 1; i <= cols; i++) {%>
			<th><%=rsmd.getColumnName(i)%></th>
			<%}%>
		</tr>
		<br\>		
		<tr>
			<%
				ListIterator<String> iter = v.listIterator();
				while(iter.hasNext()) {%>
				<%
				String ans = (String)iter.next();
				%>
				<td><%=ans%></td>
			<%}%>
		</tr>
	
	</table>
	</div>
	
	<div>
	<table border='6' style="float: left">
	
			<tr>
			<th>Estimated Aggregator</th>
			<% Iterator<String> its = er.aggregateName.iterator();
				while(its.hasNext()){
					String aggregatename = its.next(); %>	
				<th>Estimated <%=aggregatename %></th>
			<% }%>
		</tr>
		<br\>
		
		<tr>
			<th>Estimated Value</th>
			<% Iterator<Double> itd = er.estimatedValue.iterator();
				while(itd.hasNext()){
					double answer = itd.next(); %>	
				<th><%=(long)answer%></th>
			<% }%>
		</tr>
		<br\>
		
		<tr>
			<th>Lower Bound</th>
			<% Iterator<Double> itl = er.lowerBound.iterator();
				while(itl.hasNext()){
					double answer = itl.next(); %>	
				<th><%=(long)answer%></th>
			<% }%>
		</tr>
		<br\>
		
		<tr>
			<th>Upper Bound</th>
			<% Iterator<Double> itu = er.upperBound.iterator();
				while(itu.hasNext()){
					double answer = itu.next(); %>	
				<th><%=(long)answer%></th>
			<% }%>
		</tr>
		<br\>
		
	</table>
	</div>
	
	
	
</body>
</html>