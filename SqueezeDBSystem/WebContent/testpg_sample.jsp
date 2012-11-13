<%@page import="Offline.DatabaseSampler"%>
<%@page import="Offline.OfflineDriver"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.Properties"%>
<%@page import="Online.*" language="java" pageEncoding="utf-8"%>
<%@page errorPage="SyntexErr.jsp"%>

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

		String tableName;
		int lineNumber;
		if (!inputRadio.isEmpty()) {
			if (inputRadio.equals("highAccuracy")) {
				tableName = OfflineDriver.sampleTableHigh;
				lineNumber = OfflineDriver.sampleRowNumberHigh;
			} else if (inputRadio.equals("middleAccuracy")) {
				tableName = OfflineDriver.sampleTableMid;
				lineNumber = OfflineDriver.sampleRowNumberMid;
			} else if (inputRadio.equals("lowAccuracy")) {
				tableName = OfflineDriver.sampleTableLow;
				lineNumber = OfflineDriver.sampleRowNumberLow;
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
				<td><%=Sum.process(rs, lineNumber, 1000000)%></td>
			<%} else if (aggregator.name.equals("avg")) {%>
				<td><%=Avg.process(rs, lineNumber, 1000000)%></td>
			<%} %>
				
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
