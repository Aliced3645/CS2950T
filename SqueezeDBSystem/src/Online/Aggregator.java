package Online;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.Vector;

import Zql.*;


public class Aggregator {
	public String name;
	public String rowName;
	
	public Aggregator() {
		aggregators = new Vector<AggregatorPair>();
		this.name = "";
	}
	
	public Vector<AggregatorPair> aggregators;
	
	public void getAggregator(String originSQL) throws ParseException {
		try{
			InputStream is = new ByteArrayInputStream(originSQL.getBytes());
			ZqlParser parser = new ZqlParser(is);
			ZQuery statement = (ZQuery) parser.readStatement();
			Vector<ZSelectItem> ss = statement.getSelect();
			Iterator<ZSelectItem> it = ss.iterator();
			while(it.hasNext()){
				//print sth
				ZSelectItem temp = it.next();
				AggregatorPair ap = new AggregatorPair();
				ap.aggregator = temp.getAggregate();
				String aggregateString = temp.getColumn();
				int j = 0;
				for(int i = 0; i < aggregateString.length(); i ++){
					if(aggregateString.charAt(i) == '('){
						j = i;
						break;
					}
				}
				String columnName = aggregateString.substring(j+1,aggregateString.length()-1);
				ap.column = columnName;
				aggregators.add(ap);	
			}
		}catch(ParseException e){
			System.out.println("cao");
			System.out.println(e.toString());
		}
	}
	
	
	
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException, ParseException {
		
		Aggregator ag = new Aggregator();
		ag.getAggregator("select sum(av),avg(bv) from a,b where a.bi = b.bi;");
		Iterator<AggregatorPair> it = ag.aggregators.iterator();
		while(it.hasNext()){
			AggregatorPair ap = it.next();
			System.out.println(ap.aggregator);
			System.out.println(ap.column);
		}
	}
}

