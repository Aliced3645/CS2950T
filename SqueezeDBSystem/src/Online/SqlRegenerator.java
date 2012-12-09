package Online;

import java.io.IOException;
import java.sql.SQLException;

import Zql.ParseException;

public class SqlRegenerator {
	public static String regenerate(String originSQL, String tableName) {
		String[] sql = originSQL.split(" ");
		String sql_sentence;
		// TODO: modify where later
		// int where = 0;
		// for(int i = 0; i < sql.length; i++) {
		// if(sql[i].equals("where")) where = i;
		// }
		// if(where == 0)
		sql_sentence = "select * from " + tableName + ";";
		// else sql_sentence = "select * from " + tableName + " where " +
		// sql[where + 1];
		return sql_sentence;
	}

	// test it
	public static void main(String[] args) throws ClassNotFoundException,
			SQLException, IOException, ParseException {
		String sql = "select sum(av),avg(bv) from a,b where a.bi = b.bi;";
		String return_sql = SqlRegenerator.regenerate(sql, "aj_l");
		System.out.println(return_sql);
	}
}
