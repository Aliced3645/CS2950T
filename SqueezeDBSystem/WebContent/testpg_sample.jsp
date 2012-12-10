<%@page import="Zql.*" language="java"%>
<%@page import="Offline.DatabaseSampler"%>
<%@page import="Offline.OfflineDriver"%>
<%@page import="Offline.OfflineDriverMultiTables"%>
<%@page import="Online.AggregatorPair"%>
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

	<table border='12'>
		<caption>Query Result at SampleDB....</caption>
		
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
		String originTable = tableParser.getTableName(originSQL);
		String inputRadio = request.getParameter("accuracy");
		int sampleSize;
		double epsilon = 0;
		String tableName = null;
		int lineNumber;
		if (!inputRadio.isEmpty()) {
			if (inputRadio.equals("highAccuracy")) {
				if(originTable.equals("a")) tableName = "aj_h";
				else if(originTable.equals("b")) tableName = "bj_h";
				else if(originTable.equals("c")) tableName = "cj_h";
				lineNumber = OfflineDriverMultiTables.sampleRowNumberHigh;
				epsilon = 0.1;
			} else if (inputRadio.equals("middleAccuracy")) {
				if(originTable.equals("a")) tableName = "aj_m";
				else if(originTable.equals("b")) tableName = "bj_m";
				else if(originTable.equals("c")) tableName = "cj_m";
				lineNumber = OfflineDriverMultiTables.sampleRowNumberMid;
				epsilon = 0.2;
			} else if (inputRadio.equals("lowAccuracy")) {
				if(originTable.equals("a")) tableName = "aj_l";
				else if(originTable.equals("b")) tableName = "bj_l";
				else if(originTable.equals("c")) tableName = "cj_l";
				lineNumber = OfflineDriverMultiTables.sampleRowNumberLow;
				epsilon = 0.3;
			} else {
				tableName = "a";
				lineNumber = 100000;
			}
		}
		else{
			tableName = "a";
			lineNumber = 100000;
		}
		
		Aggregator aggregator = new Aggregator();
		aggregator.getAggregator(originSQL);
		//parsed!
		Iterator<AggregatorPair> it = aggregator.aggregators.iterator();
		String sql_sentence = SqlRegenerator.regenerate(originSQL, tableName);	
		long start = System.nanoTime();
		ResultSet rs = stmt.executeQuery(sql_sentence);
		long end = System.nanoTime();
		long interval = end - start;
		int target_value = 0;
		System.out.println(sql_sentence);
		
		double[] bounds = new double[2];
		long estimatedValueSum = 0;
		double estimatedValueAvg = 0;
		double estimatedValueVariance = 0;
		long estimatedValueCount = 0;
		EstimatedResult er = new EstimatedResult();
		//just test first
		while(it.hasNext()){
			AggregatorPair ap = it.next();
			rs.first();
			//try to calculate the confidence interval
			if(ap.aggregator.equals("sum")){
				estimatedValueSum = Sum.process(rs, ap.column, lineNumber, 100000);
				rs.first();
				bounds = Sum.calculateSumConfidenceInterval(rs, ap.column, lineNumber, 100000, epsilon);
				bounds[0] += estimatedValueSum;
				bounds[1] += estimatedValueSum;
				er.aggregateName.add("SUM");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				double k = estimatedValueSum;
				er.estimatedValue.add(k);
			}
			else if(ap.aggregator.equals("avg")){
				bounds = Avg.calculateAvgConfidenceInterval(rs, ap.column,lineNumber, 100000, epsilon);
				rs.first();
				estimatedValueAvg = Avg.process(rs, ap.column, lineNumber, 100000);
				bounds[0] += estimatedValueAvg;
				bounds[1] += estimatedValueAvg;
				er.aggregateName.add("AVG");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				er.estimatedValue.add(estimatedValueAvg);
			}
			else if(ap.aggregator.equals("variance")){
				estimatedValueVariance = Variance.process(rs, ap.column,lineNumber, 100000);
				rs.first();
				bounds = Variance.calculateVarianceConfidenceInterval(rs, ap.column,lineNumber, 100000, epsilon);
				er.aggregateName.add("VAR");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				er.estimatedValue.add(estimatedValueVariance);
			}
			else if(ap.aggregator.equals("count")){
				//get the value to query
				//TODO:to modify
				int startIndex = 0, endIndex = 0;
				for(int i = 0; i < originSQL.length(); i ++){
					if(originSQL.charAt(i) == '=')
						startIndex = i;
				}
				String numStr = originSQL.substring(startIndex + 1);
				target_value = Integer.parseInt(numStr);
				estimatedValueCount = Count.process(rs, ap.column,lineNumber, 100000, target_value);
				rs.first();
				bounds = Count.calculateCountConfidenceInterval(rs, ap.column,lineNumber, 100000, epsilon, target_value);
				bounds[0] += estimatedValueCount;
				bounds[1] += estimatedValueCount;
				er.aggregateName.add("COUNT");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				double k = estimatedValueCount;
				er.estimatedValue.add(k);
			}
		}
		%>
		
		<tr>
			<%=request.getParameter("sqlInput")%>
			<% Iterator<String> its = er.aggregateName.iterator();
				while(its.hasNext()){
					String aggregatename = its.next(); %>	
				<th>Estimated <%=aggregatename %></th>
			<% }%>
		</tr>
		<br\>
		
		<tr>
			<% Iterator<Double> itd = er.estimatedValue.iterator();
				while(itd.hasNext()){
					double answer = itd.next(); %>	
				<th><%=answer%></th>
			<% }%>
		</tr>
		<br\>
		
		<tr>
			<% Iterator<Double> itl = er.lowerBound.iterator();
				while(itl.hasNext()){
					double answer = itl.next(); %>	
				<th><%=answer%></th>
			<% }%>
		</tr>
		<br\>
		
		<tr>
			<% Iterator<Double> itu = er.upperBound.iterator();
				while(itu.hasNext()){
					double answer = itu.next(); %>	
				<th><%=answer%></th>
			<% }%>
		</tr>
		<br\>
		
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
