package Online;

import java.io.IOException;
import java.sql.SQLException;

public class tableParser {
	public static String getTableName(String originSQL) {
		String[] sql = originSQL.split(" ");
		int from = 0;
		for(int i = 0; i < sql.length; i++) {
			if(sql[i].equals("from")) from = i;
		}
		return sql[from + 1];
	}
	
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
		//test the performance
		String sentance = "select av from a";
		System.out.println(tableParser.getTableName(sentance));
	}
}
