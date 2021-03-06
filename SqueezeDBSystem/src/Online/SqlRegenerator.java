package Online;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.Vector;

import Zql.ParseException;
import Zql.ZExp;
import Zql.ZExpression;
import Zql.ZQuery;
import Zql.ZqlParser;

public class SqlRegenerator {


	//parse the where portion recursively
//	public static boolean recursiveEqualFinder(ZExpression exp){
//		if(exp == null)
//			return false;
//		if(exp.getOperator().equals("=") == true)
//			return true;
//		Vector<ZExp> ops = exp.getOperands();
//		Iterator<ZExp> it = ops.iterator();
//		while (it.hasNext()) {
//			ZExp op = it.next();
//			if(! (op instanceof Zql.ZConstant))
//				if(recursiveEqualFinder((ZExpression) op) == true)
//					return true;
//		}
//		return false;
//	}
	
	public static String regenerate(String sql, String tableName) throws ParseException {
		
		String sql_sentence = "select * from " + tableName;
		InputStream is = new ByteArrayInputStream(sql.getBytes());
		ZqlParser parser = new ZqlParser(is);
		ZQuery statement = (ZQuery) parser.readStatement();
		ZExpression wheres = (ZExpression) statement.getWhere();
		if (wheres == null) {
			sql_sentence += ";";
		} 
		//there is "where" clause
		else{
			sql_sentence += " where ";
			String whereSentence = wheres.toString();
			String modifiedWhere = whereSentence.replaceAll("[abc]\\.",tableName + ".");
			sql_sentence += modifiedWhere + ";";
		}
		return sql_sentence;
	}
	
	public static String regenerate2(String sql, String tableName){
		String sql_sentence = "select * from " + tableName;
		sql_sentence += ";";
		return sql_sentence;
	}
	
	
	public static void main(String[] args) throws ClassNotFoundException,
			SQLException, IOException, ParseException {
		//String sql =
		// "select sum(av),avg(bv),avg(cv) from a,b,c where ((a.bi = b.bi) AND (b.ci = c.ci)) AND ((av < 5000) AND (bv < 5000 OR cv < 5000));";
		String sql = "select sum(av) from a where av > 5000;";
		String tableName = "aj_h";
		String result = SqlRegenerator.regenerate(sql, tableName);
		System.out.println(result);
	}
}
