package Online;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.Vector;

import Zql.*;


public class tableParser {
	public static String getTableName(String originSQL) throws ParseException {
		InputStream is = new ByteArrayInputStream(originSQL.getBytes());
		ZqlParser parser = new ZqlParser(is);
		ZQuery statement = (ZQuery) parser.readStatement();
		Vector<ZFromItem> tables = statement.getFrom();
		Iterator<ZFromItem> it = tables.iterator();
		ZFromItem ft = it.next();
		return ft.getTable();
	}
		
	
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException, ParseException {
		//test the performance
		String sentance = "select sum(av),avg(bv) from a,b where a.bi = b.bi;";
		System.out.println(tableParser.getTableName(sentance));
	}
}
