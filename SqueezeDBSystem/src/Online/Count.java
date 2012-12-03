package Online;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

public class Count {
	public static long process(ResultSet result, int sample_size, int db_size, int target_value)
			throws SQLException {
				
		HashMap<Integer, Integer> frequencies = new HashMap<Integer, Integer>();
		Integer k;
		Integer v;

		long count = 0;

		while (result.next()) {
			k = new Integer(result.getInt("value"));// sum first column
			if (frequencies.containsKey(k)) {
				v = frequencies.get(k);
				frequencies.put(k, new Integer(++v));
			} else
				frequencies.put(k, new Integer(1));

		}
			
		Integer frequency = frequencies.get(target_value);
		//estimate
		if(frequency != null)
			count = frequency * db_size /  sample_size ;
		return count;		
	
	}
}


//select count(value) from bigdata where value=10