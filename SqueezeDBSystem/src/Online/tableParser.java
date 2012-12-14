package Online;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.Vector;

import Zql.*;


public class tableParser {
	public static String getTableName(String originSQL, boolean variance) throws ParseException {
		if(variance == true){
			String[] parts = originSQL.split(" ");
			int k = 0;
			for(int i = 0; i < parts.length; i ++){
				if(parts[i].equals("from")){
					k = i + 1;
					break;
				}
			}
			char a = parts[k].charAt(0);
			StringBuffer b = new StringBuffer("a");
			b.setCharAt(0, a);
			String toReturn = b.toString();
			return toReturn;
		}
		else{
			InputStream is = new ByteArrayInputStream(originSQL.getBytes());
			ZqlParser parser = new ZqlParser(is);
			ZQuery statement = (ZQuery) parser.readStatement();
			Vector<ZFromItem> tables = statement.getFrom();
			Iterator<ZFromItem> it = tables.iterator();
			ZFromItem ft = it.next();
			return ft.getTable();
		}
	}
	
		
	
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException, ParseException {
		//test the performance
		String sentance = "select sum(av),avg(bv) from a,b where a.bi = b.bi;";
		System.out.println(tableParser.getTableName(sentance,false));
	}
}
