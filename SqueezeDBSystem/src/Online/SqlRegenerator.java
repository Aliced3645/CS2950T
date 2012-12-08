package Online;

public class SqlRegenerator {
	public static String regenerate(String originSQL, String tableName) {
		String[] sql = originSQL.split(" ");
  		String sql_sentence;
  		int where = 0;
  		for(int i = 0; i < sql.length; i++) {
  			if(sql[i].equals("where")) where = i;
  		}
  		if(where == 0) sql_sentence = "select * from " + tableName;
  		else sql_sentence = "select * from " + tableName + " where " + sql[where + 1];
  		return sql_sentence;
	}
}
