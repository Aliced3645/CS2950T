package Online;

public class tableParser {
	public static String getTableName(String originSQL) {
		String[] sql = originSQL.split(" ");
		int from = 0
		for(int i = 0; i < sql.length; i++) {
			if(sql[i].equals("from")) from = i;
		}
		return sql[from + 1];
	}
}
