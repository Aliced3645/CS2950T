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

	<center>
	<h3>Query Result at SampleDB....</h3>
	
	<table border='6' style="margin-bottom: 20px; margin-top: 20px">
		
		
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
		String[] parts = originSQL.split(" ");
		boolean varianceB = false;
		for(int i = 0; i < parts.length; i ++){
			if(parts[i].charAt(0) == 'v'){
				varianceB = true;
				break;
			}
		}
		String originTable = tableParser.getTableName(originSQL,varianceB);
		String inputRadio = request.getParameter("accuracy");
		int sampleSize = 0;
		double epsilon = 0;
		String tableName = null;
		int lineNumber;
		
		if (!inputRadio.isEmpty()) {
			if (inputRadio.equals("highAccuracy")) {
				if(originTable.equals("a")) tableName = "aj_h";
				else if(originTable.equals("b")) tableName = "bj_h";
				else if(originTable.equals("c")) tableName = "cj_h";
				sampleSize = 9235;
				epsilon = 0.1;
			} else if (inputRadio.equals("middleAccuracy")) {
				if(originTable.equals("a")) tableName = "aj_m";
				else if(originTable.equals("b")) tableName = "bj_m";
				else if(originTable.equals("c")) tableName = "cj_m";
				epsilon = 0.2;
				sampleSize = 2309;
			} else if (inputRadio.equals("lowAccuracy")) {
				if(originTable.equals("a")) tableName = "aj_l";
				else if(originTable.equals("b")) tableName = "bj_l";
				else if(originTable.equals("c")) tableName = "cj_l";
				epsilon = 0.3;
				sampleSize = 1027;
			} else {
				tableName = "a";
				lineNumber = 100000;
			}
		}
		else{
			tableName = "a";
			lineNumber = 100000;
		}
		

		//parsed!
		String sql_sentence;
		Iterator<AggregatorPair> it;
		if(varianceB == false){
			Aggregator aggregator = new Aggregator();
			aggregator.getAggregator(originSQL);
			it = aggregator.aggregators.iterator();
			sql_sentence = SqlRegenerator.regenerate(originSQL, tableName);	
			System.out.println(sql_sentence);
		}
		else{
			sql_sentence = SqlRegenerator.regenerate2(originSQL, tableName);
			System.out.println(sql_sentence);
			Aggregator aggregator = new Aggregator();
			AggregatorPair ap = new AggregatorPair();
			int start = 0, end = 0;
			for(int i = 0; i < originSQL.length(); i ++){
				if(originSQL.charAt(i) == '('){
					start = i+1;
				}
				if(originSQL.charAt(i) == ')'){
					end = i;
				}
			}
			ap.column =  originSQL.substring(start, end);
			System.out.print(ap.column);
			ap.aggregator = "variance";
			aggregator.aggregators.add(ap);
			it = aggregator.aggregators.iterator();
		}
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

		rs.last();
		lineNumber = rs.getRow();
		rs.first();
		System.out.println(lineNumber);
		
		//just test first
		while(it.hasNext()){
			AggregatorPair ap = it.next();
			rs.first();
			//try to calculate the confidence interval
			if(ap.aggregator.equals("sum")){
				estimatedValueSum = Sum.process(rs, ap.column, sampleSize, 100000);
				rs.first();
				bounds = Sum.calculateSumConfidenceInterval(rs, ap.column, sampleSize, 100000, epsilon);
				bounds[0] += estimatedValueSum;
				bounds[1] += estimatedValueSum;
				er.aggregateName.add("SUM");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				double k = estimatedValueSum;
				er.estimatedValue.add(k);
			}
			else if(ap.aggregator.equals("avg")){
				bounds = Avg.calculateAvgConfidenceInterval(rs, ap.column,sampleSize, 100000, epsilon);
				rs.first();
				estimatedValueAvg = Avg.process(rs, ap.column, sampleSize, 100000);
				bounds[0] += estimatedValueAvg;
				bounds[1] += estimatedValueAvg;
				er.aggregateName.add("AVG");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				er.estimatedValue.add(estimatedValueAvg);
			}
			else if(ap.aggregator.equals("variance")){
				estimatedValueVariance = Variance.process(rs, ap.column,sampleSize, 100000);
				rs.first();
				bounds = Variance.calculateVarianceConfidenceInterval(rs, ap.column,sampleSize, 100000, epsilon);
				er.aggregateName.add("VAR");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				er.estimatedValue.add(estimatedValueVariance);
			}
			else if(ap.aggregator.equals("count")){
				//get the value to query
				//TODO:to modify
				estimatedValueCount = Count.process(rs, ap.column,sampleSize, 100000);
				rs.first();
				bounds = Count.calculateCountConfidenceInterval(rs, ap.column,sampleSize, 100000, epsilon);
				bounds[0] += estimatedValueCount;
				bounds[1] += estimatedValueCount;
				er.aggregateName.add("COUNT");
				er.upperBound.add(bounds[1]);
				er.lowerBound.add(bounds[0]);
				double k = estimatedValueCount;
				er.estimatedValue.add(k);
			}
		}
		application.setAttribute("sample_data_test", er);
		%>
		
		<tr>
			<th>Estimated Aggregator</th>
			<%=request.getParameter("sqlInput")%>
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
	

	<br\>
	
	<table border='3' bgcolor="white">
		<tr>
			<td>Time Cost(s):</td>
		</tr>
		<tr>
			<td><%=(double) interval / 1000000000%></td>
		</tr>
	</table>
	
	</center>
	<%
		rs.close();
		stmt.close();
		conn.close();
	%>

</body>
</html>
