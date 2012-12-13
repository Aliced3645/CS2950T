<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Properties" %>
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

String sql_sentence = request.getParameter("sqlInput");
long start = System.nanoTime();
ResultSet rs=stmt.executeQuery(sql_sentence);
long end = System.nanoTime();
long interval = end - start;
ResultSetMetaData rsmd = rs.getMetaData();
int cols = rsmd.getColumnCount();

application.setAttribute("data_test",rsmd);
//application.setAttribute("result_set",rs);

String s2="55";
application.removeAttribute("s2");
session.setAttribute("s2", s2);

Vector<String> result_v = new Vector<String>();


%>
	<center>
	<h3>Query Result at OriginalDB....</h3>
	<table border='6' style="margin-bottom: 20px; margin-top: 20px">
		<tr>
			<%=request.getParameter("sqlInput") %>
			<%for(int i = 1; i <= cols; i++) {%>
			<th><%=rsmd.getColumnName(i)%></th>
			<%}%>
		</tr>
		<br\>
		<%while(rs.next()) {%>
		<tr>
			<%for(int i = 1; i <= cols; i++) {
			
			String ans = rs.getString(i);
			result_v.add(ans);
			%>
			<td><%=ans%></td>
			<%}%>
		</tr>
		<%}%>

	</table>
	<br\>
	<table border='3' bgcolor="white">
		<tr>
			<td>Time Cost(s):</td>
		</tr>
		<tr>
			<td><%=(double)interval/1000000000%></td>
		</tr>
	</table>
	</center>

	<%
		application.setAttribute("result_dataset",result_v);
		rs.close();
		stmt.close();
		conn.close();
	%>
</body>
</html>
