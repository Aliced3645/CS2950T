<%@page import="Offline.DatabaseSampler"%>
<%@page import="Offline.OfflineDriver"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.Properties"%>
<%@page import="ilog.concert.IloException"%>
<%@page import="ilog.concert.IloNumExpr"%>
<%@page import="ilog.concert.IloNumVar"%>
<%@page import="ilog.cplex.IloCplex"%>
<%@page import="Online.*" language="java" pageEncoding="utf-8"%>
<%--@page import="Online.Avg" language="java" pageEncoding="utf-8"--%>
<%--@page import="Online.Sum" language="java" pageEncoding="utf-8"--%>

<%--@page errorPage="SyntexErr.jsp"--%>

<html>
<body>

	<%
		Class.forName("org.postgresql.Driver").newInstance();
		String db_url = "jdbc:postgresql://db.cs.brown.edu/squeezedb";
		String db_user = "szhang";
		String db_pw = "36453645Zs";
		Connection conn = DriverManager.getConnection(db_url, db_user,
				db_pw);
		Statement stmt = conn
				.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		String originSQL = request.getParameter("sqlInput");
		String inputRadio = request.getParameter("accuracy");
		int sampleSize;
		double epsilon = 0;
		String tableName;
		int lineNumber;
		if (!inputRadio.isEmpty()) {
			if (inputRadio.equals("highAccuracy")) {
				tableName = OfflineDriver.sampleTableHigh;
				lineNumber = OfflineDriver.sampleRowNumberHigh;
				epsilon = 0.2;
			} else if (inputRadio.equals("middleAccuracy")) {
				tableName = OfflineDriver.sampleTableMid;
				lineNumber = OfflineDriver.sampleRowNumberMid;
				epsilon = 0.5;
			} else if (inputRadio.equals("lowAccuracy")) {
				tableName = OfflineDriver.sampleTableLow;
				lineNumber = OfflineDriver.sampleRowNumberLow;
				epsilon = 0.8;
			} else {
				tableName = "bigdata";
				lineNumber = 1000000;
			}
		}
		else{
			tableName = "bigdata";
			lineNumber = 1000000;
		}
		Aggregator aggregator = new Aggregator();
		aggregator.getAggregator(originSQL);
		String sql_sentence = SqlRegenerator.regenerate(originSQL, tableName);
		long start = System.nanoTime();
		ResultSet rs = stmt.executeQuery(sql_sentence);
		long end = System.nanoTime();
		long interval = end - start;
		int target_value = 0;
		
		double[] bounds = new double[2];
		long estimatedValueSum = 0;
		double estimatedValueAvg = 0;
		double estimatedValueVariance = 0;
		long estimatedValueCount = 0;
		
		//try to calculate the confidence interval
		if(aggregator.name.equals("sum")){
			bounds = Sum.calculateSumConfidenceInterval(rs, lineNumber, 1000000, epsilon);
			rs.first();
			estimatedValueSum = Sum.process(rs, lineNumber, 1000000);
			bounds[0] += estimatedValueSum;
			bounds[1] += estimatedValueSum;
		}
		else if(aggregator.name.equals("avg")){
			bounds = Avg.calculateAvgConfidenceInterval(rs, lineNumber, 1000000, epsilon);
			rs.first();
			estimatedValueAvg = Avg.process(rs, lineNumber, 1000000);
			bounds[0] += estimatedValueAvg;
			bounds[1] += estimatedValueAvg;
		}
		else if(aggregator.name.equals("variance")){
			estimatedValueVariance = Variance.process(rs, lineNumber, 1000000);
			rs.first();
			bounds = Variance.calculateVarianceConfidenceInterval(rs, lineNumber, 1000000, epsilon);
		}
		else if(aggregator.name.equals("count")){
			//get the value to query
			int startIndex = 0, endIndex = 0;
			for(int i = 0; i < originSQL.length(); i ++){
				if(originSQL.charAt(i) == '=')
					startIndex = i;
			}
			String numStr = originSQL.substring(startIndex + 1);
			target_value = Integer.parseInt(numStr);
			estimatedValueCount = Count.process(rs, lineNumber, 1000000, target_value);
			rs.first();
			bounds = Count.calculateCountConfidenceInterval(rs, lineNumber, 1000000, epsilon, target_value);
			bounds[0] += estimatedValueCount;
			bounds[1] += estimatedValueCount;
		}
		
		
	%>
	
	<table border='12'>
		<caption>Query Result at SampleDB....</caption>
		<tr>
			<%=request.getParameter("sqlInput")%>
			<th>Estimated <%=aggregator.name %></th>
		</tr>
		<br\>
		<tr>
			<% if(aggregator.name.equals("sum")) {%>
				<td><%=estimatedValueSum%></td>
			<%} else if (aggregator.name.equals("avg")) {%>
				<td><%=estimatedValueAvg%></td>
			<%} else if (aggregator.name.equals("variance")) {%>
				<td><%=estimatedValueVariance%></td>
			<%} else if (aggregator.name.equals("count")) {%>
				<td><%=estimatedValueCount%></td>
			<%} %>			
		</tr>
		
		<tr>
			<th>Low Confidence Bound </th>
		</tr>
		<br\>
		<tr>
			<td><%=(long)bounds[0]%></td>
		</tr>
		<tr>
			<th>High Confidence Bound </th>
		</tr>
		<br\>
		<tr>
			<td><%=(long)bounds[1]%></td>
		</tr>
		
	</table>
	<br\>
	
	<table border='3' bgcolor="green">
		<tr>
			<td>Time Cost(s):</td>
		</tr>
		<tr>
			<td><%=(double) interval / 1000000000%></td>
		</tr>
	</table>
	<%
		rs.close();
		stmt.close();
		conn.close();
	%>
</body>
</html>
