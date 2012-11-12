<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Properties" %>
<%@ page import="Online.*"  language="java"  pageEncoding="utf-8"%>
<%@page errorPage="SyntexErr.jsp"%>

<html>
<body>

<%
Class.forName("org.postgresql.Driver").newInstance();
String db_url ="jdbc:postgresql://db.cs.brown.edu/squeezedb";
String db_user="szhang";
String db_pw="36453645Zs";
Connection conn= DriverManager.getConnection(db_url, db_user, db_pw);
Statement stmt=conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
//String sql_sentence = request.getParameter("sqlInput") + "_sample";
String sql_sentence = "select * from sampledata08";
long start = System.nanoTime();
ResultSet rs=stmt.executeQuery(sql_sentence);
int sum = Sum.processSum(rs, 1166, 1000000);
long end = System.nanoTime();
long interval = end - start;
//ResultSetMetaData rsmd = rs.getMetaData();
//int cols = rsmd.getColumnCount();
%>
	<table border='12'>
		<caption>Query Result at SampleDB....</caption>
		<tr>
			<%=request.getParameter("sqlInput") %>
					<th>Estimated Sum</th>
		</tr>
		<br\>
		<tr>
			<td><%=sum%></td>
		</tr>
	</table>
	<br\>
	<table border='3' bgcolor="green">
		<tr>
			<td>Time Cost(s):</td>
		</tr>
		<tr>
			<td><%=(double)interval/1000000000%></td>
		</tr>
	</table>
	<%rs.close();
stmt.close();
conn.close();
%>
</body>
</html>
