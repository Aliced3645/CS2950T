public class SqlRegenerator {
	public static String regenerate(String originSQL, String tableName) {
		String[] sql = originSQL.split(" ");
		String sql_sentence;
		if(sql.length == 6)
            sql_sentence = sql[0] + " * " + sql[2] + " " + tableName + " " + sql[4] + " " + sql[5];
        else
            sql_sentence = sql[0] + " * " + sql[2] + " " + tableName;
		return sql_sentence;
	}
}
